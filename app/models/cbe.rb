# frozen_string_literal: true

# CBES are created by calling the create method for example:
# name, title, description, and exam_body_id are required
# current_cbe = Cbe.create(name: 'BCCA EXAM', title: 'exam 1', description: 'test desc', exam_body_id: 1)
# current_cbe.initialize_settings will setup default settings for the CBE

class Cbe < ApplicationRecord
  has_many :cbe_sections, dependent: :destroy
  has_many :cbe_questions, dependent: :destroy
  has_many :cbe_introduction_pages, dependent: :destroy
  has_one :cbe_agreement, dependent: :destroy

  validates :name, :title, :description, :subject_course_id, presence: true

  def initialize_settings(exam_time = 120, number_of_pauses_allowed = 32, length_of_pauses = 15)
    self.exam_time = exam_time
    self.number_of_pauses_allowed = number_of_pauses_allowed
    self.length_of_pauses = length_of_pauses
    self.hard_time_limit = exam_time * 2
    self.save
  end

end
