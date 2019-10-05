# == Schema Information
#
# Table name: course_module_elements
#
#  id                               :integer          not null, primary key
#  name                             :string
#  name_url                         :string
#  description                      :text
#  estimated_time_in_seconds        :integer
#  course_module_id                 :integer
#  sorting_order                    :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#  is_video                         :boolean          default(FALSE), not null
#  is_quiz                          :boolean          default(FALSE), not null
#  active                           :boolean          default(TRUE), not null
#  seo_description                  :string
#  seo_no_index                     :boolean          default(FALSE)
#  destroyed_at                     :datetime
#  number_of_questions              :integer          default(0)
#  duration                         :float            default(0.0)
#  temporary_label                  :string
#  is_constructed_response          :boolean          default(FALSE), not null
#  available_on_trial               :boolean          default(FALSE)
#  related_course_module_element_id :integer
#

require 'rails_helper'

describe CourseModuleElement do

  describe 'relationships' do
    it { should belong_to(:course_module) }
    it { should belong_to(:related_course_module_element) }
    it { should have_one(:course_module_element_quiz) }
    it { should have_one(:course_module_element_video) }
    it { should have_one(:constructed_response) }
    it { should have_one(:video_resource) }
    it { should have_many(:quiz_questions) }
    it { should have_many(:course_module_element_resources)}
    it { should have_many(:course_module_element_user_logs) }
    it { should have_many(:student_exam_tracks) }
  end

  describe 'validations' do

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }

    it { should validate_presence_of(:name_url) }
    it { should validate_uniqueness_of(:name_url).scoped_to(:course_module_id).with_message('must be unique within the course module') }

    it { should validate_presence_of(:course_module_id) }

    it { should validate_presence_of(:sorting_order) }
  end

  describe 'callbacks' do
    it { should callback(:log_count_fields).before(:save) }
    it { should callback(:sanitize_name_url).before(:save) }
    it { should callback(:update_parent).after(:save) }
  end

  describe 'scopes' do
    it { expect(CourseModuleElement).to respond_to(:all_in_order) }
    it { expect(CourseModuleElement).to respond_to(:all_active) }
    it { expect(CourseModuleElement).to respond_to(:all_destroyed) }
    it { expect(CourseModuleElement).to respond_to(:all_videos) }
    it { expect(CourseModuleElement).to respond_to(:all_quizzes) }
    it { expect(CourseModuleElement).to respond_to(:all_constructed_response) }
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
    it { should respond_to(:available_for_subscription) }
    it { should respond_to(:available_for_complimentary) }
    it { should respond_to(:available_to_user) }

    it { should respond_to(:type_name) }
    it { should respond_to(:cme_is_video?) }

    describe User, '#available_to_user' do
      it 'for unverified_user it returns false and verification-required' do
        user = build(:unverified_user)
        cme = build(:course_module_element)

        expect(cme.available_to_user(user, nil)).to eq(view: false, reason: 'verification-required')
      end

      it 'for comp_user it returns true' do
        user = build(:comp_user)
        cme = build(:course_module_element)

        expect(cme.available_to_user(user, nil)).to eq(view: true, reason: nil)
      end

      it 'for standard_student_user it returns false and invalid-subscription' do
        user = build(:active_student_user)
        cme = build(:course_module_element, available_on_trial: false)

        expect(cme.available_to_user(user, nil)).to eq(view: false, reason: 'invalid-subscription')
      end
    end

  end

end
