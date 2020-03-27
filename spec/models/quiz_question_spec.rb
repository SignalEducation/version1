# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_quiz_id :integer
#  course_step_id      :integer
#  difficulty_level              :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  destroyed_at                  :datetime
#  course_id             :integer
#  sorting_order                 :integer
#  custom_styles                 :boolean          default("false")
#

require 'rails_helper'
require 'concerns/archivable_spec.rb'

describe QuizQuestion do
  describe 'relationships' do
    it { should belong_to(:course) }
    it { should belong_to(:course_step) }
    it { should belong_to(:course_quiz) }
    it { should have_many(:quiz_attempts) }
    it { should have_many(:quiz_answers) }
    it { should have_many(:quiz_contents) }
    it { should have_many(:quiz_solutions) }
  end

  describe 'validations' do
   it { should validate_presence_of(:course_step_id).on(:update) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:set_course_step).before(:validation) }
  end
  describe 'scopes' do
    it { expect(QuizQuestion).to respond_to(:all_in_order) }
    it { expect(QuizQuestion).to respond_to(:in_created_order) }
    it { expect(QuizQuestion).to respond_to(:all_destroyed) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
    it { should respond_to(:destroyable_children) }
  end

  describe 'Concern' do
    it_behaves_like 'archivable'
  end
end
