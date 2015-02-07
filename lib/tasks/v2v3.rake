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
    message('INFO', "Loading data from: #{source_file}")
    migrate_data = aws_read_file(s3, source_file)

    #### Process the data
    # course content
    migrate_courses(migrate_data[:courses]) # done
    migrate_topics(migrate_data[:topics]) # done
    migrate_videos(migrate_data[:videos]) # -wip
    migrate_quizzes(migrate_data[:quizzes])
    migrate_steps(migrate_data[:steps])
    migrate_questions(migrate_data[:questions])
    migrate_answers(migrate_data[:answers])
    migrate_resources(migrate_data[:resources])
    migrate_markdown_images(migrate_data[:markdown_images])
    migrate_notes(migrate_data[:notes])

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
    ####
  end

  def migrate_courses(exports)
    # sample = {:_id=>1, :_slugs=>["first-course"], :created_at=>"2014-08-11T12:14:38.919Z",
    #           :description=>"Sample course with simple topics!", :has_steps=>true,
    #           :name=>"First Course", :sequence_number=>1, :status=>"published",
    #           :updated_at=>"2014-08-11T12:14:38.919Z"}

    exports.each do |export|
      it = ImportTracker.where(old_model_name: 'course', old_model_id: export[:_id]).first
      it.nil? ? create_course(export) :
                compare_and_update_course(it, export)
    end
    message('INFO', "Complete: #{exports.count} Courses processed")
  end

  def create_course(export)
    es = ExamSection.where(name: export[:name].split(' - Level 1')[0]).first
    unless es
      es = ExamSection.create!(exam_level_id: EXAM_LEVEL_ID,
                           qualification_id: QUALIFICATION_ID,
                           institution_id: INSTITUTION_ID,
                           subject_area_id: SUBJECT_AREA_ID,
                           name: export[:name].split(' - Level 1')[0],
                           name_url: export[:name].split(' - Level 1')[0].downcase,
                           active: export[:status] == 'published',
                           sorting_order: export[:sequence] || 1
      )
    end
    it = ImportTracker.create!(
                old_model_name: 'course', old_model_id: export[:_id],
                new_model_name: 'exam_section', new_model_id: es.id,
                imported_at: Time.now,
                original_data: export.to_json
    )
    message('INFO', "export:course #{export[:_id]} imported to ExamSection #{es.id} it:id #{it.id}.")
  end

  def compare_and_update_course(it, export)
    es = ExamSection.find(it.new_model_id)
    if es.updated_at > it.updated_at
      message('WARN', "export:course #{export[:_id]} UPDATED locally. Your changes may be lost during import - ExamSection #{es.id} it:id #{it.id}.")
    end
    if Time.parse(export[:updated_at]) > it.updated_at
      es.update_attributes(
              name: export[:name].split(' - Level 1')[0],
              name_url: export[:name].split(' - Level 1')[0].downcase,
              active: export[:status] == 'published',
              sorting_order: export[:sequence]
      )
      it.touch
      message('WARN', "export:course #{export[:_id]} UPDATED to ExamSection #{es.id} it:id #{it.id}.")
    end
  end

  def migrate_markdown_images(exports)
    ####
  end

  def migrate_notes(exports)
    ####
  end

  def migrate_questions(exports)
    ####
  end

  def migrate_quizzes(exports)
    ####
  end

  def migrate_resources(exports)
    ####
  end

  def migrate_steps(exports)
    ####
  end

  def migrate_topics(exports)
    # sample = {:_slugs=>["easy-topic"], :name=>"Easy Topic",
    #           :description=>"This is the easiest topic ever!", :sequence_number=>1,
    #           :course_id=>1, :_id=>1}

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
    cm = CourseModule.create!(
            name: export[:name], name_url: export[:name].downcase,
            description: export[:description],
            sorting_order: export[:sequence_number],
            institution_id: INSTITUTION_ID,
            qualification_id: QUALIFICATION_ID,
            exam_level_id: EXAM_LEVEL_ID,
            exam_section_id: es.id,
            tutor_id: TUTOR_ID,
            active: es.active
    )
    it = ImportTracker.create!(
            old_model_name: 'topic', old_model_id: export[:_id],
            new_model_name: 'course_module', new_model_id: cm.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    message('INFO', "export:topic #{export[:_id]} imported to CourseModule #{cm.id} it:id #{it.id}.")
  end

  def compare_and_update_topic(it, export)
    cm = CourseModule.find(it.new_model_id)
    es_it = ImportTracker.where(old_model_name: 'course', old_model_id: export[:course_id]).first
    es = ExamSection.find(es_it.new_model_id)
    if cm.updated_at > it.updated_at
      message('WARN', "export:topic #{export[:_id]} UPDATED locally. Your changes may be lost during import - CourseModule #{cm.id} it:id #{it.id}.")
    end

    unless export[:name] == cm.name && export[:sequence_number] == cm.sorting_order && cm.exam_section_id == es.id && cm.active == (export[:status] == 'published')
      cm.update_attributes(
              name: export[:name],
              name_url: export[:name].downcase,
              exam_section_id: es.id,
              active: export[:status] == 'published',
              sorting_order: export[:sequence_number]
      )
      it.touch
      message('WARN', "export:topic #{export[:_id]} UPDATED to CourseModule #{cm.id} it:id #{it.id}.")
    end
  end

  def migrate_videos(exports)
    # sample = {:_id=>1, :_slugs=>["theory-video"], :_type=>"Video", :duration=>330.12,
    #           :name=>"Theory video", :sequence_number=>1, :topic_id=>1, :type=>"theory",
    #           :url=>"http://view.vzaar.com/1983674"}
    # 'type' and 'url' are to be ignored.
    exports.each do |export|
      it = ImportTracker.where(old_model_name: 'video', old_model_id: export[:_id]).first
      it.nil? ? create_video(export) :
              compare_and_update_video(it, export)
    end
    message('INFO', "Complete: #{exports.count} Videos processed")
    ####
  end

  def create_video(export)
    cm_it = ImportTracker.where(old_model_name: 'course_module', old_model_id: export[:topic_id]).first
    cm = CourseModule.find(cm_it.new_model_id)
    cme = CourseModuleElement.create!(
            name: export[:name], name_url: export[:name].downcase,
            # description: export[:description],
            # sorting_order: export[:sequence_number],
            # institution_id: INSTITUTION_ID,
            # qualification_id: QUALIFICATION_ID,
            # exam_level_id: EXAM_LEVEL_ID,
            # exam_section_id: es.id,
            # tutor_id: TUTOR_ID,
            # active: es.active
    )
    cmev = CourseModuleElementVideo.create!(
            name: export[:name], name_url: export[:name].downcase,
            # description: export[:description],
            # sorting_order: export[:sequence_number],
            # institution_id: INSTITUTION_ID,
            # qualification_id: QUALIFICATION_ID,
            # exam_level_id: EXAM_LEVEL_ID,
            # exam_section_id: es.id,
            # tutor_id: TUTOR_ID,
            # active: es.active
    )
    it = ImportTracker.create!(
            old_model_name: 'video', old_model_id: export[:_id],
            new_model_name: 'course_module_element', new_model_id: cme.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    it = ImportTracker.create!(
            old_model_name: 'video', old_model_id: export[:_id],
            new_model_name: 'course_module_element_video', new_model_id: cmev.id,
            imported_at: Time.now,
            original_data: export.to_json
    )
    message('INFO', "export:video #{export[:_id]} imported to CourseModuleElement #{cme.id} it:id #{it.id}.")
    message('INFO', "export:video #{export[:_id]} imported to CourseModuleElementVideo #{cmev.id} it:id #{it.id}.")

    ####
  end

  def compare_and_update_video(it, export)
    ####
  end

  #### users and financial items

  def migrate_users(exports)
    message('INFO', 'Starting to import users')
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
    #   import_tracker_user.update_attributes(
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
    # s3.copy_object(bucket: BUCKET, copy_source: BUCKET + '/' + file_name, key: destination_name)
    # s3.delete_object(bucket: BUCKET, key: file_name)

    puts ''
    message('INFO', "renamed file to #{destination_name}")
    message('INFO', 'DONE')
  end

end


#### See
# http://ruby.awsblog.com/post/Tx354Y6VTZ421PJ/Downloading-Objects-from-Amazon-S3-using-the-AWS-SDK-for-Ruby
