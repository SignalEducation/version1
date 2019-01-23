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
    it { should validate_uniqueness_of(:name_url) }
    it { should validate_length_of(:name_url).is_at_most(255) }

    context 'if cme_is_video?' do
      before { allow(subject).to receive(:cme_is_video?).and_return(true) }
      it { should validate_presence_of(:description) }
    end

    it { should validate_presence_of(:course_module_id) }

    it { should validate_presence_of(:sorting_order) }

    it { should validate_length_of(:seo_description).is_at_most(255) }
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
    it { should respond_to(:available_for_trial) }
    it { should respond_to(:available_for_subscription) }
    it { should respond_to(:available_for_complimentary) }
    it { should respond_to(:available_to_user) }

    it { should respond_to(:type_name) }
    it { should respond_to(:cme_is_video?) }

  end

end
