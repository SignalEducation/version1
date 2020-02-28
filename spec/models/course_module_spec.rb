# == Schema Information
#
# Table name: course_modules
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  name_url                   :string(255)
#  description                :text
#  sorting_order              :integer
#  estimated_time_in_seconds  :integer
#  active                     :boolean          default("false"), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  cme_count                  :integer          default("0")
#  seo_description            :string(255)
#  seo_no_index               :boolean          default("false")
#  destroyed_at               :datetime
#  number_of_questions        :integer          default("0")
#  subject_course_id          :integer
#  video_duration             :float            default("0.0")
#  video_count                :integer          default("0")
#  quiz_count                 :integer          default("0")
#  highlight_colour           :string
#  tuition                    :boolean          default("false")
#  test                       :boolean          default("false")
#  revision                   :boolean          default("false")
#  course_section_id          :integer
#  constructed_response_count :integer          default("0")
#  temporary_label            :string
#

require 'rails_helper'

describe CourseModule do
  describe 'relationships' do
    it { should belong_to(:subject_course) }
    it { should belong_to(:course_section) }
    it { should have_many(:student_exam_tracks) }
    it { should have_many(:course_module_elements) }
    it { should have_many(:course_module_element_quizzes) }
    it { should have_many(:course_module_element_videos) }
    it { should have_many(:course_module_element_user_logs) }
  end

  describe 'validations' do
    it { should validate_presence_of(:subject_course) }

    it { should validate_presence_of(:course_section) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:course_section_id).with_message('must be unique within the course section') }

    it { should validate_presence_of(:name_url) }
    it { should validate_uniqueness_of(:name_url).scoped_to(:course_section_id).with_message('must be unique within the course section') }

    it { should validate_presence_of(:sorting_order) }
  end

  describe 'callbacks' do
    it { should callback(:set_sorting_order).before(:create) }
    it { should callback(:set_count_fields).before(:save) }
    it { should callback(:sanitize_name_url).before(:save) }
    it { should callback(:update_parent).after(:update) }
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(CourseModule).to respond_to(:all_in_order) }
    it { expect(CourseModule).to respond_to(:all_active) }
    it { expect(CourseModule).to respond_to(:all_destroyed) }
    it { expect(CourseModule).to respond_to(:all_inactive) }
    it { expect(CourseModule).to respond_to(:with_url) }
  end

  describe 'instance methods' do
    it { should respond_to(:parent) }
    it { should respond_to(:children) }
    it { should respond_to(:active_children) }
    it { should respond_to(:first_active_cme) }
    it { should respond_to(:children_available_count) }
    it { should respond_to(:array_of_sibling_ids) }
    it { should respond_to(:my_position_among_siblings) }
    it { should respond_to(:next_module) }
    it { should respond_to(:next_module_id) }
    it { should respond_to(:previous_module) }
    it { should respond_to(:previous_module_id) }
    it { should respond_to(:destroyable?) }
    it { should respond_to(:destroyable_children) }
    it { should respond_to(:update_video_and_quiz_counts) }

    it { should respond_to(:completed_by_user) }
    it { should respond_to(:percentage_complete_by_user) }
    it { should respond_to(:completed_for_scul) }
    it { should respond_to(:percentage_complete_for_scul) }
    it { should respond_to(:all_content_restricted?) }
  end
end
