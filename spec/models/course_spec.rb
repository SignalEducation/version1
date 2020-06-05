# frozen_string_literal: true

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
#  accredible_group_id                     :integer
#

require 'rails_helper'
require 'concerns/archivable_spec.rb'

describe Course, type: :model do
  let(:user)                     { create(:user) }
  let!(:course)                  { create(:active_course) }
  let!(:course_sections)         { create_list(:course_section, 3, course: course) }
  let!(:inactive_course_section) { create(:course_section, course: course, active: false) }
  let!(:course_lesson)           { create(:course_lesson, course_section: course_sections.first) }

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

    context 'emit certificate' do
      before { allow(subject).to receive(:emit_certificate?).and_return(true) }
      it { is_expected.to validate_presence_of(:accredible_group_id) }
    end

    context 'not emit certificate' do
      before { allow(subject).to receive(:emit_certificate?).and_return(false) }
      it { is_expected.not_to validate_presence_of(:accredible_group_id) }
    end
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
    it { should respond_to(:emit_certificate?) }
  end

  describe 'Concern' do
    it_behaves_like 'archivable'
  end

  describe 'Methods' do
    describe '.get_by_name_url' do
      context 'return course' do
        it { expect(Course.get_by_name_url(course.name_url)).to eq(course) }
      end
    end

    describe '.search' do
      context 'return should find course by name' do
        it { expect(Course.search(course.name.first(3))).to include(course) }
        it { expect(Course.search(course.name.last(2))).to include(course) }
      end

      context 'return should find course by description' do
        it { expect(Course.search(course.description.first(3))).to include(course) }
        it { expect(Course.search(course.description.last(2))).to include(course) }
      end

      context 'return should find course without any search' do
        it { expect(Course.search(nil)).to include(course) }
      end
    end

    describe '.to_csv' do
      context 'return course' do
        it do
          expect(Course.to_csv).to include('name',
                                           'new_enrollments',
                                           'total_enrollments',
                                           'active_enrollments',
                                           'non_expired_enrollments',
                                           'expired_enrollments')
        end
      end
    end

    describe '#parent' do
      context 'return group' do
        it { expect(course.parent).to be_a(Group) }
      end
    end

    describe '#parent' do
      context 'return group' do
        it { expect(course.parent).to be_a(Group) }
      end
    end

    describe '#parent' do
      context 'return group' do
        it { expect(course.parent).to be_a(Group) }
      end
    end

    describe '#children' do
      context 'return course_sections' do
        it { expect(course.children).to include(course_sections.sample) }
        it { expect(course.children).to include(inactive_course_section) }
      end
    end

    describe '#active_children' do
      context 'return actives course_sections' do
        it { expect(course.active_children).to include(course_sections.sample) }
        it { expect(course.active_children).not_to include(inactive_course_section) }
      end
    end

    describe '#valid_children' do
      context 'return actives course_sections' do
        it { expect(course.valid_children).to include(course_sections.sample) }
        it { expect(course.valid_children).not_to include(inactive_course_section) }
      end
    end

    describe '#first_active_child' do
      context 'return actives course_sections' do
        it { expect(course.first_active_child).to eq(course_sections.first) }
      end
    end

    describe '#first_active_cme' do
      it 'return actives course_sections' do
        expect_any_instance_of(CourseSection).to receive(:first_active_cme).and_return(course_lesson)

        expect(course.first_active_cme).to eq(course_lesson)
      end
    end

    describe '#destroyable?' do
      context 'always return true' do
        it { expect(course).to be_destroyable }
      end
    end

    describe 'Enrollments' do
      before do
        allow_any_instance_of(Enrollment).to receive(:set_percentage_complete).and_return(true)
      end

      let!(:enrollments) { create_list(:enrollment, 3, course: course) }

      describe '#enrolled_user_ids' do
        context 'return users id' do
          it { expect(course.enrolled_user_ids).to include(1) }
        end
      end

      describe '#enrolled_user_ids' do
        context 'return actives users id' do
          it { expect(course.active_enrollment_user_ids).to be_empty }
        end
      end

      describe '#valid_enrollment_user_ids' do
        context 'return valid users id' do
          it { expect(course.valid_enrollment_user_ids).to be_empty }
        end
      end
    end

    describe '#started_by_user' do
      let!(:course_logs) { create_list(:course_log, 3, course: course, user: user) }

      context 'always return true' do
        it { expect(course.started_by_user(user.id)).to eq(course_logs.first) }
      end
    end

    describe '#completed_by_user' do
      context 'return if completed' do
        it { expect(course.completed_by_user(user.id)).to be(false) }
      end
    end

    describe '#check_dependencies' do
      it 'stubb destroyable to true to cover method' do
        allow_any_instance_of(Course).to receive(:destroyable?).and_return(false)
        course.destroy

        expect(course.errors).to be_empty
      end
    end

    describe '#update_all_course_logs' do
      let(:worker) { CourseLessonLogsWorker }

      before do
        Sidekiq::Testing.fake!
        Sidekiq::Worker.clear_all
        allow_any_instance_of(CourseLessonLogsWorker).to receive(:perform).and_return(true)
      end

      it 'stubb destroyable to true to cover method' do
        expect{ course.update_all_course_logs }.to change(worker.jobs, :size).by(1)
      end
    end

    describe '#home_page' do
      let!(:home_page) { create(:home_page, course: course) }

      context 'return if completed' do
        it { expect(course.home_page).to eq(home_page) }
      end
    end
  end
end
