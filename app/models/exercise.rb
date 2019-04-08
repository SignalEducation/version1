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
#

class Exercise < ApplicationRecord
  belongs_to :product
  belongs_to :user
  belongs_to :corrector, optional: true

  has_attached_file :submission, default_url: nil
  has_attached_file :correction, default_url: nil
  validates_attachment_content_type :submission,
    :correction, content_type: 'application/pdf'

  after_submission_post_process :submit
  after_correction_post_process :return

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
      # email the user to confirm
      # email the correctors
    end

    after_transition submitted: :correcting do |exercise, _transition|
      # no need to do anything here, just to show the other correctors that it
      # is in progress
    end

    after_transition correcting: :returned do |exercise, _transition|
      # email the user to say their corrections are available
    end
  end
end
