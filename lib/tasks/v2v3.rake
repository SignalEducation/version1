# To extract data from v2:
# production --- $ heroku run rake v2v3:export_data --app production-learnsignal
# staging ------ # heroku run rake v2v3:export_data --app signaleducation

namespace :v2v3 do

  BUCKET = 'learnsignal3-data-migration'

  desc 'Import data from v2 website'
  task(import_data: :environment) do
    # USAGE: rake v2v3:import_data {optional_file_name.json}

    #### Find the data file and import it into a hash
    source_file = ARGV[1] || 'v2_data.json'
    s3 = connect_to_s3

    #### set up the anestry for Finance / CFA / CFA Professional / Level 1
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

    puts
    puts 'rake v2v3:import_data'
    puts '---------------------'

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
    migrate_users(migrate_data[:users])
    migrate_users_courses(migrate_data[:users_courses])
    # migrate_courses(migrate_data[:courses])
    # migrate_courses(migrate_data[:courses])
    # migrate_courses(migrate_data[:courses])
    # migrate_courses(migrate_data[:courses])
    # migrate_courses(migrate_data[:courses])
    # migrate_courses(migrate_data[:courses])
    # migrate_courses(migrate_data[:courses])
    # migrate_courses(migrate_data[:courses])
    # migrate_courses(migrate_data[:courses])

    #### Rename the source file, and finish.
    rename_source_and_finish(s3, source_file)
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
                sorting_order: export[:sequence] || 1
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
    end
    if Time.parse(export[:updated_at]) > it.updated_at
      es.update_attributes!(
              name: export[:name].split(' - Level 1')[0],
              name_url: export[:name].split(' - Level 1')[0].downcase,
              active: (export[:status] == 'published'),
              sorting_order: export[:sequence]
      )
      it.touch
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
    message('INFO', "Complete: #{exports.count} Videos processed")
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

  #### users and financial items

  def migrate_users(exports)
    message('INFO', 'Starting to process Users...')
    if exports
      exports.each do |export|
        # look in the import_tracker for this user
        it = ImportTracker.where(old_model_name: 'user', old_model_id: export[:_id]).first
        it.nil? ? create_user(export) :
                  compare_and_update_user(it.new_model_id, export)
      end
      message('INFO', "processed #{exports.count} users")
    else
      message('WARN', 'No users found')
    end
  end

  def compare_and_update_user(existing_user_id, exported_user) # todo
    # compare the details
    # if import_tracker.user.first_name == exported_user[:first_name] ...
    #         more comparisons
    #   # do nothing
        print '.'
    # else
    #   import_tracker_user.update_attributes!(
    #         email: exported_user[:email],
    #         first_name: exported_user[:first_name],
    #         etc..
    #   )
        print 'U'
    #   Rails.logger.info "INFO rake v2v3:import_json - user #{import_tracker_user.id} updated"
    # end
  end

  def create_user(exported_user) # todo
    # Create the User
    # user = User.create!(
    #       email: exported_user[:email],
    #       first_name: exported_user[:first_name],
    #       etc.
    # )
    # Create an ImportTracker record
    # it = ImportTracker.create!(
    #         old_model_name: 'user',
    #         old_model_id: exported_user[:id],
    #         new_model_name: 'user',
    #         new_model_id: user.id,
    #         imported_at: Time.now,
    #         original_data: exported_user
    # )
    # Rails.logger.info "INFO rake v2v3:import_data - Created user: old ID:#{it.old_model_id}, new ID:#{it.new_model_id}, import tracker ID:#{it.id}."
  end

  #### users' content tracking

  def migrate_users_courses(imports)
    #
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

end


#### See
# http://ruby.awsblog.com/post/Tx354Y6VTZ421PJ/Downloading-Objects-from-Amazon-S3-using-the-AWS-SDK-for-Ruby
