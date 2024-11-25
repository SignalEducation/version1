# == Schema Information
#
# Table name: course_sections
#
#  id                         :integer          not null, primary key
#  course_id                  :integer
#  name                       :string
#  name_url                   :string
#  sorting_order              :integer
#  active                     :boolean          default("false")
#  counts_towards_completion  :boolean          default("false")
#  assumed_knowledge          :boolean          default("false")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  cme_count                  :integer          default("0")
#  video_count                :integer          default("0")
#  quiz_count                 :integer          default("0")
#  destroyed_at               :datetime
#  constructed_response_count :integer          default("0")
#

require 'rails_helper'

describe CourseSection do
  describe 'relationships' do
    it { should belong_to(:course) }
    it { should have_many(:course_lessons) }
    it { should have_many(:course_section_logs) }
    it { should have_many(:course_lesson_logs) }
    it { should have_many(:course_step_logs) }
  end

  describe 'validations' do
    it { should validate_presence_of(:course) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:name_url) }
    xit { should validate_uniqueness_of(:name_url).scoped_to(:course) }
    xit { should validate_presence_of(:sorting_order) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(CourseSection).to respond_to(:all_in_order) }
    it { expect(CourseSection).to respond_to(:all_active) }
    it { expect(CourseSection).to respond_to(:all_for_completion) }
  end

  describe 'instance methods' do
    it { should respond_to(:parent) }
    it { should respond_to(:children) }
    it { should respond_to(:active_children) }
    it { should respond_to(:first_active_course_lesson) }
    it { should respond_to(:first_active_cme) }
    it { should respond_to(:children_available_count) }
    it { should respond_to(:all_content_restricted?) }
    it { should respond_to(:destroyable?) }
    it { should respond_to(:destroyable_children) }
    it { should respond_to(:recalculate_fields) }
  end
end
