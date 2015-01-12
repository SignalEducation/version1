# == Schema Information
#
# Table name: course_module_elements
#
#  id                        :integer          not null, primary key
#  name                      :string(255)
#  name_url                  :string(255)
#  description               :text
#  estimated_time_in_seconds :integer
#  course_module_id          :integer
#  sorting_order             :integer
#  forum_topic_id            :integer
#  tutor_id                  :integer
#  related_quiz_id           :integer
#  related_video_id          :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default(FALSE), not null
#  is_quiz                   :boolean          default(FALSE), not null
#  active                    :boolean          default(TRUE), not null
#

require 'rails_helper'

describe CourseModuleElement do

  # attr-accessible
  black_list = %w(id created_at updated_at )
  CourseModuleElement.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()CourseModuleElement.const_defined?(:CONSTANT_NAME).to eq(true) }

  # relationships
  it { should belong_to(:course_module) }
  it { should have_one(:course_module_element_quiz) }
  it { should have_many(:course_module_element_resources)}
  it { should have_many(:course_module_element_user_logs) }
  it { should have_one(:course_module_element_video) }
  it { should belong_to(:forum_topic) }
  it { should have_many(:quiz_answers) }
  it { should have_many(:quiz_questions) }
  it { should belong_to(:related_quiz) }
  it { should belong_to(:related_video) }
  it { should belong_to(:tutor) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:estimated_time_in_seconds) }
  it { should validate_numericality_of(:estimated_time_in_seconds) }

  it { should validate_presence_of(:course_module_id) }
  it { should validate_numericality_of(:course_module_id) }

  it { should validate_presence_of(:sorting_order) }
  it { should validate_numericality_of(:sorting_order) }

  it { should_not validate_presence_of(:forum_topic_id) }
  it { should validate_numericality_of(:forum_topic_id) }

  it { should validate_presence_of(:tutor_id) }
  it { should validate_numericality_of(:tutor_id) }

  it { should_not validate_presence_of(:related_quiz_id) }
  it { should validate_numericality_of(:related_quiz_id) }

  it { should_not validate_presence_of(:related_video_id) }
  it { should validate_numericality_of(:related_video_id) }

  # callbacks
  it { should callback(:sanitize_name_url).before(:save) }
  it { should callback(:update_the_module_total_time).after(:save) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleElement).to respond_to(:all_in_order) }
  it { expect(CourseModuleElement).to respond_to(:all_active) }
  it { expect(CourseModuleElement).to respond_to(:all_videos) }
  it { expect(CourseModuleElement).to respond_to(:all_quizzes) }

  # class methods

  # instance methods
  it { should respond_to(:array_of_sibling_ids) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:my_position_among_siblings) }
  it { should respond_to(:next_element_id) }
  it { should respond_to(:parent) }
  it { should respond_to(:previous_element_id) }
  it { should respond_to(:update_the_module_total_time) }

end
