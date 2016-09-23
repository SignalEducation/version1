# == Schema Information
#
# Table name: subject_courses
#
#  id                                      :integer          not null, primary key
#  name                                    :string
#  name_url                                :string
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  live                                    :boolean          default(FALSE), not null
#  wistia_guid                             :string
#  tutor_id                                :integer
#  cme_count                               :integer
#  video_count                             :integer
#  quiz_count                              :integer
#  question_count                          :integer
#  description                             :text
#  short_description                       :string
#  mailchimp_guid                          :string
#  forum_url                               :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  best_possible_first_attempt_score       :float
#  default_number_of_possible_exam_answers :integer
#  restricted                              :boolean          default(FALSE), not null
#  corporate_customer_id                   :integer
#  total_video_duration                    :float            default(0.0)
#  destroyed_at                            :datetime
#  is_cpd                                  :boolean          default(FALSE)
#  cpd_hours                               :float
#  cpd_pass_rate                           :integer
#  live_date                               :datetime
#  certificate                             :boolean          default(FALSE), not null
#  hotjar_guid                             :string
#  enrollment_option                       :boolean          default(FALSE)
#  subject_course_category_id              :integer
#  email_content                           :text
#

require 'rails_helper'

describe SubjectCourse do

  # attr-accessible
  black_list = %w(id created_at updated_at video_count quiz_count question_count best_possible_first_attempt_score total_video_duration destroyed_at)
  SubjectCourse.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(SubjectCourse.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should have_many(:course_modules) }
  it { should have_many(:course_module_elements) }
  it { should have_many(:course_module_element_quizzes) }
  it { should have_many(:course_module_jumbo_quizzes) }
  it { should have_many(:student_exam_tracks) }
  it { should have_many(:corporate_group_grants) }
  it { should have_and_belong_to_many(:groups) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:name_url) }
  it { should validate_length_of(:name_url).is_at_most(255) }

  xit { should validate_presence_of(:wistia_guid) }
  xit { should validate_length_of(:wistia_guid).is_at_most(255) }

  it { should validate_presence_of(:tutor_id) }

  it { should validate_presence_of(:description) }

  xit { should validate_presence_of(:short_description) }
  xit { should validate_length_of(:short_description).is_at_most(255) }

  it { should_not validate_presence_of(:mailchimp_guid) }
  it { should validate_length_of(:mailchimp_guid).is_at_most(255) }

  it { should_not validate_presence_of(:forum_url) }
  it { should validate_length_of(:forum_url).is_at_most(255) }

  it { should validate_presence_of(:default_number_of_possible_exam_answers) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:calculate_best_possible_score).before(:save) }
  it { should callback(:sanitize_name_url).before(:save) }


  # scopes
  it { expect(SubjectCourse).to respond_to(:all_active) }
  it { expect(SubjectCourse).to respond_to(:all_live) }
  it { expect(SubjectCourse).to respond_to(:all_in_order) }
  it { expect(SubjectCourse).to respond_to(:all_not_live) }
  it { expect(SubjectCourse).to respond_to(:all_not_restricted) }
  it { expect(SubjectCourse).to respond_to(:for_corporates) }
  it { expect(SubjectCourse).to respond_to(:for_public) }


  # class methods
  it { expect(SubjectCourse).to respond_to(:get_by_name_url) }
  it { expect(SubjectCourse).to respond_to(:search) }

  # instance methods
  it { should respond_to(:active_children) }
  it { should respond_to(:children) }
  it { should respond_to(:completed_by_user_or_guid) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:estimated_time_in_seconds) }
  it { should respond_to(:first_active_cme) }
  it { should respond_to(:number_complete_by_user_or_guid) }
  it { should respond_to(:percentage_complete_by_user_or_guid) }
  it { should respond_to(:project_data) }
  it { should respond_to(:total_project_hours_watched) }
  it { should respond_to(:monthly_project_hours_watched) }
  it { should respond_to(:last_6_months_project_data) }
  it { should respond_to(:total_questions_answered) }
  it { should respond_to(:monthly_questions_answered) }
  it { should respond_to(:tutor_name) }
  it { should respond_to(:recalculate_fields) }

end
