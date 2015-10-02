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
#

require 'rails_helper'

describe SubjectCourse do

  # attr-accessible
  black_list = %w(id created_at updated_at video_count quiz_count question_count best_possible_first_attempt_score)
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

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:name_url) }
  it { should validate_length_of(:name_url).is_at_most(255) }

  xit { should validate_presence_of(:wistia_guid) }
  xit { should validate_length_of(:wistia_guid).is_at_most(255) }

  it { should validate_presence_of(:tutor_id) }
  it { should validate_numericality_of(:tutor_id) }

  it { should validate_presence_of(:description) }

  xit { should validate_presence_of(:short_description) }
  xit { should validate_length_of(:short_description).is_at_most(255) }

  it { should_not validate_presence_of(:mailchimp_guid) }
  it { should validate_length_of(:mailchimp_guid).is_at_most(255) }

  it { should_not validate_presence_of(:forum_url) }
  it { should validate_length_of(:forum_url).is_at_most(255) }

  it { should validate_presence_of(:default_number_of_possible_exam_answers) }
  it { should validate_numericality_of(:default_number_of_possible_exam_answers) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:calculate_best_possible_score).before(:save) }
  it { should callback(:sanitize_name_url).before(:save) }
  it { should callback(:recalculate_cme_count).before(:save) }


  # scopes
  it { expect(SubjectCourse).to respond_to(:all_active) }
  it { expect(SubjectCourse).to respond_to(:all_in_order) }


  # class methods
  it { expect(SubjectCourse).to respond_to(:get_by_name_url) }
  it { expect(SubjectCourse).to respond_to(:search) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:active_children) }
  it { should respond_to(:children) }
  it { should respond_to(:completed_by_user_or_guid) }
  it { should respond_to(:first_active_cme) }
  it { should respond_to(:number_complete_by_user_or_guid) }
  it { should respond_to(:percentage_complete_by_user_or_guid) }

end
