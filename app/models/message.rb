# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id                    :bigint           not null, primary key
#  user_id               :integer
#  opens                 :integer
#  clicks                :integer
#  kind                  :integer          default("0"), not null
#  process_at            :datetime
#  template              :string
#  mandrill_id           :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  state                 :string
#  template_params       :hstore
#  guid                  :string
#  onboarding_process_id :integer
#
class Message < ApplicationRecord
  # enums
  enum kind: { general: 0, onboarding: 1, account: 2 }

  STATES = %w[sent rejected spam unsub bounced soft_bounced].freeze

  # relationships
  belongs_to :user
  belongs_to :onboarding_process, optional: true

  validates :user_id, presence: true
  validates :kind, inclusion: { in: Message.kinds.keys }, presence: true
  validates :state, inclusion: { in: Message::STATES }, on: :update
  validates :state, presence: true, on: :update
  validates :process_at, presence: true
  validates :template, presence: true
  validates :mandrill_id, presence: true, on: :update

  # callbacks
  before_create :set_guid
  after_create_commit :send_message

  # scopes
  scope :day_1, -> { where(template: 'send_onboarding_content_email').where("template_params -> 'day' = ?", '1') }
  scope :day_2, -> { where(template: 'send_onboarding_content_email').where("template_params -> 'day' = ?", '2') }
  scope :day_3, -> { where(template: 'send_onboarding_content_email').where("template_params -> 'day' = ?", '3') }
  scope :day_4, -> { where(template: 'send_onboarding_content_email').where("template_params -> 'day' = ?", '4') }
  scope :day_5, -> { where(template: 'send_onboarding_content_email').where("template_params -> 'day' = ?", '5') }
  scope :sent_last_week,  -> { where(process_at: 1.week.ago.beginning_of_week...1.week.ago.end_of_week) }
  scope :sent_this_week,  -> { where(process_at: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week) }
  scope :sent_this_month, -> { where(process_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month) }

  def self.process_webhook_event(event)
    msg = Message.find_by(mandrill_id: event['_id'])

    return unless msg

    opens = event['msg']['opens'].count if event['msg']['opens']
    clicks = event['msg']['clicks'].count if event['msg']['clicks']

    msg.update(state: event['msg']['state'],
               opens: opens,
               clicks: clicks)
    msg
  end

  def self.get_and_unsubscribe(message_guid)
    return unless (msg = Message.find_by(guid: message_guid))

    msg.user.onboarding_process.update(active: false) if msg.kind == 'onboarding'
    msg
  end

  def unsubscribe_url
    UrlHelper.instance.unsubscribe_url(message_guid: guid, host: LEARNSIGNAL_HOST) if kind == 'onboarding'
  end

  def self.to_csv(options = {}, attributes = %w[id user_id opens clicks state day course subject_line utm_content utm_source utm_term study_visit paid_within_24])
    CSV.generate(options) do |csv|
      csv << attributes

      find_each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  def day
    template_params['day']
  end

  def course
    template_params['course_name'] ? template_params['course_name'] : template_params['course']
  end

  def subject_line
    template_params['subject_line']
  end

  def utm_medium
    params_hash = Rack::Utils.parse_query URI(template_params['url']).query
    params_hash['utm_medium']
  end

  def utm_campaign
    params_hash = Rack::Utils.parse_query URI(template_params['url']).query
    params_hash['utm_campaign']
  end

  def utm_content
    params_hash = Rack::Utils.parse_query URI(template_params['url']).query
    params_hash['utm_content']
  end

  def utm_source
    params_hash = Rack::Utils.parse_query URI(template_params['url']).query
    params_hash['utm_source']
  end

  def utm_term
    params_hash = Rack::Utils.parse_query URI(template_params['url']).query
    params_hash['utm_term']
  end

  def paid_within_24
    user.viewable_subscriptions.where(created_at: process_at..(process_at + 24.hours)).any?
  end

  def payment_visit
    visits = Ahoy::Visit.where(landing_page: template_params['url'], user_id: user_id)
    payment_visits = visits.map(&:subscription).reject { |item| item.blank? }
    payment_visits.any?
  end

  def study_visit
    visits = Ahoy::Visit.where(landing_page: template_params['url'], user_id: user_id)
    study_visits = visits.map(&:study_visit?)
    study_visits.any?
  end

  protected

  def send_message
    MandrillWorker.perform_at(process_at, id) unless Rails.env.test?
  end

  def set_guid
    self.guid = SecureRandom.hex(15)
  end
end
