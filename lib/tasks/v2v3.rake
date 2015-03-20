# To extract data from v2:
# production --- $ heroku run rake v2v3:export_data --app production-learnsignal
# staging ------ # heroku run rake v2v3:export_data --app signaleducation

namespace :v2v3 do

  BUCKET = 'learnsignal3-data-migration'

  desc 'Import data from v2 website'
  task(import_data: :environment) do
    # USAGE: rake v2v3:import_data {optional_file_name.json}

    puts
    puts 'rake v2v3:import_data'
    puts '---------------------'

    #### Make sure we are 'ok' to run
    if Rails.env.production? && ENV['learnsignal_v3_stripe_live_mode'] == 'live'
      message('ERROR', 'v2v3:import_data - Execution HALTED as we are in LIVE / Production mode')
      exit
    end

    #### Find the data file and import it into a hash
    source_file = ARGV[1] || 'v2_data.json'
    s3 = connect_to_s3

    #### set up the ancestry for Finance / CFA / CFA Professional / Level 1
    if Rails.env.development? || Rails.env.staging?
      SUBJECT_AREA_ID = 1
      INSTITUTION_ID = 2
      QUALIFICATION_ID = 3
      EXAM_LEVEL_ID = 1
    else # RAILS.env.production?
      SUBJECT_AREA_ID = 1
      INSTITUTION_ID = 1
      QUALIFICATION_ID = 1
      EXAM_LEVEL_ID = 1
    end
    TUTOR_ID = User.all_tutors.first.try(:id) || User.all_admins.first.id

    migrate_data = aws_read_file(s3, source_file)
    message('INFO', "Loading data from: #{source_file} - Source environment: #{migrate_data[:environment]}")

    #### Process the data
    # course content
    migrate_courses(migrate_data[:courses]) # ExamSection                   - done
    migrate_topics(migrate_data[:topics]) # CourseModule                    - done
    migrate_videos(migrate_data[:videos]) # CME & CME-V                     - done
    migrate_resources(migrate_data[:resources]) # CME-resources             - done
    migrate_notes(migrate_data[:notes]) # CME-V (transcript)                - done
    migrate_quizzes(migrate_data[:quizzes]) # CME & CME-Q                   - done
    migrate_questions(migrate_data[:questions]) # Question + 2xQuizContents - done
    migrate_answers(migrate_data[:answers]) # QuizAnswer + QuizContent      - done
    # ---- Can't do this one - it embeds images into questions (only 7 records)
    # migrate_markdown_images(migrate_data[:markdown_images]) #             - skip
    migrate_steps(migrate_data[:steps]) # CME                               - done

    # users and payments
    migrate_users(migrate_data[:users]) #                                   - done
    migrate_users_courses(migrate_data[:users_courses])
    # ---- empty; data is embedded inside users
    # migrate_courses(migrate_data[:billing_addresses])                     - skip
    # ---- empty; data is embedded inside customers
    # migrate_courses(migrate_data[:cards])                                 - skip
    migrate_customers(migrate_data[:customers])
    # migrate_courses(migrate_data[:invoices])                              - skip
    # migrate_courses(migrate_data[:invoice_items])                         - skip
  # migrate_plans(migrate_data[:plans])
  # migrate_subscriptions(migrate_data[:subscriptions])

    #### Rename the source file, and finish.
#    rename_source_and_finish(s3, source_file)
  end

  #### course content

  def migrate_answers(exports)
    # Answer _id:, sequence_number: nil, question_id: nil, body: "Answer text here...", correct: false
    message('INFO', 'Starting to process Answers...')
    exports.each do |export|
      it = ImportTracker.where(old_model_name: 'answer', old_model_id: export[:_id]).first
      it.nil? ? create_answer(export) :
              compare_and_update_answer(it, export)
    end
    message('INFO', "Complete: #{exports.count} Answers processed")
  end

  def create_answer(export)
    # Answer _id:, sequence_number: nil, question_id: nil, body: "Answer text here...", correct: false
    qq_it = ImportTracker.where(old_model_name: 'question', old_model_id: export[:question_id], new_model_name: 'quiz_question').first
    qq = QuizQuestion.find(qq_it.new_model_id)
    answer = QuizAnswer.create!(
            quiz_question_id: qq.id,
            correct: export[:correct],
            difficulty_level: 'easy',
            degree_of_wrongness: (export[:correct] ? 'correct' : 'wrong')
    )
    content = QuizContent.create!(
            quiz_answer_id: answer.id,
            text_content: export[:body],
            contains_mathjax: false,
            contains_image: false,
            sorting_order: 1
    )
    it1 = ImportTracker.create!(
            old_model_name: 'answer', old_model_id: export[:_id],
            new_model_name: 'quiz_answer', new_model_id: answer.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    it2 = ImportTracker.create!(
            old_model_name: 'answer', old_model_id: export[:_id],
            new_model_name: 'quiz_content', new_model_id: content.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    message('INFO', "-- export:answer #{export[:_id]} imported to QuizAnswer #{answer.id} it:id #{it1.id}.")
    message('INFO', "-- export:answer #{export[:_id]} imported to QuizContent #{content.id} it:id #{it2.id}.")
  end

  def compare_and_update_answer(it, export)
    # Answer _id:, sequence_number: nil, question_id: nil, body: "Answer text here...", correct: false
    answer = QuizAnswer.find(it.new_model_id)
    # nothing can be changed about question.
    content = answer.quiz_contents.first
    unless content.text_content == export[:body].squish
      content.update_attributes!(
              text_content: export[:body]
      )
      message('INFO', "-- export:answer #{export[:_id]} UPDATED to QuizContent #{content.id} it:id #{it.id}.")
    end
  end

  def migrate_courses(exports)
    # sample = {:_id=>1, :_slugs=>["first-course"], :created_at=>"2014-08-11T12:14:38.919Z",
    #           :description=>"Sample course with simple topics!", :has_steps=>true,
    #           :name=>"First Course", :sequence_number=>1, :status=>"published",
    #           :updated_at=>"2014-08-11T12:14:38.919Z"}

    message('INFO', 'Starting to process Courses...')
    exports.each do |export|
      it = ImportTracker.where(old_model_name: 'course', old_model_id: export[:_id]).first
      it.nil? ? create_course(export) :
                compare_and_update_course(it, export)
    end
    message('INFO', "Complete: #{exports.count} Courses processed")
  end

  def create_course(export)
    shortened_name = export[:name].to_s.split(' - Level 1')[0]
    es = ExamSection.where(name: shortened_name).first_or_initialize
    es.assign_attributes( # name: exported_name,
                exam_level_id: EXAM_LEVEL_ID,
                qualification_id: QUALIFICATION_ID,
                institution_id: INSTITUTION_ID,
                subject_area_id: SUBJECT_AREA_ID,
                name_url: shortened_name.downcase,
                active: (export[:status] == 'published'),
                sorting_order: export[:sequence_number] || 1
    )
    es.save!
    it = ImportTracker.create!(
                old_model_name: 'course', old_model_id: export[:_id],
                new_model_name: 'exam_section', new_model_id: es.id,
                imported_at: Time.now,
                original_data: export.to_json
    )
    message('INFO', "-- export:course #{export[:_id]} imported to ExamSection #{es.id} it:id #{it.id}.")
  end

  def compare_and_update_course(it, export)
    es = ExamSection.find(it.new_model_id)
    if es.updated_at > it.updated_at
      message('WARN', "-- export:course #{export[:_id]} UPDATED locally. Your changes may be lost during import - ExamSection #{es.id} it:id #{it.id}.")
    else
      message('INFO', "-- export:course #{export[:_id]} matches to ExamSection #{es.id} it:id #{it.id}.")
    end
    if Time.parse(export[:updated_at]) > it.imported_at
      es.update_attributes!(
              name: export[:name].split(' - Level 1')[0],
              name_url: export[:name].split(' - Level 1')[0].downcase,
              active: (export[:status] == 'published'),
              sorting_order: export[:sequence_number]
      )
      it.update_attributes!(imported_at: Time.now,
                            original_data: export.to_json)
      message('WARN', "-- export:course #{export[:_id]} UPDATED to ExamSection #{es.id} it:id #{it.id}.")
    end
  end

  def migrate_markdown_images(exports)
    # {:content=>"Quiz_R8_Q6.png", :updated_at=>"2014-09-17T11:17:24.316Z", :created_at=>"2014-09-17T11:17:24.316Z", :_id=>1}
    puts 'Could NOT import Markdown Images'
    ####
  end

  def migrate_notes(exports)
    # <Note _id: , html_body: nil, associated_files_paths: [], video_id: nil, uid: "abc123">
    message('INFO', 'Starting to process Notes...')
    exports.each do |export|
      it = ImportTracker.where(old_model_name: 'note', old_model_id: export[:_id]).first
      it.nil? ? create_note(export) :
              compare_and_update_note(it, export)
    end
    message('INFO', "Complete: #{exports.count} Notes processed")
  end

  def create_note(export)
    cmev_it = ImportTracker.where(old_model_name: 'video', old_model_id: export[:video_id], new_model_name: 'course_module_element_video').first
    cmev = CourseModuleElementVideo.find(cmev_it.new_model_id)
    cmev.update_attributes!(transcript: export[:html_body].gsub('<body>','').gsub('</body>',''))
    it = ImportTracker.create!(
            old_model_name: 'note', old_model_id: export[:_id],
            new_model_name: 'course_module_element_video', new_model_id: cmev.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    message('INFO', "-- export:note #{export[:_id]} imported into CourseModuleElementVideo-transcript #{cmev.id} it:id #{it.id}.")
  end

  def compare_and_update_note(it, export)
    cmev = CourseModuleElementVideo.find(it.new_model_id)
    unless cmev.transcript == (export[:html_body].gsub('<body>','').gsub('</body>',''))
      cmev.update_attributes!(transcript: export[:html_body].gsub('<body>','').gsub('</body>',''))

      message('INFO', "-- export:note #{export[:_id]} UPDATED to CourseModuleElementVideo #{cmev.id} it:id #{it.id}.")
      it.touch
    end
  end

  def migrate_questions(exports)
    # Question _id: , sequence_number: nil, quiz_id: nil, body: "Question text here..."
    message('INFO', 'Starting to process Questions...')
    exports.each do |export|
      it = ImportTracker.where(old_model_name: 'question', old_model_id: export[:_id], new_model_name: 'quiz_question').first
      it.nil? ? create_question(export) :
                compare_and_update_question(it, export)
    end
    message('INFO', "Complete: #{exports.count} Questions processed")
  end

  def create_question(export)
    # Question _id: , sequence_number: nil, quiz_id: nil, body: "Question text here..."
    cmeq_it = ImportTracker.where(old_model_name: 'quiz', old_model_id: export[:quiz_id], new_model_name: 'course_module_element_quiz').first
    cmeq = CourseModuleElementQuiz.find(cmeq_it.new_model_id)
    question = QuizQuestion.create!(
            course_module_element_quiz_id: cmeq.id,
            course_module_element_id: cmeq.course_module_element_id,
            difficulty_level: 'easy'
    )
    content = QuizContent.create!(
            quiz_question_id: question.id,
            text_content: export[:body],
            contains_mathjax: false,
            contains_image: false,
            sorting_order: 1
    )
    solution = QuizContent.create!(
            quiz_solution_id: question.id,
            text_content: 'Solution goes here...',
            contains_mathjax: false,
            contains_image: false,
            sorting_order: 1
    )
    it1 = ImportTracker.create!(
            old_model_name: 'question', old_model_id: export[:_id],
            new_model_name: 'quiz_question', new_model_id: question.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    it2 = ImportTracker.create!(
            old_model_name: 'question', old_model_id: export[:_id],
            new_model_name: 'quiz_content', new_model_id: content.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    it3 = ImportTracker.create!(
            old_model_name: 'question', old_model_id: export[:_id],
            new_model_name: 'quiz_solution', new_model_id: solution.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    message('INFO', "-- export:question #{export[:_id]} imported to QuizQuestion #{question.id} it:id #{it1.id}.")
    message('INFO', "-- export:question #{export[:_id]} imported to QuizContent #{content.id} it:id #{it2.id}.")
    message('INFO', "-- export:question #{export[:_id]} imported to QuizSolution #{solution.id} it:id #{it3.id}.")
  end

  def compare_and_update_question(it, export)
    # Question _id: , sequence_number: nil, quiz_id: nil, body: "Question text here..."
    question = QuizQuestion.find(it.new_model_id)
    # nothing can be changed about question.
    content = question.quiz_contents.first
    unless content.text_content == export[:body].squish
      content.update_attributes!(
            text_content: export[:body]
      )
      message('INFO', "-- export:question #{export[:_id]} UPDATED to QuizContent #{content.id} it:id #{it.id}.")
    end
    # no need to check the solution either - it was auto-populated.
  end

  def migrate_quizzes(exports)
    # sample <Quiz _id: , sequence_number: nil, topic_id: nil, name: nil, description: nil, _slugs: [], _type: "Quiz", number_of_questions: 10>
    message('INFO', 'Starting to process Quizzes...')
    exports.each do |export|
      it = ImportTracker.where(old_model_name: 'quiz', old_model_id: export[:_id]).first
      it.nil? ? create_quiz(export) :
                compare_and_update_quiz(it, export)
    end
    message('INFO', "Complete: #{exports.count} Quizzes processed")
    ####
  end

  def create_quiz(export)
    # sample <Quiz _id: ,  name: nil, description: nil, sequence_number: nil, topic_id: nil, _slugs: [], _type: "Quiz", number_of_questions: 10>
    cm_it = ImportTracker.where(old_model_name: 'topic', old_model_id: export[:topic_id]).first
    cm    = CourseModule.find(cm_it.new_model_id)
    cme   = CourseModuleElement.where(name: export[:name], is_quiz: true, course_module_id: cm.id).first_or_initialize
    cme.assign_attributes( # name: export[:name], course_module_id: cm.id,
            name_url: export[:name].downcase,
            description: export[:description],
            estimated_time_in_seconds: (export[:number_of_questions] * 30),
            sorting_order: export[:sequence_number],
            tutor_id: TUTOR_ID,
            ### todo: related_video_id: nil, # needs to be filled in later
            is_video: false,
            is_quiz: true,
            active: cm.exam_section.active
    )
    cme.save!

    # need to create a CME-video too, if one doesn't already exist
    cme_quiz  = CourseModuleElementQuiz.where(course_module_element_id: cme.id).first_or_initialize
    cme_quiz.assign_attributes( # course_module_element_id: cme.id
            number_of_questions: 5, # Default requested by Philip - (export[:number_of_questions] * 30),
            question_selection_strategy: 'random'
    )
    cme_quiz.save!
    cme.update_attributes!(related_quiz_id: cme_quiz.id)

    # now, create two ImportTrackers
    it1 = ImportTracker.create!(
            old_model_name: 'quiz', old_model_id: export[:_id],
            new_model_name: 'course_module_element', new_model_id: cme.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    it2 = ImportTracker.create!(
            old_model_name: 'quiz', old_model_id: export[:_id],
            new_model_name: 'course_module_element_quiz', new_model_id: cme_quiz.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    message('INFO', "-- export:quiz #{export[:_id]} imported to CourseModuleElement #{cme.id} it:id #{it1.id}.")
    message('INFO', "-- export:quiz #{export[:_id]} imported to CourseModuleElementQuiz #{cme_quiz.id} it:id #{it2.id}.")
  end

  def compare_and_update_quiz(it, export)
    # sample <Quiz _id: , sequence_number: nil, topic_id: nil, name: nil, description: nil, _slugs: [], _type: "Quiz", number_of_questions: 10>
    cme = CourseModuleElement.find(it.new_model_id)
    unless cme.name == export[:name].to_s.squish && cme.description.to_s.squish == export[:description].to_s.squish &&
              cme.estimated_time_in_seconds == (export[:number_of_questions] * 30) &&
              cme.sorting_order == export[:sequence_number]
      cme.update_attributes!(
              name: export[:name], # course_module_id: cm.id,
              name_url: export[:name].downcase,
              description: export[:description],
              estimated_time_in_seconds: (export[:number_of_questions] * 30),
              sorting_order: export[:sequence_number],
              # tutor_id: TUTOR_ID,
              ### todo: related_video_id: nil, # needs to be filled in later
              is_video: false,
              is_quiz: true
      # active: cm.exam_section.active
      )
      message('INFO', "-- export:quiz #{export[:_id]} UPDATED to CourseModuleElement #{cme.id} it:id #{it.id}.")
    end
    cme_quiz = cme.course_module_element_quiz
    unless cme_quiz.number_of_questions == 5
      cme_quiz.update_attributes!( # course_module_element_id: cme.id
              number_of_questions: 5, # Default requested by Philip - (export[:number_of_questions] * 30),
              question_selection_strategy: 'random'
      )
      it2 = ImportTracker.where(new_model_name: 'course_module_element_quiz', new_model_id: cme_quiz.id).first
      it2.touch
      message('INFO', "-- export:quiz #{export[:_id]} UPDATED to CourseModuleElementQuiz #{cme_quiz.id} it:id #{it2.id}.")
    end
  end

  def migrate_resources(exports)
    message('INFO', 'Starting to process Resources...')
    exports.each do |export|
      it = ImportTracker.where(old_model_name: 'resource', old_model_id: export[:_id]).first
      it.nil? ? create_resource(export) :
              compare_and_update_resource(it, export)
    end
    message('INFO', "Complete: #{exports.count} Resources processed")
  end

  def create_resource(export)
    # Sample: {:_id=>1, :external_url=>"http://www.docertifications.com/r17_l1", :name=>"Useful resources", :video_id=>12}

    cme_it = ImportTracker.where(old_model_name: 'video', old_model_id: export[:video_id], new_model_name: 'course_module_element').first
    cme = CourseModuleElement.find(cme_it.new_model_id)
    cmer = CourseModuleElementResource.create!(
            name: export[:name],
            description: export[:name],
            course_module_element_id: cme.id,
            web_url: (export[:external_url].blank? ? export[:content] : export[:external_url])
    )
    it = ImportTracker.create!(
            old_model_name: 'resource', old_model_id: export[:_id],
            new_model_name: 'course_module_element_resource', new_model_id: cmer.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    message('INFO', "-- export:resource #{export[:_id]} imported to CourseModuleElementResource #{cmer.id} it:id #{it.id}.")
  end

  def compare_and_update_resource(it, export)
    cmer = CourseModuleElementResource.find(it.new_model_id)
    unless cmer.name == export[:name] && cmer.description == export[:name] &&
            cmer.web_url == (export[:external_url].blank? ? export[:content] : export[:external_url])
      cmer.update_attributes!(
              name: export[:name],
              description: export[:name],
              web_url: (export[:external_url].blank? ? export[:content] : export[:external_url])
      )
      message('INFO', "-- export:video #{export[:_id]} UPDATED to CourseModuleElementResource #{cmer.id} it:id #{it.id}.")
      it.touch
    end
  end

  def migrate_steps(exports)
    # Quiz _id: 153, sequence_number: 8, topic_id: 24, name: "Quiz: Commodities", description: nil, _slugs: ["quiz-commodities-1"], _type: "Quiz", number_of_questions: 10>
    message('INFO', 'Starting to process Steps...')
    exports.each do |export|
      it = ImportTracker.where(old_model_name: 'step', old_model_id: export[:_id]).first
      it.nil? ? create_step(export) :
              compare_and_update_step(it, export)
    end
    message('INFO', "Complete: #{exports.count} Steps processed")
  end

  def create_step(export)
    # Quiz _id: 153, sequence_number: 8, topic_id: 24, name: "Quiz: Commodities", description: nil, _slugs: ["quiz-commodities-1"], _type: "Quiz", number_of_questions: 10>
    cm_it = ImportTracker.where(old_model_name: 'topic', old_model_id: export[:topic_id], new_model_name: 'course_module').first
    cm = CourseModule.find(cm_it.new_model_id)
    if export[:_type] == 'Quiz'
      cme = CourseModuleElement.where(is_quiz: true, name: export[:name], course_module_id: cm.id).first
    elsif export[:_type] == 'Video'
      cme = CourseModuleElement.where(is_video: true, name: export[:name], course_module_id: cm.id).first
    end
    if cme
      cme.update_attributes!(sorting_order: export[:sequence_number]) if cme
      it = ImportTracker.create!(
            old_model_name: 'step', old_model_id: export[:_id],
            new_model_name: 'course_module_element', new_model_id: cme.id,
            imported_at: Time.now,
            original_data: export.to_json
      )
      message('INFO', "-- export:step #{export[:_id]} imported to CourseModuleElement #{cme.id} it:id #{it.id}.")
    else
      message('ERROR', "-- export: step #{export[:_id]} could not be imported: #{export.inspect}")
    end
  end

  def compare_and_update_step(it, export)
    # Quiz _id: 153, sequence_number: 8, topic_id: 24, name: "Quiz: Commodities", description: nil, _slugs: ["quiz-commodities-1"], _type: "Quiz", number_of_questions: 10>
    cme = CourseModuleElement.find(it.new_model_id)
    unless cme.sorting_order == export[:sequence_number]
      cme.update_attributes(sorting_order: export[:sequence_number])
      it.touch
      message('INFO', "-- export: step #{export[:_id]} UPDATED CourseModuleElement #{cme.id}")
    end
  end

  def migrate_topics(exports)
    # sample = {:_slugs=>["easy-topic"], :name=>"Easy Topic",
    #           :description=>"This is the easiest topic ever!", :sequence_number=>1,
    #           :course_id=>1, :_id=>1}

    message('INFO', 'Starting to process Topics...')
    exports.each do |export|
      it = ImportTracker.where(old_model_name: 'topic', old_model_id: export[:_id]).first
      it.nil? ? create_topic(export) :
              compare_and_update_topic(it, export)
    end
    message('INFO', "Complete: #{exports.count} Topics processed")
  end

  def create_topic(export)
    es_it = ImportTracker.where(old_model_name: 'course', old_model_id: export[:course_id]).first
    es = ExamSection.find(es_it.new_model_id)
    cm = CourseModule.where(name: export[:name], exam_section_id: es.id).first_or_initialize
    cm.assign_attributes( # name: export[:name], exam_section_id: es.id,
            name_url: export[:name].downcase,
            description: export[:description],
            sorting_order: export[:sequence_number],
            institution_id: INSTITUTION_ID,
            qualification_id: QUALIFICATION_ID,
            exam_level_id: EXAM_LEVEL_ID,
            tutor_id: TUTOR_ID,
            active: es.active
    )
    cm.save!
    it = ImportTracker.create!(
            old_model_name: 'topic', old_model_id: export[:_id],
            new_model_name: 'course_module', new_model_id: cm.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    message('INFO', "-- export:topic #{export[:_id]} imported to CourseModule #{cm.id} it:id #{it.id}.")
  end

  def compare_and_update_topic(it, export)
    cm = CourseModule.find(it.new_model_id)
    es_it = ImportTracker.where(old_model_name: 'course', old_model_id: export[:course_id]).first
    es = ExamSection.find(es_it.new_model_id)
    if cm.updated_at > (it.updated_at + 10.seconds)
      message('WARN', "-- export:topic #{export[:_id]} UPDATED locally. Your changes may be lost during import - CourseModule #{cm.id} it:id #{it.id}.")
    end

    unless export[:name].squish == cm.name && cm.exam_section_id == es.id && cm.active == es.active
      cm.update_attributes!(
              name: export[:name],
              name_url: export[:name].downcase,
              exam_section_id: es.id,
              active: es.active
              # sorting_order: export[:sequence_number] -could be overwritten by Steps
      )
      it.touch
      message('WARN', "-- export:topic #{export[:_id]} UPDATED to CourseModule #{cm.id} it:id #{it.id}.")
    end
  end

  def migrate_videos(exports)
    # sample = {:_id=>1, :_slugs=>["theory-video"], :_type=>"Video", :duration=>330.12,
    #           :name=>"Theory video", :sequence_number=>1, :topic_id=>1, :type=>"theory",
    #           :url=>"http://view.vzaar.com/1983674"}
    # 'type' and 'url' are to be ignored.

    message('INFO', 'Starting to process Videos...')
    exports.each do |export|
      it = ImportTracker.where(old_model_name: 'video', old_model_id: export[:_id], new_model_name: 'course_module_element').first
      it.nil? ? create_video(export) :
              compare_and_update_video(it, export)
    end
    message('INFO', "processed #{exports.count} Videos")
  end

  def create_video(export)
    cm_it = ImportTracker.where(old_model_name: 'topic', old_model_id: export[:topic_id]).first
    cm    = CourseModule.find(cm_it.new_model_id)
    cme   = CourseModuleElement.where(name: export[:name], course_module_id: cm.id).first_or_initialize
    cme.assign_attributes( # name: export[:name], course_module_id: cm.id,
            name_url: export[:name].downcase,
            description: export[:name],
            estimated_time_in_seconds: export[:duration].to_i,
            sorting_order: export[:sequence_number],
            tutor_id: TUTOR_ID,
            ### todo: related_video_id: nil, # needs to be filled in later
            is_video: true,
            active: cm.exam_section.active
    )
    cme.save!

    # need to create a CME-video too, if one doesn't already exist
    cme_video  = CourseModuleElementVideo.where(course_module_element_id: cme.id).first_or_initialize
    cme_video.assign_attributes( # course_module_element_id: cme.id
            raw_video_file_id: RawVideoFile.first.id,
            tags: export[:type],
            difficulty_level: 'easy',
            estimated_study_time_seconds: export[:duration].to_i,
            transcript: 'Lorem ipsum'
    )
    cme_video.save!
    cme.update_attributes!(related_video_id: cme_video.id)

    # now, create two ImportTrackers
    it1 = ImportTracker.create!(
            old_model_name: 'video', old_model_id: export[:_id],
            new_model_name: 'course_module_element', new_model_id: cme.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    it2 = ImportTracker.create!(
            old_model_name: 'video', old_model_id: export[:_id],
            new_model_name: 'course_module_element_video', new_model_id: cme_video.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    message('INFO', "-- export:video #{export[:_id]} imported to CourseModuleElement #{cme.id} it:id #{it1.id}.")
    message('INFO', "-- export:video #{export[:_id]} imported to CourseModuleElementVideo #{cme_video.id} it:id #{it2.id}.")
  end

  def compare_and_update_video(it, export)
    cme = CourseModuleElement.find(it.new_model_id)
    unless cme.name == export[:name].squish && cme.description == export[:name].squish &&
              cme.estimated_time_in_seconds == export[:duration].to_i &&
              cme.sorting_order == export[:sequence_number]
      cme.update_attributes!(
              name: export[:name], # course_module_id: cm.id,
              name_url: export[:name].downcase,
              description: export[:name],
              estimated_time_in_seconds: export[:duration].to_i,
              sorting_order: export[:sequence_number],
              # tutor_id: TUTOR_ID,
              ### todo: related_video_id: nil, # needs to be filled in later
              is_video: true,
              # active: cm.exam_section.active
      )
      message('INFO', "-- export:video #{export[:_id]} UPDATED to CourseModuleElement #{cme.id} it:id #{it.id}.")
    end
    #### cme_video can't be adjusted once imported.
    #### Only the duration can be reset, and it is set by the parent CME.
    # cme_video = cme.course_module_element_video
    # unless cme_video.estimated_study_time_seconds == export[:duration].to_i
    #   cme_video.update_attributes!( # course_module_element_id: cme.id
    #         # raw_video_file_id: nil,
    #         # tags: export[:type],
    #         # difficulty_level: 'easy',
    #         estimated_study_time_seconds: export[:duration].to_i,
    #         # transcript: 'Lorem ipsum'
    #   )
    #   it2 = ImportTracker.where(new_model_name: 'course_module_element_video', new_model_id: cme_video.id).first
    #   it2.touch
    #   message('INFO', "-- export:video #{export[:_id]} UPDATED to CourseModuleElementVideo #{cme_video.id} it:id #{it2.id}.")
    # end
  end

  #### users

  def migrate_users(exports)
    message('INFO', 'Starting to process Users...')
    if exports
      exports.each do |export|
        # look in the import_tracker for this user
        it = ImportTracker.where(old_model_name: 'user', old_model_id: export[:_id]).first
        it.nil? ? create_user(export) :
                  compare_and_update_user(it, export)
      end
      message('INFO', "processed #{exports.count} users")
    else
      message('WARN', 'No users found')
    end
  end

  def create_user(export)
    it = ImportTracker.new
    dummy_password = "Pwd#{rand(99999999)}"
    country = Country.find_by_name(export[:billing_address][:country].to_s.gsub('United States of America', 'United States')) || Country.find_by_iso_code('IE')
    user_group = set_the_user_group(export[:role], export[:complimentary])

    ActiveRecord::Base.transaction do
      user = User.where(email: export[:email]).first_or_initialize( # email might already exist
              first_name: export[:first_name],
              last_name: export[:last_name],
              address: "#{export[:billing_address][:first_line]}\r\n#{export[:billing_address][:second_line]}\r\n#{export[:billing_address][:country]}",
              country_id: country.id,
              password: dummy_password,
              password_confirmation: dummy_password,
              account_activation_code: export[:confirmation_token],
              account_activated_at: (export[:confirmed_at].to_s.length > 5 ? Time.parse(export[:confirmed_at]) : nil),
              active: (export[:current_sign_in_at].to_s.length > 5),
              user_group_id: user_group.id,
              password_reset_requested_at: (export[:reset_password_sent_at] ? Time.parse(export[:reset_password_sent_at]) : nil),
              password_reset_token: export[:reset_password_token],
              password_reset_at: nil,
              stripe_customer_id: "v2v3-import-#{export[:_id]}",
              corporate_customer_id: nil,
              corporate_customer_user_group_id: nil,
              operational_email_frequency: 'off',
              study_plan_notifications_email_frequency: 'off',
              falling_behind_email_alert_frequency: 'off',
              marketing_email_frequency: 'off',
              marketing_email_permission_given_at: 'off',
              blog_notification_email_frequency: 'off',
              forum_notification_email_frequency: 'off',
              locale: 'en'
      )
      if user.id.nil? # only set these values if the user is new
        user.failed_login_count = 0
        user.last_request_at = nil
        user.login_count = export[:sign_in_count]
        user.current_login_at = (export[:current_sign_in_at].to_s.length > 5 ? Time.parse(export[:current_sign_in_at]) : nil)
        user.last_login_at = (export[:last_sign_in_at].to_s.length > 5 ? Time.parse(export[:last_sign_in_at]) : nil)
        user.current_login_ip = export[:current_sign_in_ip]
        user.last_login_ip = export[:last_sign_in_ip]
        user.send(:add_guid)
        user.save!(callbacks: false)
      end
      it = ImportTracker.create!(
              old_model_name: 'user',
              old_model_id: export[:_id],
              new_model_name: 'user',
              new_model_id: user.id,
              imported_at: Time.now,
              original_data: export.to_json
      )
      message('INFO', "-- export:user #{export[:_id]} imported as User #{user.id} it:id #{it.id}.")
    end

    # sample_exported_user = { #### indicates a field that is not imported
            # _id: 7,
            # billing_address: {
            #         first_line: "99 Calumet street, Apt.2\r\nRoxbury Crossing",
            #         second_line: '',
            #         country: 'United States of America',
            #         _id: 424
            # },
            #### business_name: '',
            #### complimentary: false,
            #### confirmation_sent_at: '2014-08-04T15:42:42.495Z',
            # confirmation_token: 'b6ec0e034d46ba3d06b5f16984133183daac48bc51d2cf7c307062177e59d105',
            # confirmed_at: '2014-05-01T12:02:31.869Z',
            # current_sign_in_at: '2014-10-09T07:24:07.087Z',
            # current_sign_in_ip: '109.78.90.48',
            # email: 'philip@em38.com',
            #### encrypted_password: '$2a$10$OvBMaMnjmU8DON3VIhQBAePiuYsSiyqmDrs9DKplqQTafQxAAbmsO',
            # first_name: 'Philip',
            #### forum_username: 'lily',
            # last_name: 'Meagher',
            # last_sign_in_at: '2014-09-22T20:44:38.546Z',
            # last_sign_in_ip: '188.141.95.233',
            #### remember_created_at: nil,
            # reset_password_sent_at: nil,
            # reset_password_token: nil,
            # role: 'student',
            # sign_in_count: 11,
            #### unconfirmed_email: 'lily@bissett.net'
    # }
  rescue => e
    message('ERROR', "rake v2v3:import_data#create_user - transaction rolled back. ImportTracker: #{try(:it).try(:errors).try(:inspect)}. User: #{try(:user).try(:errors).inspect}.  Error: #{e.inspect}. Further processing of users halted.")
  end

  def compare_and_update_user(it, export)
    # find the user
    user = User.find(it.new_model_id)
    # compare the details
    if user.email == export[:email] &&
          (export[:current_sign_in_at].nil? || it.imported_at > (Time.parse(export[:current_sign_in_at]) + 5.seconds))
      # do nothing
    else
      ActiveRecord::Base.transaction do
        user.assign_attributes(
              email: export[:email],
              first_name: export[:first_name],
              last_name: export[:last_name],
              user_group_id: set_the_user_group(export[:role], export[:complimentary]).id,
              address: "#{export[:billing_address][:first_line]}\r\n#{export[:billing_address][:second_line]}\r\n#{export[:billing_address][:country]}",
        )
        user.login_count = export[:sign_in_count]
        if export[:current_sign_in_at].to_s.length > 5 && self.current_login_at > Time.parse(export[:current_sign_in_at])
          user.current_login_at = Time.parse(export[:current_sign_in_at])
          user.last_login_at = Time.parse(export[:last_sign_in_at]) if export[:last_sign_in_at].to_s.length > 5
          user.current_login_ip = export[:current_sign_in_ip]
          user.last_login_ip = export[:last_sign_in_ip]
        end
        user.save!
        it.update_attributes!(imported_at: Time.now, original_data: export.to_json)
      end
      message('INFO', "rake v2v3:import_data#update_user #{it.id} updated")
    end
  rescue => e
    message('ERROR', "rake v2v3:import_data#update_user - transaction rolled back. ImportTracker: #{it.errors.inspect}. User: #{user.errors.inspect}.  Error: #{e.inspect}. Further processing of users halted.")
    exit
  end

  #### users' content tracking

  def migrate_users_courses(exports)
    message('INFO', 'Starting to process UsersCourses...')
    if exports
      exports.each do |export|
        # look in the import_tracker for this user/course
        it = ImportTracker.where(old_model_name: 'users_course', old_model_id: export[:_id]).first
        it.nil? ? create_user_course(export) :
                compare_and_update_user_course(it, export)
      end
      message('INFO', "processed #{exports.count} users_courses")
    else
      message('WARN', 'No users_courses found')
    end
  end

  def create_user_course(export)
    ActiveRecord::Base.transaction do
      (export[:finished_step_ids] || []).each do |step_id|
        step_it = ImportTracker.where(
                old_model_name: 'step',
                old_model_id: step_id).first
        if step_it # exists
          cme = CourseModuleElement.find(step_it.new_model_id)
          the_user_id = ImportTracker.where(old_model_name: 'user',
                  old_model_id: export[:user_id].to_i).first.new_model_id
          cmeul = CourseModuleElementUserLog.create!(
                  course_module_element_id: cme.id,
                  user_id: the_user_id,
                  session_guid: "v2v3:import users-course-#{export[:_id]} / step #{step_id}",
                  element_completed: true,
                  time_taken_in_seconds: 0,
                  quiz_score_actual: cme.try(:course_module_element_quiz).try(:best_possible_score_first_attempt),
                  quiz_score_potential: cme.try(:course_module_element_quiz).try(:best_possible_score_first_attempt),
                  is_video: cme.is_video,
                  is_quiz: cme.is_quiz,
                  course_module_id: cme.course_module_id,
                  latest_attempt: true,
                  corporate_customer_id: nil,
                  course_module_jumbo_quiz_id: nil,
                  is_jumbo_quiz: false # didn't exist in v2
          )
          it = ImportTracker.create!(
                  old_model_name: 'users_course', old_model_id: export[:_id].to_i,
                  new_model_name: 'course_module_element_user_log',
                  new_model_id: cmeul.id,
                  imported_at: Time.now, original_data: export.to_json
          )
          message('INFO', "-- export:user_course #{export[:_id]} imported as CMEUL #{cmeul.id} and it:id #{it.id}.")
        end # of loop of "steps"
      end # of if
    end # of transaction
    sample_user_course = {
            _id: 1,
            course_id: 1,
            finished: false,
            finished_step_ids: [1, 3, 5, 12, 20, 6, 22, 4, 2, 9, 10, 7, 21, 23, 19, 18, 17, 16, 15, 36, 35, 37],
            first_unfinished_step_id: 24,
            last_access_date: '2014-07-23T16:13:09.154Z',
            percentage_completion: 58,
            user_id: 1
    }
  rescue => e
    message('ERROR', "rake v2v3:import_data#create_user_course - transaction rolled back. Export: #{export.inspect}. Step-ID: #{try(:step_id)}. ImportTracker: #{try(:it).try(:errors).try(:inspect)}. CMEUL: #{try(:cmeul).try(:errors).inspect}.  SET: #{try(:set).try(:errors).inspect}. Error: #{e.inspect}. Further processing of users_courses halted.")
    exit
  end

  def compare_and_update_user_course(it, export)
    if Time.parse(export[:last_access_date]) > (it.imported_at + 5.seconds)
      # We only care about two of export's attributes - finished_step_ids and last_access_date
      (export[:finished_step_ids] || []).each do |step_id|
        cme = CourseModuleElement.find(
                ImportTracker.where(old_model_name: 'step',
                        old_model_id: step_id).first.new_model_id)
        cmeul = CourseModuleElementUserLog.where(
                user_id: ImportTracker.where(old_model_name: 'user',
                         old_model_id: export[:user_id]).first.new_model_id,
                course_module_element_id: cme.id
        ).first_or_initialize(
                session_guid: "v2v3:import users-course-#{export[:_id]} / step #{step_id}",
                element_completed: true,
                time_taken_in_seconds: 0,
                quiz_score_actual: cme.try(:course_module_element_quiz).try(:best_possible_score_first_attempt),
                quiz_score_potential: cme.try(:course_module_element_quiz).try(:best_possible_score_first_attempt),
                is_video: cme.is_video,
                is_quiz: cme.is_quiz,
                course_module_id: cme.course_module_id,
                latest_attempt: true,
                corporate_customer_id: nil,
                course_module_jumbo_quiz_id: nil,
                is_jumbo_quiz: false # didn't exist in v2
        )
        if cmeul.id.nil?
          cmeul.save!
          new_it = ImportTracker.create!(
                old_model_name: 'users_course', old_model_id: export[:_id].to_i,
                new_model_name: 'course_module_element_user_log',
                new_model_id: cmeul.id,
                imported_at: Time.now, original_data: export.to_json
          )
          message('INFO', "-- export:user_course #{export[:_id]} imported an EXTRA CMEUL #{cmeul.id} and it:id #{new_it.id}.")
        end
      end

    else
      # no update required
    end
  rescue => e
    message('ERROR', "rake v2v3:import_data#compare_and_update_user_course - transaction rolled back. Export: #{export.inspect}. Step-ID: #{try(:step_id)}. ImportTracker: #{try(:it).try(:errors).try(:inspect)}. CMEUL: #{try(:cmeul).try(:errors).inspect}.  SET: #{try(:set).try(:errors).inspect}. Error: #{e.inspect}. Further processing of users_courses halted.")
  end

  #### financial items

  def migrate_customers(exports)
    message('INFO', 'Starting to process Customers...')
    if exports
      exports.each do |export|
        # look in the import_tracker for this customer
        it = ImportTracker.where(old_model_name: 'customer', old_model_id: export[:_id]).first
        it.nil? ? create_customer(export) :
                compare_and_update_customer(it, export)
      end
      message('INFO', "processed #{exports.count} customers")
    else
      message('WARN', 'No customers found')
    end
  end

  def create_customer(export)
    the_user = User.find(ImportTracker.where(old_model_name: 'user', old_model_id: export[:user_id]).first.new_model_id)
    the_user.update_column(:stripe_customer_id, export[:stripe_id])
    it = ImportTracker.create!(
            old_model_name: 'customer', old_model_id: export[:_id].to_i,
            new_model_name: 'user',
            new_model_id: the_user.id,
            imported_at: Time.now, original_data: export.to_json
    )
    message('INFO', "-- export:customer #{export[:_id]} imported into User #{the_user.id} and it:id #{it.id}.")

    customer_sample = {_id: 1, status: 'unpaid', user_id: 5,
            stripe_id: 'cus_4bz3HLniS9Y5wW'}
  rescue => e
    message('ERROR', "rake v2v3:import_data#create_customer - transaction rolled back. Export: #{export.inspect}. User: #{try(:the_user).inspect}. ImportTracker: #{try(:it).try(:errors).try(:inspect)}. Error: #{e.inspect}. Further processing of customers halted.")
    exit
  end

  def compare_and_update_customer(it, export)
    the_user = User.find(it.new_model_id)
    if it.imported_at > ((the_user.last_request_at || the_user.current_login_at || the_user.updated_at) + 5.seconds) && the_user.stripe_customer_id[0..3] != 'cus_'
      the_user.update_column(:stripe_customer_id, export[:stripe_id])
      it.update_column(:imported_at, Time.now)
      message('INFO', "-- export:customer #{export[:_id]} updated to User #{the_user.id} and it:id #{it.id}.")
    end
  rescue => e
    message('ERROR', "rake v2v3:import_data#compare_and_update_customer - transaction rolled back. Export: #{export.inspect}. User: #{try(:the_user).inspect}. ImportTracker: #{try(:it).try(:errors).try(:inspect)}. Error: #{e.inspect}. Further processing of customers halted.")
    exit
  end

  def migrate_plans(exports)
    message('INFO', 'Starting to process Plans...')
    if exports
      exports.each do |export|
        # look in the import_tracker for this plan
        it = ImportTracker.where(old_model_name: 'plan', old_model_id: export[:_id]).first
        it.nil? ? create_plan(export) :
                compare_and_update_plan(it, export)
      end
      message('INFO', "processed #{exports.count} plans")
    else
      message('WARN', 'No plans found')
    end
  end

  def create_plan(export)

    sample_plan = {
            currency: 'usd',
            interval: 'month',
            interval_count: 1,
            trial_period_days: 7,
            name: 'Monthly',
            amount: 1000,
            statement_description: 'Monthly',
            default: true,
            stripe_id: 'plan_XNbHlgQaOr1GN3QEp+YT',
            _id: 5
    }
  end

  def compare_and_update_plan(it_new_model_id, exported_data)
  end

  def migrate_subscriptions(exports)
    message('INFO', 'Starting to process Subscriptions...')
    if exports
      exports.each do |export|
        # look in the import_tracker for this subscription
        it = ImportTracker.where(old_model_name: 'subscription', old_model_id: export[:_id]).first
        it.nil? ? create_subscription(export) :
                compare_and_update_subscription(it.new_model_id, export)
      end
      message('INFO', "processed #{exports.count} subscriptions")
    else
      message('WARN', 'No subscriptions found')
    end
  end

  def create_subscription(exported_data)
    sample_subscription = {
            _id: 24,
            cancel_at_period_end: false,
            canceled_at: nil,
            current_period_end: '2014-09-24T17:04:32.000Z',
            current_period_start: '2014-09-17T17:04:32.000Z',
            customer_id: 79,
            ended_at: '2014-09-24T17:04:32.000Z',
            plan_id: 5,
            start: '2014-09-17T17:04:32.000Z',
            status: 'trialing',
            stripe_id: 'sub_4nMalNQsR7jLqn',
            user_id: 85
    }
  end

  def compare_and_update_subscription(it_new_model_id, exported_data)
  end

  #### General

  def aws_credentials
    Aws::Credentials.new(
            ENV['LEARNSIGNAL3_S3_ACCESS_KEY_ID'],
            ENV['LEARNSIGNAL3_S3_SECRET_ACCESS_KEY']
    )
  end

  def aws_read_file(s3, file_name)
    JSON.parse(s3.get_object(key: file_name, bucket: BUCKET).body.read, {symbolize_names: true})
  end

  def connect_to_s3
    Aws::S3::Client.new(credentials: aws_credentials, region: 'eu-west-1')
  end

  def message(level, content)
    puts content
    Rails.logger.debug "#{level.upcase} rake v2v3:import_data - #{content} at #{Time.now}"
  end

  def rename_source_and_finish(s3, file_name)
    destination_name = file_name + '-processed-' + Time.now.strftime('%Y%m%d-%H%M%S')
    s3.copy_object(bucket: BUCKET, copy_source: BUCKET + '/' + file_name, key: destination_name)
    s3.delete_object(bucket: BUCKET, key: file_name)

    puts ''
    message('INFO', "renamed file to #{destination_name}")
    message('INFO', 'DONE')
  end

  def set_the_user_group(the_role, complimentary)
    if the_role == 'student' && complimentary == false
      UserGroup.default_student_user_group
    elsif the_role == 'student' && complimentary == true
      UserGroup.default_complimentary_user_group
    elsif the_role == 'tutor'
      UserGroup.default_tutor_user_group
    elsif the_role == 'admin'
      UserGroup.default_admin_user_group
    else
      UserGroup.default_student_user_group
    end
  end

end


#### See
# http://ruby.awsblog.com/post/Tx354Y6VTZ421PJ/Downloading-Objects-from-Amazon-S3-using-the-AWS-SDK-for-Ruby
