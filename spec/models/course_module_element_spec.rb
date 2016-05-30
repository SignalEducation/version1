# == Schema Information
#
# Table name: course_module_elements
#
#  id                        :integer          not null, primary key
#  name                      :string
#  name_url                  :string
#  description               :text
#  estimated_time_in_seconds :integer
#  course_module_id          :integer
#  sorting_order             :integer
#  tutor_id                  :integer
#  related_quiz_id           :integer
#  related_video_id          :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default(FALSE), not null
#  is_quiz                   :boolean          default(FALSE), not null
#  active                    :boolean          default(TRUE), not null
#  is_cme_flash_card_pack    :boolean          default(FALSE), not null
#  seo_description           :string
#  seo_no_index              :boolean          default(FALSE)
#  destroyed_at              :datetime
#  number_of_questions       :integer          default(0)
#  duration                  :float            default(0.0)
#

require 'rails_helper'

describe CourseModuleElement do

  # attr-accessible
  black_list = %w(id created_at updated_at destroyed_at forum_topic_id forum_topic_id duration)
  CourseModuleElement.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  subject { FactoryGirl.build(:course_module_element) }

  # Constants
  #it { expect()CourseModuleElement.const_defined?(:CONSTANT_NAME).to eq(true) }

  # relationships
  it { should belong_to(:course_module) }
  it { should have_one(:course_module_element_flash_card_pack)}
  it { should have_one(:course_module_element_quiz) }
  it { should have_many(:course_module_element_resources)}
  it { should have_many(:course_module_element_user_logs) }
  it { should have_one(:course_module_element_video) }
  it { should have_many(:quiz_answers) }
  it { should have_many(:quiz_questions) }
  it { should belong_to(:related_quiz) }
  it { should belong_to(:related_video) }
  it { should have_many(:student_exam_tracks) }
  it { should belong_to(:tutor) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url) }
  it { should validate_length_of(:name_url).is_at_most(255) }

  # it { should validate_presence_of(:description) }

  it { should validate_presence_of(:course_module_id) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:tutor_id) }

  it { should_not validate_presence_of(:related_quiz_id) }

  it { should_not validate_presence_of(:related_video_id) }

  it { should validate_length_of(:seo_description).is_at_most(255) }

  # callbacks
  it { should callback(:sanitize_name_url).before(:save) }
  it { should callback(:log_question_count_and_duration).before(:save) }
  it { should callback(:populate_estimated_time).before(:save) }
  it { should callback(:update_parent).after(:create) }
  it { should callback(:update_parent).after(:update) }

  # scopes
  it { expect(CourseModuleElement).to respond_to(:all_in_order) }
  it { expect(CourseModuleElement).to respond_to(:all_active) }
  it { expect(CourseModuleElement).to respond_to(:all_destroyed) }
  it { expect(CourseModuleElement).to respond_to(:all_videos) }
  it { expect(CourseModuleElement).to respond_to(:all_quizzes) }

  # class methods

  # instance methods
  it { should respond_to(:array_of_sibling_ids) }
  it { should respond_to(:completed_by_user_or_guid) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }
  it { should respond_to(:my_position_among_siblings) }
  it { should respond_to(:next_element) }
  it { should respond_to(:parent) }
  it { should respond_to(:previous_element) }
  it { should respond_to(:type_name) }

end
