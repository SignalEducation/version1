# == Schema Information
#
# Table name: quiz_answers
#
#  id                  :integer          not null, primary key
#  quiz_question_id    :integer
#  correct             :boolean          default("false"), not null
#  degree_of_wrongness :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  destroyed_at        :datetime
#

FactoryBot.define do
  factory :quiz_answer do
    quiz_question
    correct { false }
    degree_of_wrongness { 'incorrect' }

    factory :correct_quiz_answer do
      correct { true }
      degree_of_wrongness { 'correct' }
    end
  end
end
