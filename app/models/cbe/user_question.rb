# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_user_questions
#
#  id               :bigint           not null, primary key
#  educator_comment :text
#  score            :float            default("0.0")
#  correct          :boolean          default("false")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  cbe_user_log_id  :bigint
#  cbe_question_id  :bigint
#
class Cbe
  class UserQuestion < ApplicationRecord
    # relationships
    belongs_to :user_log, class_name: 'Cbe::UserLog', foreign_key: 'cbe_user_log_id',
                          inverse_of: :questions
    belongs_to :cbe_question, class_name: 'Cbe::Question', foreign_key: 'cbe_question_id',
                              inverse_of: :user_questions
    has_one :section, through: :cbe_question
    has_many :answers, class_name: 'Cbe::UserAnswer', foreign_key: 'cbe_user_question_id',
                       inverse_of: :question, dependent: :destroy

    accepts_nested_attributes_for :answers

    # scopes
    scope :by_section, ->(section_id) { joins(cbe_question: :section).where('cbe_sections.id': section_id).order('cbe_questions.sorting_order') }
  end
end
