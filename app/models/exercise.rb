# frozen_string_literal: true

# == Schema Information
#
# Table name: exercises
#
#  id                      :bigint           not null, primary key
#  product_id              :bigint
#  state                   :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint
#  corrector_id            :bigint
#  submission_file_name    :string
#  submission_content_type :string
#  submission_file_size    :bigint
#  submission_updated_at   :datetime
#  correction_file_name    :string
#  correction_content_type :string
#  correction_file_size    :bigint
#  correction_updated_at   :datetime
#  submitted_on            :datetime
#  corrected_on            :datetime
#  returned_on             :datetime
#  order_id                :bigint
#

class Exercise < ApplicationRecord
  include Filterable
  belongs_to :product
  belongs_to :order, optional: true
  belongs_to :user, inverse_of: :exercises
  belongs_to :corrector, class_name: 'User', foreign_key: 'corrector_id', optional: true, inverse_of: :exercises

  has_one :cbe_user_log, class_name: 'Cbe::UserLog', dependent: :destroy, inverse_of: :exercise

  has_attached_file :submission, default_url: nil
  has_attached_file :correction, default_url: nil
  validates_attachment_content_type :submission,
                                    :correction,
                                    content_type: ['application/pdf', 'image/png', 'image/jpeg', 'image/jpg']

  after_update :check_corrector

  # SCOPES =====================================================================

  search_scope :state, lambda { |state|
    state == 'all' ? where.not(state: nil) : where(state: state)
  }
  search_scope :product, ->(product_id) { where product_id: product_id }
  search_scope :corrector, ->(corrector_id) { where(corrector_id: corrector_id) }
  search_scope :search, lambda { |term|
    joins(:user).where(
      "users.email ILIKE :t OR users.first_name ILIKE :t OR users.last_name
      ILIKE :t OR textcat(users.first_name, textcat(text(' '), users.last_name))
      ILIKE :t", t: "%#{term}%"
    )
  }

  scope :all_in_order, -> { order(created_at: :asc) }
  scope :live, -> { with_states(%w[submitted correcting returned]) }

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
      exercise.update(submitted_on: Time.zone.now)

      SlackNotificationWorker.perform_async(:exercise, exercise.id, :notify_submitted)
    end

    after_transition submitted: :correcting do |exercise, _transition|
      exercise.update(corrected_on: Time.zone.now)
    end

    after_transition correcting: :returned do |exercise, _transition|
      exercise.update(returned_on: Time.zone.now)
      exercise.correction_returned_email
    end
  end

  # CLASS METHODS ==============================================================

  def self.bulk_create(csv_data, product_id)
    new_exercises = []
    transaction do
      csv_data['user_id'].each_with_index do |u_id, idx|
        CsvBulkExerciseWorker.perform_async(u_id, product_id)
        new_exercises << { email: csv_data['email'][idx] }
      end
    end

    new_exercises
  end

  def self.parse_csv(csv_content)
    users = []
    has_errors = false

    CSV.new(csv_content, headers: true).each do |row|
      unless (user = User.find_by(email: row['email']))
        user = OpenStruct.new({ email: row['email'], errors: ['do not exist'] })
        has_errors = true
      end

      users << user
    end

    [users, has_errors]
  end

  def self.search(term)
    joins(:user).where(
      "users.email ILIKE :t OR users.first_name ILIKE :t OR users.last_name ILIKE :t OR textcat(users.first_name, textcat(text(' '), users.last_name)) ILIKE :t", t: "%#{term}%"
    )
  end

  # INSTANCE METHODS ===========================================================
  def notify_submitted
    send_submitted_slack_message
  end

  def correction_returned_email
    Message.create(
      process_at: Time.zone.now,
      user_id: user_id,
      kind: :account,
      template: 'send_correction_returned_email',
      template_params: {
        url: UrlHelper.instance.user_exercises_url(user_id: user_id, host: LEARNSIGNAL_HOST),
        product_name: product.name_by_type
      }
    )
  end

  private

  def check_corrector
    correct if corrector_id_previously_changed?
  end

  def send_submitted_slack_message
    attachments = [{
      fallback: "#{user.name} uploaded an exercise. - #{UrlHelper.instance.admin_exercises_url(host: LEARNSIGNAL_HOST)}",
      title: "<#{UrlHelper.instance.admin_exercises_url(host: LEARNSIGNAL_HOST)}|#{user.name}> - uploaded an exercise.",
      title_link: UrlHelper.instance.admin_exercises_url(host: LEARNSIGNAL_HOST).to_s,
      color: '#7CD197',
      fields: [{
        title: product.mock_exam? ? 'Mock Exam' : 'General Correction',
        value: product.name,
        short: true
      }]
    }]
    SlackService.new.notify_channel('corrections', attachments)
  end

  def send_submitted_email
    Message.create(
      process_at: Time.zone.now,
      user_id: user_id,
      kind: :account,
      template: 'send_exercise_submitted_email',
      template_params: {
        url: UrlHelper.instance.account_url(host: LEARNSIGNAL_HOST),
        product_name: product.mock_exam.name,
        file: product.mock_exam.file,
        reference_guid: reference_guid
      }
    )
  end
end
