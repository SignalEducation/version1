# frozen_string_literal: true

# == Schema Information
#
# Table name: ahoy_events
#
#  id         :uuid             not null, primary key
#  visit_id   :uuid
#  user_id    :integer
#  name       :string
#  properties :text
#  time       :datetime
#

class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods

  self.table_name = "ahoy_events"

  belongs_to :visit
  belongs_to :user, optional: true

  scope :all_in_order, -> { order(:time) }
  scope :this_month, -> { where(time: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month - 1.month) }
  scope :last_month, -> { where(time: (Time.zone.now.beginning_of_month - 1.month)..(Time.zone.now.end_of_month - 1.month)) }
  scope :all_registration_events, -> { where_event('Page View', properties = { title: 'Thank You for Registering | LearnSignal' }) }
  scope :all_get_started_events, -> { where_event('Video Play', properties = { lesson: 'Get Started' }) }
  scope :all_checkout_events, -> { where_event('Page View', properties = { title: 'Course Membership Payment | LearnSignal' }) }
  scope :all_payment_success_events, -> { where_event('Page View', properties = { title: 'Thank You for Subscribing | LearnSignal' }) }
  scope :all_page_load_events, -> { where_event('Page View') }
  scope :all_get_started_page_loads, -> { where_event('Page View', properties = { url: 'https://learnsignal.com/en/courses/fr/learning/free-lesson/get-started' }) }

  def next_event
    siblings = visit.events.all_in_order.map(&:id)
    my_position_among_siblings = siblings.index(id)
    Ahoy::Event.find(siblings[my_position_among_siblings + 1])
  end

  def next_pageload
    siblings = visit.events.all_page_load_events.all_in_order.map(&:id)
    my_position_among_siblings = siblings.index(id)
    Ahoy::Event.find(siblings[my_position_among_siblings + 1])
  end

  def next_pageload_event
    siblings_events = visit.events.all_page_load_events.map(&:id)
    all = siblings_events + id
    all_events = Ahoy::Event.where(id: all).all_in_order.map(&:id)

    my_position_among_siblings = all_events.index(id)
    Ahoy::Event.find(siblings_events[my_position_among_siblings + 1])
  end

end
