# == Schema Information
#
# Table name: course_tutors
#
#  id                :integer          not null, primary key
#  course_id :integer
#  user_id           :integer
#  sorting_order     :integer
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

describe CourseTutor do

  describe 'relationships' do
    it { should belong_to(:course) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:course_id) }
    it { should validate_numericality_of(:course_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_numericality_of(:user_id) }
    it { should validate_presence_of(:sorting_order) }
    it { should_not validate_presence_of(:title) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(CourseTutor).to respond_to(:all_in_order) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
  end

end
