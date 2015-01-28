namespace :v2v3 do

  desc 'Import data from v2 website'
  task :import_json do
    # USAGE: rake v2v3:import_json
    puts  'Loading v2 data from: '
    print '- '

    var = File.read('tmp/testfile.json')
    var2 = JSON.parse(var, symbolize_names: true)
    var2[:users].each do |user|
      print user[:id]
    end

    puts
    puts 'DONE'
  end

end

# sample data:
# {"users":[{"id":1,"first_name":"John","last_name":"Murphy"}],"user_groups":[{"id":1,"name":"Students"},{"id":2,"Name":"Admins"}]}

