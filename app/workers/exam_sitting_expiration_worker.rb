class ExamSittingExpirationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(exam_sitting_id)
    sitting = ExamSitting.find(exam_sitting_id)
    if sitting && sitting.date
      sitting.update_attribute(:active, false)
    end
  end

end
