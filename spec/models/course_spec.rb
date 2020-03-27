# == Schema Information
#
# Table name: courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default("false"), not null
#  cme_count                               :integer
#  video_count                             :integer
#  quiz_count                              :integer
#  description                             :text
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  default_number_of_possible_exam_answers :integer
#  destroyed_at                            :datetime
#  exam_body_id                            :integer
#  survey_url                              :string
#  group_id                                :integer
#  quiz_pass_rate                          :integer
#  background_image_file_name              :string
#  background_image_content_type           :string
#  background_image_file_size              :integer
#  background_image_updated_at             :datetime
#  preview                                 :boolean          default("false")
#  computer_based                          :boolean          default("false")
#  highlight_colour                        :string           default("#ef475d")
#  category_label                          :string
#  icon_label                              :string
#  constructed_response_count              :integer          default("0")
#  completion_cme_count                    :integer
#  release_date                            :date
#  seo_title                               :string
#  seo_description                         :string
#  has_correction_packs                    :boolean          default("false")
#  short_description                       :text
#  on_welcome_page                         :boolean          default("false")
#  unit_label                              :string
#  level_id                                :integer
#

require 'rails_helper'
require 'concerns/archivable_spec.rb'

describe Course do
  describe 'relationships' do
    it { should belong_to(:exam_body) }
    it { should belong_to(:group) }
    it { should have_many(:course_tutors) }
    it { should have_many(:home_pages) }
    it { should have_many(:course_resources) }
    it { should have_many(:orders) }
    it { should have_many(:mock_exams) }
    it { should have_many(:exam_sittings) }
    it { should have_many(:enrollments) }
    it { should have_many(:course_logs) }
    it { should have_many(:course_sections) }
    it { should have_many(:course_section_logs) }
    it { should have_many(:course_lessons) }
    it { should have_many(:course_lesson_logs) }
    it { should have_many(:course_quizzes) }
    it { should have_many(:course_steps) }
    it { should have_many(:course_step_logs) }
  end

  describe 'validations' do
    subject { build(:course) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:name_url) }
    it { should validate_uniqueness_of(:name_url) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:quiz_pass_rate) }
    it { should validate_presence_of(:survey_url) }
    it { should validate_presence_of(:group_id) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:set_count_fields).before(:save) }
    it { should callback(:sanitize_name_url).before(:save) }
  end

  describe 'scopes' do
    it { expect(Course).to respond_to(:all_live) }
    it { expect(Course).to respond_to(:all_active) }
    it { expect(Course).to respond_to(:all_preview) }
    it { expect(Course).to respond_to(:all_computer_based) }
    it { expect(Course).to respond_to(:all_in_order) }
    it { expect(Course).to respond_to(:this_month) }
  end

  describe 'class methods' do
    it { expect(Course).to respond_to(:get_by_name_url) }
    it { expect(Course).to respond_to(:search) }
    it { expect(Course).to respond_to(:to_csv) }
  end

  describe 'instance methods' do
    it { should respond_to(:parent) }
    it { should respond_to(:children) }
    it { should respond_to(:active_children) }
    it { should respond_to(:valid_children) }
    it { should respond_to(:first_active_child) }
    it { should respond_to(:first_active_cme) }
    it { should respond_to(:destroyable?) }
    it { should respond_to(:destroyable_children) }
    it { should respond_to(:recalculate_fields) }
    it { should respond_to(:set_count_fields) }
    it { should respond_to(:enrolled_user_ids) }
    it { should respond_to(:active_enrollment_user_ids) }
    it { should respond_to(:valid_enrollment_user_ids) }
    it { should respond_to(:started_by_user) }
    it { should respond_to(:completed_by_user) }
    it { should respond_to(:percentage_complete_by_user) }
    it { should respond_to(:number_complete_by_user) }
    it { should respond_to(:update_all_course_logs) }
    it { should respond_to(:new_enrollments) }
    it { should respond_to(:active_enrollments) }
    it { should respond_to(:expired_enrollments) }
    it { should respond_to(:non_expired_enrollments) }
    it { should respond_to(:completed_enrollments) }
    it { should respond_to(:total_enrollments) }
    it { should respond_to(:home_page) }
    it { should respond_to(:duplicate) }
  end

  describe 'Concern' do
    it_behaves_like 'archivable'
  end
end
