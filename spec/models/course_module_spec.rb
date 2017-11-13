# == Schema Information
#
# Table name: course_modules
#
#  id                        :integer          not null, primary key
#  name                      :string
#  name_url                  :string
#  description               :text
#  sorting_order             :integer
#  estimated_time_in_seconds :integer
#  active                    :boolean          default(FALSE), not null
#  created_at                :datetime
#  updated_at                :datetime
#  cme_count                 :integer          default(0)
#  seo_description           :string
#  seo_no_index              :boolean          default(FALSE)
#  destroyed_at              :datetime
#  number_of_questions       :integer          default(0)
#  subject_course_id         :integer
#  video_duration            :float            default(0.0)
#  video_count               :integer          default(0)
#  quiz_count                :integer          default(0)
#  highlight_colour          :string
#  tuition                   :boolean          default(FALSE)
#  test                      :boolean          default(FALSE)
#  revision                  :boolean          default(FALSE)
#  discourse_topic_id        :integer
#

require 'rails_helper'

describe CourseModule do

  # attr-accessible
  black_list = %w(id created_at updated_at destroyed_at discourse_topic_id)
  CourseModule.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  subject { FactoryGirl.build(:course_module) }

  # Constants

  # relationships
  it { should belong_to(:subject_course) }

  it { should have_many(:course_module_elements) }
  it { should have_many(:course_module_element_quizzes) }
  it { should have_many(:course_module_element_videos) }
  it { should have_many(:course_module_element_user_logs) }
  it { should have_many(:student_exam_tracks) }


  # validation

  it { should validate_presence_of(:subject_course_id)}

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:subject_course_id) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url).scoped_to(:subject_course_id) }
  it { should validate_length_of(:name_url).is_at_most(255) }

  it { should validate_presence_of(:sorting_order) }

  it { should_not validate_presence_of(:highlight_colour) }

  it { should validate_length_of(:seo_description).is_at_most(255) }

  # callbacks
  it { should callback(:set_sorting_order).before(:create) }
  it { should callback(:set_count_fields).before(:save) }
  it { should callback(:sanitize_name_url).before(:save) }
  it { should callback(:update_parent).after(:update) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModule).to respond_to(:all_in_order) }
  it { expect(CourseModule).to respond_to(:all_active) }
  it { expect(CourseModule).to respond_to(:all_destroyed) }
  it { expect(CourseModule).to respond_to(:all_tuition) }
  it { expect(CourseModule).to respond_to(:all_revision) }
  it { expect(CourseModule).to respond_to(:all_test) }
  it { expect(CourseModule).to respond_to(:all_inactive) }
  it { expect(CourseModule).to respond_to(:with_url) }

  # class methods

  # instance methods
  it { should respond_to(:array_of_sibling_ids) }
  it { should respond_to(:children) }
  it { should respond_to(:completed_by_user_or_guid) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }
  it { should respond_to(:full_name) }
  it { should respond_to(:my_position_among_siblings) }
  it { should respond_to(:next_module) }
  it { should respond_to(:next_module_id) }
  it { should respond_to(:parent) }
  it { should respond_to(:previous_module) }
  it { should respond_to(:previous_module_id) }
  it { should respond_to(:update_video_and_quiz_counts) }

end
