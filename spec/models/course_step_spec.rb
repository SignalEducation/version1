# == Schema Information
#
# Table name: course_steps
#
#  id                        :integer          not null, primary key
#  name                      :string(255)
#  name_url                  :string(255)
#  description               :text
#  estimated_time_in_seconds :integer
#  course_lesson_id          :integer
#  sorting_order             :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default("false"), not null
#  is_quiz                   :boolean          default("false"), not null
#  active                    :boolean          default("true"), not null
#  seo_description           :string(255)
#  seo_no_index              :boolean          default("false")
#  destroyed_at              :datetime
#  number_of_questions       :integer          default("0")
#  duration                  :float            default("0.0")
#  temporary_label           :string
#  is_constructed_response   :boolean          default("false"), not null
#  available_on_trial        :boolean          default("false")
#  related_course_step_id    :integer
#  is_note                   :boolean          default("false")
#  vid_end_seconds           :integer
#  is_practice_question      :boolean
#

require 'rails_helper'
require 'concerns/archivable_spec.rb'

describe CourseStep do
  describe 'relationships' do
    it { should belong_to(:course_lesson) }
    it { should belong_to(:related_course_step) }
    it { should have_one(:course_quiz) }
    it { should have_one(:course_video) }
    it { should have_one(:course_note) }
    it { should have_one(:constructed_response) }
    it { should have_one(:video_resource) }
    it { should have_many(:quiz_questions) }
    it { should have_many(:course_step_logs) }
    it { should have_many(:course_lesson_logs) }
    it { should have_many(:course_resources) }
  end

  describe 'Should Respond' do
    it { should respond_to(:id) }
    it { should respond_to(:name) }
    it { should respond_to(:name_url) }
    it { should respond_to(:description) }
    it { should respond_to(:estimated_time_in_seconds) }
    it { should respond_to(:course_lesson_id) }
    it { should respond_to(:sorting_order) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
    it { should respond_to(:is_video) }
    it { should respond_to(:is_quiz) }
    it { should respond_to(:active) }
    it { should respond_to(:seo_description) }
    it { should respond_to(:seo_no_index) }
    it { should respond_to(:destroyed_at) }
    it { should respond_to(:number_of_questions) }
    it { should respond_to(:duration) }
    it { should respond_to(:temporary_label) }
    it { should respond_to(:is_constructed_response) }
    it { should respond_to(:available_on_trial) }
    it { should respond_to(:related_course_step_id) }
    it { should respond_to(:is_note) }
    it { should respond_to(:vid_end_seconds) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_presence_of(:name_url) }
    it { should validate_uniqueness_of(:name_url).scoped_to(:course_lesson_id).with_message('must be unique within the course module') }
    it { should validate_presence_of(:course_lesson) }
    it { should validate_presence_of(:sorting_order) }
  end

  describe 'callbacks' do
    it { should callback(:log_count_fields).before(:save) }
    it { should callback(:sanitize_name_url).before(:save) }
    it { should callback(:update_parent).after(:save) }
  end

  describe 'scopes' do
    it { expect(CourseStep).to respond_to(:all_in_order) }
    it { expect(CourseStep).to respond_to(:all_active) }
    it { expect(CourseStep).to respond_to(:all_destroyed) }
    it { expect(CourseStep).to respond_to(:all_videos) }
    it { expect(CourseStep).to respond_to(:all_quizzes) }
    it { expect(CourseStep).to respond_to(:all_constructed_response) }
  end

  describe 'instance methods' do
    it { should respond_to(:parent) }

    it { should respond_to(:array_of_sibling_ids) }
    it { should respond_to(:my_position_among_siblings) }
    it { should respond_to(:next_element) }
    it { should respond_to(:previous_element) }

    it { should respond_to(:destroyable?) }
    it { should respond_to(:destroyable_children) }

    it { should respond_to(:completed_by_user) }
    it { should respond_to(:started_by_user) }

    it { should respond_to(:previous_cme_restriction) }
    it { should respond_to(:available_for_complimentary) }
    it { should respond_to(:available_to_user) }

    it { should respond_to(:type_name) }
    it { should respond_to(:cme_is_video?) }
  end

  describe 'methods' do
    let(:basic_student)       { create(:basic_student) }
    let(:course_section)      { create(:course_section) }
    let(:course_lesson)       { create(:course_lesson) }
    let(:active_lesson)       { create(:course_lesson, active: true, course_section: course_section) }
    let!(:course_step_01)     { create(:course_step, course_lesson: course_lesson) }
    let!(:course_step_02)     { create(:course_step, course_lesson: course_lesson) }
    let!(:course_step_03)     { create(:course_step, course_lesson: active_lesson) }

    describe 'Concern' do
      it_behaves_like 'archivable'
    end

    describe '#parent' do
      it 'return CourseLesson parent' do
        expect(course_step_01.parent).to be_kind_of(CourseLesson)
      end
    end

    describe '#array_of_sibling_ids' do
      it 'return steps ids' do
        expect(course_step_01.array_of_sibling_ids).to include(course_step_01.id, course_step_02.id)
        expect(course_step_02.array_of_sibling_ids).to include(course_step_01.id, course_step_02.id)
      end
    end

    describe '#my_position_among_siblings' do
      it 'return data index position' do
        expect(course_step_01.my_position_among_siblings).to eq(0)
        expect(course_step_02.my_position_among_siblings).to eq(1)
      end
    end

    describe '#with_active_parents?' do
      it 'return a bollean' do
        expect(course_step_01.with_active_parents?).to be(false)
        expect(course_step_02.with_active_parents?).to be(false)
        expect(course_step_03.with_active_parents?).to be(true)
      end
    end

    describe '#next_element' do
      context 'inactive step' do
        it 'does not return next element' do
          expect(course_step_01.next_element).not_to eq(course_step_01.course_lesson.course_section.course)
          expect(course_step_02.next_element).not_to eq(course_step_02.course_lesson.course_section.course)
        end
      end

      context 'active step' do
        it 'return next element' do
          allow(CourseStep).to receive(:find).and_return(active_lesson.course_section)
          allow_any_instance_of(CourseStep).to receive(:my_position_among_siblings).and_return(-99)

          expect(course_step_03.next_element).to eq(course_step_03.course_lesson.course_section)
        end
      end

      context 'next step in current lesson' do
        it 'return next element' do
          allow(CourseStep).to receive(:find).and_return(course_step_01)
          allow_any_instance_of(CourseStep).to receive(:my_position_among_siblings).and_return(-99)

          expect(course_step_03.next_element).to eq(course_step_01)
        end
      end

      context 'next step in next lesson' do
        xit 'return next element' do
          allow_any_instance_of(CourseLesson).to receive(:next_module).and_return(active_lesson)

          expect(course_step_03.next_element).to eq(course_step_03)
        end
      end
    end

    describe '#previous_element' do
      context 'active step' do
        it 'previous step in current lesson' do
          allow(CourseStep).to receive(:find).and_return(course_step_01)
          allow_any_instance_of(CourseStep).to receive(:my_position_among_siblings).and_return(99)

          expect(course_step_03.previous_element).to eq(course_step_01)
        end
      end

      context 'previous step in previous lesson' do
        it 'return previous element' do
          allow_any_instance_of(CourseLesson).to receive(:previous_module).and_return(active_lesson)

          expect(course_step_02.previous_element).to eq(course_step_01)
        end
      end
    end

    describe '#destroyable?' do
      it 'return a bollean' do
        expect(course_step_01.destroyable?).to be(true)
      end
    end

    describe '#completed_by_user' do
      it 'return a bollean' do
        expect(course_step_03.completed_by_user(basic_student.id)).to be(false)
      end
    end

    describe '#started_by_user' do
      it 'return a bollean' do
        expect(course_step_03.started_by_user(basic_student.id)).to be(false)
      end
    end

    describe '#type_name' do
      it 'return Quiz' do
        allow_any_instance_of(CourseStep).to receive(:is_quiz).and_return(true)

        expect(course_step_03.type_name).to eq('Quiz')
      end

      it 'return Video' do
        allow_any_instance_of(CourseStep).to receive(:is_video).and_return(true)

        expect(course_step_03.type_name).to eq('Video')
      end

      it 'return Notes' do
        allow_any_instance_of(CourseStep).to receive(:is_note).and_return(true)

        expect(course_step_03.type_name).to eq('Notes')
      end

      it 'return Contruct Response' do
        allow_any_instance_of(CourseStep).to receive(:is_constructed_response).and_return(true)

        expect(course_step_03.type_name).to eq('Constructed Response')
      end

      it 'return Unknown' do
        expect(course_step_03.type_name).to eq('Unknown')
      end
    end

    describe '#icon_label' do
      it 'return Quiz' do
        allow_any_instance_of(CourseStep).to receive(:is_quiz).and_return(true)

        expect(course_step_03.icon_label).to eq('quiz')
      end

      it 'return Video' do
        allow_any_instance_of(CourseStep).to receive(:is_video).and_return(true)

        expect(course_step_03.icon_label).to eq('smart_display')
      end

      it 'return Constructed Response' do
        allow_any_instance_of(CourseStep).to receive(:is_constructed_response).and_return(true)

        expect(course_step_03.icon_label).to eq('grid_on')
      end

      it 'return Notes' do
        allow_any_instance_of(CourseStep).to receive(:is_note).and_return(true)

        expect(course_step_03.icon_label).to eq('file_present')
      end

      it 'return Unknown' do
        expect(course_step_03.icon_label).to eq('checked')
      end
    end

    describe '#cme_is_video?' do
      context 'is video' do
        it do
          allow_any_instance_of(CourseStep).to receive(:is_video).and_return(true)
          expect(course_step_03.cme_is_video?).to be(true)
        end
      end

      context 'is not video' do
        it { expect(course_step_03.cme_is_video?).to be(false) }
      end
    end

    describe '.nested_resource_is_blank?' do
      it 'return a bollean' do
        expect(CourseStep.nested_resource_is_blank?({})).to be(true)
      end
    end

    describe '.nested_video_resource_is_blank?' do
      it 'return a bollean' do
        expect(CourseStep.nested_video_resource_is_blank?({})).to be(true)
      end
    end

    describe '#available_to_user' do
      it 'for unverified_user it returns false and verification-required' do
        user = build(:unverified_user)

        expect(course_step_01.available_to_user(user, nil)).to eq(view: false, reason: 'verification-required')
      end

      it 'for comp_user it returns true' do
        user = build(:comp_user)

        expect(course_step_01.available_to_user(user, nil)).to eq(view: true, reason: nil)
      end

      it 'for standard_student_user it returns false and invalid-subscription' do
        user        = build(:active_student_user)
        course_step = build(:course_step, available_on_trial: false)

        expect(course_step.available_to_user(user, nil)).to eq(view: false, reason: 'invalid-subscription')
      end
    end
  end
end
