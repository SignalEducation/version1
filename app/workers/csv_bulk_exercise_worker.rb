# frozen_string_literal: true

class CsvBulkExerciseWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(u_id, product_id)
    user = User.find(u_id)
    user.exercises.create(product_id: product_id)
  end
end
