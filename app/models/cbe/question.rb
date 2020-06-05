# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_questions
#
#  id              :bigint           not null, primary key
#  content         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  kind            :integer
#  cbe_section_id  :bigint
#  score           :float
#  sorting_order   :integer
#  cbe_scenario_id :bigint
#  solution        :text
#  destroyed_at    :datetime
#  active          :boolean          default("true")
#
class Cbe
  class Question < ApplicationRecord
    # concerns
    include CbeQuestionTypes
    include CbeSupport

    # relationships
    belongs_to :section, class_name: 'Cbe::Section', foreign_key: 'cbe_section_id',
                         inverse_of: :questions
    belongs_to :scenario, class_name: 'Cbe::Scenario', foreign_key: 'cbe_scenario_id',
                          inverse_of: :questions, optional: true
    has_many :answers, class_name: 'Cbe::Answer', foreign_key: 'cbe_question_id',
                       inverse_of: :question, dependent: :destroy
    has_many :user_questions, class_name: 'Cbe::UserQuestion', foreign_key: 'cbe_question_id',
                              inverse_of: :cbe_question, dependent: :restrict_with_error

    accepts_nested_attributes_for :answers, allow_destroy: true

    # validations
    validates :content, :kind, :score, presence: true
    validates :score, numericality: { greater_than_or_equal_to: 0 }

    # scopes
    scope :without_scenario, -> { where(cbe_scenario_id: nil) }
    scope :with_scenario,    -> { where.not(cbe_scenario_id: nil) }
  end
end
