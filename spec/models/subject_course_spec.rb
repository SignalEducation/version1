# == Schema Information
#
# Table name: subject_courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  cme_count                               :integer
#  video_count                             :integer
#  quiz_count                              :integer
#  question_count                          :integer
#  description                             :text
#  short_description                       :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  best_possible_first_attempt_score       :float
#  default_number_of_possible_exam_answers :integer
#  total_video_duration                    :float            default(0.0)
#  destroyed_at                            :datetime
#  email_content                           :text
#  external_url_name                       :string
#  external_url                            :string
#  exam_body_id                            :integer
#  survey_url                              :string
#  group_id                                :integer
#  quiz_pass_rate                          :integer
#

require 'rails_helper'

describe SubjectCourse do

  # attr-accessible
  black_list = %w(id created_at updated_at best_possible_first_attempt_score destroyed_at)
  SubjectCourse.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:exam_body) }
  it { should belong_to(:group) }
  it { should have_many(:course_modules) }
  it { should have_many(:course_module_elements) }
  it { should have_many(:course_module_element_quizzes) }
  it { should have_many(:enrollments) }
  it { should have_many(:home_pages) }
  it { should have_many(:student_exam_tracks) }
  it { should have_many(:subject_course_user_logs) }
  it { should have_many(:subject_course_resources) }
  it { should have_many(:orders) }
  it { should have_many(:white_papers) }
  it { should have_many(:mock_exams) }
  it { should have_and_belong_to_many(:users) }

  # validation
  # Build a FactoryGirl record for Rspec to test the uniqueness validations against
  subject { FactoryGirl.build(:subject_course) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url) }
  it { should validate_length_of(:name_url).is_at_most(255) }

  it { should validate_presence_of(:description) }

  it { should_not validate_presence_of(:short_description) }
  it { should validate_length_of(:short_description).is_at_most(255) }

  it { should validate_presence_of(:email_content).on(:update) }

  it { should validate_presence_of(:quiz_pass_rate) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:set_count_fields).before(:save) }
  it { should callback(:sanitize_name_url).before(:save) }


  # scopes
  it { expect(SubjectCourse).to respond_to(:all_active) }
  it { expect(SubjectCourse).to respond_to(:all_in_order) }
  it { expect(SubjectCourse).to respond_to(:this_month) }


  # class methods
  it { expect(SubjectCourse).to respond_to(:get_by_name_url) }
  it { expect(SubjectCourse).to respond_to(:search) }
  it { expect(SubjectCourse).to respond_to(:to_csv) }

  # instance methods
  it { should respond_to(:active_children) }
  it { should respond_to(:first_active_child) }
  it { should respond_to(:children) }
  it { should respond_to(:completed_by_user_or_guid) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }
  it { should respond_to(:enrolled_user_ids) }
  it { should respond_to(:estimated_time_in_seconds) }
  it { should respond_to(:first_active_cme) }
  it { should respond_to(:home_page) }
  it { should respond_to(:number_complete_by_user_or_guid) }
  it { should respond_to(:parent) }
  it { should respond_to(:percentage_complete_by_user_or_guid) }
  it { should respond_to(:recalculate_fields) }
  it { should respond_to(:revision_children?) }
  it { should respond_to(:started_by_user_or_guid) }
  it { should respond_to(:test_children?) }
  it { should respond_to(:tuition_children?) }


end
