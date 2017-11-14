class CsvImportUserCreationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(email, first_name, last_name, root_url)
    User.create_csv_user(email, first_name, last_name, root_url)
  end

end
