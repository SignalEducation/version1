# frozen_string_literal: true

# == Schema Information
#
# Table name: visits
#
#  id               :uuid             not null, primary key
#  visitor_id       :uuid
#  ip               :string
#  user_agent       :text
#  referrer         :text
#  landing_page     :text
#  user_id          :integer
#  referring_domain :string
#  search_keyword   :string
#  browser          :string
#  os               :string
#  device_type      :string
#  screen_height    :integer
#  screen_width     :integer
#  country          :string
#  region           :string
#  city             :string
#  postal_code      :string
#  latitude         :decimal(, )
#  longitude        :decimal(, )
#  utm_source       :string
#  utm_medium       :string
#  utm_term         :string
#  utm_content      :string
#  utm_campaign     :string
#  started_at       :datetime
#

class Ahoy::Visit < ApplicationRecord
  has_many :events, class_name: 'Ahoy::Event', dependent: :destroy
  has_one :subscription, foreign_key: 'ahoy_visit_id', inverse_of: :ahoy_visit
  belongs_to :user, optional: true

  scope :search_for, ->(search_term) { where('utm_source ILIKE :t OR utm_medium ILIKE :t OR utm_term ILIKE :t  OR utm_content ILIKE :t  OR utm_campaign ILIKE :t ', t: '%' + search_term + '%').order(started_at: :desc) }
  scope :all_in_order, -> { order(:started_at) }

  def study_visit?
    user.course_step_logs.where(created_at: started_at.to_date.midnight..started_at.to_date.end_of_day).any?
  end

  def self.to_csv(options = {}, attributes = %w[id user_id ])
    CSV.generate(options) do |csv|
      csv << attributes

      find_each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end


  def generate_source
    search_list = %w[www.google.com www.bing.com www.google.com.sg www.google.co.uk uk.search.yahoo.com yandex.ru]
    non_referral_list = %w[learnsignal.com www.learnsignal.com www.google.com www.bing.com com.google.android.gm mail.qq.com www.google.com.sg www.google.co.uk uk.search.yahoo.com yandex.ru]

    if !utm_campaign.blank? && utm_campaign == 'OnboardingEmails'
      'Onboarding Email'
    elsif referring_domain == 'blog.learnsignal.com'
      'Blog'
    elsif !referring_domain.blank? && visit_referring_domain == 'www.youtube.com'
      'Youtube'
    elsif !referring_domain.blank? && search_list.include?(referring_domain)
      'Search'
    elsif !referring_domain.blank? && !non_referral_list.include?(referring_domain)
      'Referral'
    elsif !landing_page.blank? && referrer.blank?
      'Direct'
    #elsif utm_medium == 'Onsite_banner'
    #  previous_visit.generate_source
    end
  end

  def previous_visit
    user.ahoy_visits.where('started_at < ?', started_at).all_in_order.last
  end

  def page_load_events
    last_get_started_event = events.all_get_started_events.last
    events.all_in_order.where('time > ?', last_get_started_event.time).where.not(name: 'Video Finished')
  end

  def event_1
    page_load_events[0].name if page_load_events.any?
  end

  def event_2
    page_load_events[1].name if page_load_events.any? && page_load_events[1]
  end

  def event_3
    page_load_events[2].name if page_load_events.any? && page_load_events[2]
  end

  def event_4
    page_load_events[3].name if page_load_events.any? && page_load_events[3]
  end

  def event_5
    page_load_events[4].name if page_load_events.any? && page_load_events[4]
  end

  def self.events_to_csv(options = {}, attributes = %w[id user_id started_at event_1 event_2 event_3 event_4 event_5])
    CSV.generate(options) do |csv|
      csv << attributes

      find_each do |event|
        csv << attributes.map { |attr| event.send(attr) }
      end
    end
  end

end
