# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id              :bigint           not null, primary key
#  user_id         :integer
#  opens           :integer
#  clicks          :integer
#  kind            :integer          default("0"), not null
#  process_at      :datetime
#  template        :string
#  mandrill_id     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  state           :string
#  template_params :hstore
#
class Message < ApplicationRecord
  # enums
  enum kind: { general: 0, onboarding: 1, account: 2 }

  STATES = %w[sent rejected spam unsub bounced soft_bounced].freeze

  # relationships
  belongs_to :user

  validates :user_id, presence: true
  validates :kind, inclusion: { in: Message.kinds.keys }, presence: true
  validates :state, inclusion: { in: Message::STATES }, on: :update
  validates :state, presence: true, on: :update
  validates :process_at, presence: true
  validates :template, presence: true
  validates :mandrill_id, presence: true, on: :update

  # callbacks
  after_create :send_message

  # scopes
  scope :day_1, -> { where(template: 'send_onboarding_content_email').where("template_params -> 'day' = ?", '1') }
  scope :day_2, -> { where(template: 'send_onboarding_content_email').where("template_params -> 'day' = ?", '1') }
  scope :day_3, -> { where(template: 'send_onboarding_content_email').where("template_params -> 'day' = ?", '1') }
  scope :day_4, -> { where(template: 'send_onboarding_content_email').where("template_params -> 'day' = ?", '1') }
  scope :day_5, -> { where(template: 'send_onboarding_content_email').where("template_params -> 'day' = ?", '1') }

  def self.process_webhook_event(event)
    msg = Message.find_by(mandrill_id: event['_id'])

    return unless msg

    msg.update(state: event['msg']['state'],
               opens: event['msg']['opens'].count,
               clicks: event['msg']['clicks'].count)
  end

  protected

  def send_message
    MandrillWorker.perform_at(process_at, id) unless Rails.env.test?
  end
end
