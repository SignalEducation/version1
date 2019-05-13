# == Schema Information
#
# Table name: exercises
#
#  id                      :bigint(8)        not null, primary key
#  product_id              :bigint(8)
#  state                   :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint(8)
#  corrector_id            :bigint(8)
#  submission_file_name    :string
#  submission_content_type :string
#  submission_file_size    :bigint(8)
#  submission_updated_at   :datetime
#  correction_file_name    :string
#  correction_content_type :string
#  correction_file_size    :bigint(8)
#  correction_updated_at   :datetime
#  submitted_on            :datetime
#  corrected_on            :datetime
#  returned_on             :datetime
#

class Exercise < ApplicationRecord
  belongs_to :product
  belongs_to :user
  belongs_to :corrector, class_name: 'User', foreign_key: 'corrector_id', optional: true

  has_attached_file :submission, default_url: nil
  has_attached_file :correction, default_url: nil
  validates_attachment_content_type :submission,
    :correction, content_type: ['application/pdf', 'image/png', 'image/jpeg', 'image/jpg']

  # after_submission_post_process :submit
  # after_correction_post_process :return
  after_update :check_corrector

  # SCOPES =====================================================================

  scope :all_in_order, -> { order(created_at: :asc) }

  # STATE MACHINE ==============================================================

  state_machine initial: :pending do
    event :submit do
      transition pending: :submitted
    end

    event :correct do
      transition submitted: :correcting
    end

    event :return do
      transition correcting: :returned
    end

    after_transition pending: :submitted do |exercise, _transition|
      exercise.update_columns(submitted_on: Time.zone.now)
      # exercise.notify_submitted
    end

    after_transition submitted: :correcting do |exercise, _transition|
      exercise.update_columns(corrected_on: Time.zone.now)
    end

    after_transition correcting: :returned do |exercise, _transition|
      exercise.update_columns(returned_on: Time.zone.now)
      exercise.send_returned_email
    end
  end

  def send_returned_email
    MandrillWorker.perform_async(
      self.user_id,
      'send_correction_returned_email',
      Rails.application.routes.url_helpers.user_exercises_url(
        id: self.user_id,
        host: 'https://learnsignal.com'
      ),
      product.mock_exam.name
    )
  end

  def notify_submitted
    MandrillWorker.perform_async(
      self.user_id, 
      'send_exercise_submitted_email', 
      Rails.application.routes.url_helpers.account_url(
        host: 'https://learnsignal.com'
      ), 
      product.mock_exam.name, 
      product.mock_exam.file, 
      self.reference_guid
    )
  end

  private

  def check_corrector
    self.correct if corrector_id_previously_changed?
  end
end
