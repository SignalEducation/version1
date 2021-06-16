class CsvImportUserCreationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(email, first_name, last_name, preferred_exam_body_id, user_group_id, root_url)
    User.create_csv_user(email, first_name, last_name, preferred_exam_body_id, user_group_id, root_url)
  end
end
