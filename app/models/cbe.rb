class Cbe < ApplicationRecord
  has_many :cbe_sections
  has_many :cbe_questions
  has_many :cbe_introduction_pages
  has_one :cbe_agreement

  validates :name, :title, :description, :exam_body_id, presence: true


  def initialize_settings(exam_time = 120, number_of_pauses_allowed = 3, length_of_pauses = 15)
    self.exam_time = exam_time
    self.number_of_pauses_allowed = number_of_pauses_allowed
    self.length_of_pauses = length_of_pauses
    self.hard_time_limit = exam_time * 2
    self.save
  end


end
