namespace :v2v3 do

  BUCKET = 'learnsignal3-data-migration'

  desc 'Import data from v2 website'
  task(import_data: :environment) do
    # USAGE: rake v2v3:import_data {optional_file_name.json}

    #### Find the data file and import it into a hash
    source_file = ARGV[1] || 'v2_data.json'
    s3 = connect_to_s3
    puts 'rake v2v3:import_data'
    puts '---------------------'
    message('INFO', "Loading data from: #{source_file}")
    migrate_data = aws_read_file(s3, source_file)

    #### Process the data
    migrate_users(migrate_data[:users])

    #### Rename the source file, and finish.
    rename_source_and_finish(s3, source_file)
  end

  #### courses



  #### users

  def migrate_users(exported_users)
    message('INFO', 'Starting to import users')
    if exported_users
      exported_users.each do |exported_user|
        # look in the import_tracker for this user
        it = ImportTracker.where(old_model_name: 'user', old_model_id: exported_user[:id]).first
        it.nil? ? create_user(exported_user) :
                  compare_and_update_user(it.user, exported_user)
      end
      message('INFO', "processed #{exported_users.count} users")
    else
      message('WARN', 'No users found')
    end
  end

  def compare_and_update_user(import_tracker_user, exported_user) # todo
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
    Rails.logger.debug "#{level.upcase} rake v2v3:import_data - #{message} at #{Time.now}"
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

# sample data:
# {"users":[{"id":1,"first_name":"John","last_name":"Murphy"}],"user_groups":[{"id":1,"name":"Students"},{"id":2,"Name":"Admins"}]}

#### See
# http://ruby.awsblog.com/post/Tx354Y6VTZ421PJ/Downloading-Objects-from-Amazon-S3-using-the-AWS-SDK-for-Ruby
