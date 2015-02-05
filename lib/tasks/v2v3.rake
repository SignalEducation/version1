namespace :v2v3 do

  desc 'Import data from v2 website'
  task(import_data: :environment) do
    # USAGE: rake v2v3:import_data {optional_file_name.json}

    #### Find the data file and import it into a hash
    source_file = ARGV[1] || 'tmp/v2_data.json'
    Rails.logger.info "INFO rake v2v3:import_data - Starting to read file: #{source_file} at #{Time.now}"
    puts 'rake v2v3:import_data'
    puts '---------------------'
    puts "Loading data from: #{source_file}"
    migrate_data = JSON.parse(File.read(source_file), symbolize_names: true)

    #### Process the data
    migrate_users(migrate_data[:users])

    #### Rename the source file, and finish.
    rename_source_and_finish(source_file)
  end

  #### courses



  #### users

  def migrate_users(exported_users)
    print '- Users: '
    if exported_users
      exported_users.each do |exported_user|
        # look in the import_tracker for this user
        it = ImportTracker.where(old_model_name: 'user', old_model_id: exported_user[:id]).first
        it.nil? ? create_user(exported_user) :
                  compare_and_update_user(it.user, exported_user)
      end
      Rails.logger.info "INFO rake v2v3:import_data - processed #{exported_users.count} users"
      puts ''
    else
      puts 'None found'
      Rails.logger.warn 'WARN rake v2v3:import_data NO USERS FOUND'
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
    print 'C'
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

  def rename_source_and_finish(source_file)
    destination_name = source_file + '-processed-' + Time.now.strftime('%Y%m%d-%H%M%S')
    system("mv #{source_file} #{destination_name}")
    puts ''
    Rails.logger.info "INFO rake v2v3:import_data - renamed file to #{destination_name}"
    puts "Source file renamed to #{destination_name}"
    Rails.logger.info "INFO rake v2v3:import_data - complete at #{Time.now}"
    puts 'DONE'
  end
end

# sample data:
# {"users":[{"id":1,"first_name":"John","last_name":"Murphy"}],"user_groups":[{"id":1,"name":"Students"},{"id":2,"Name":"Admins"}]}

