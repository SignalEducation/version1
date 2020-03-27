# == Schema Information
#
# Table name: course_quizzes
#
#  id                          :integer          not null, primary key
#  course_step_id    :integer
#  number_of_questions         :integer
#  question_selection_strategy :string(255)
#  created_at                  :datetime
#  updated_at                  :datetime
#  destroyed_at                :datetime
#

require 'rails_helper'
require 'concerns/archivable_spec.rb'

describe CourseQuiz do
  describe 'constants' do
    it { expect(CourseQuiz.const_defined?(:STRATEGIES)).to eq(true) }
  end

  describe 'relationships' do
    it { should belong_to(:course_step) }
    it { should have_many(:quiz_questions) }
  end

  describe 'validations' do
    it { should validate_presence_of(:course_step_id).on(:update) }
    it { should validate_presence_of(:number_of_questions).on(:update) }
    it { should validate_inclusion_of(:question_selection_strategy).in_array(CourseQuiz::STRATEGIES) }
    it { should validate_length_of(:question_selection_strategy).is_at_most(255) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(CourseQuiz).to respond_to(:all_in_order) }
    it { expect(CourseQuiz).to respond_to(:all_destroyed) }
  end

  describe 'instance methods' do
    it { should respond_to(:enough_questions?) }
    it { should respond_to(:add_an_empty_question) }
    it { should respond_to(:all_ids_random) }
    it { should respond_to(:all_ids_ordered) }
    it { should respond_to(:destroyable?) }
    it { should respond_to(:destroyable_children) }
    it { should respond_to(:duplicate) }
  end

  describe 'Concern' do
    it_behaves_like 'archivable'
  end
end
