# frozen_string_literal: true

# CBES are created by calling the create method for example:
# name, title, description, and exam_body_id are required
# current_cbe = Cbe.create(name: 'BCCA EXAM', title: 'exam 1', description: 'test desc', exam_body_id: 1)
# current_cbe.initialize_settings will setup default settings for the CBE
class Cbe < ApplicationRecord
  alias_attribute :time, :hard_time_limit
  alias_attribute :number_of_pauses, :number_of_pauses_allowed
  alias_attribute :cbe_length_of_pauses, :length_of_pauses

  # relationships
  belongs_to :subject_course
  has_one :product, dependent: :destroy

  has_many :sections, dependent: :destroy, inverse_of: :cbe,
                      class_name: 'Cbe::Section'
  has_many :introduction_pages, dependent: :destroy, inverse_of: :cbe,
                                class_name: 'Cbe::IntroductionPage'
  has_many :questions, through: :sections, class_name: 'Cbe::Question'
  has_many :resources, inverse_of: :cbe, class_name: 'Cbe::Resource',
                       dependent: :destroy

  # validations
  validates :name, :agreement_content, :subject_course_id, presence: true

  # instance methods
  def initialize_settings(exam_time = 120, pauses_allowed = 32, length_of_pauses = 15)
    self.number_of_pauses_allowed = pauses_allowed
    self.length_of_pauses = length_of_pauses
    self.hard_time_limit = exam_time * 2

    save
  end
end
