# == Schema Information
#
# Table name: exam_levels
#
#  id                                      :integer          not null, primary key
#  qualification_id                        :integer
#  name                                    :string(255)
#  name_url                                :string(255)
#  is_cpd                                  :boolean          default(FALSE), not null
#  sorting_order                           :integer
#  active                                  :boolean          default(FALSE), not null
#  best_possible_first_attempt_score       :float
#  created_at                              :datetime
#  updated_at                              :datetime
#  default_number_of_possible_exam_answers :integer          default(4)
#  enable_exam_sections                    :boolean          default(TRUE), not null
#  cme_count                               :integer          default(0)
#  seo_description                         :string(255)
#  seo_no_index                            :boolean          default(FALSE)
#  description                             :text
#  duration                                :integer
#

require 'rails_helper'

describe ExamLevel do

  # attr-accessible
  black_list = %w(id created_at updated_at best_possible_first_attempt_score cme_count)
  ExamLevel.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()ExamLevel.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should have_many(:exam_sections) }
  it { should have_many(:course_modules) }
  it { should have_many(:course_module_elements) }
  it { should have_many(:course_module_element_quizzes) }
  it { should have_many(:course_module_jumbo_quizzes) }
  it { should belong_to(:qualification) }
  it { should have_many(:student_exam_tracks) }
  it { should have_many(:user_exam_level) }

  # validation
  it { should validate_presence_of(:qualification_id) }
  it { should validate_numericality_of(:qualification_id) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:qualification_id) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url).scoped_to(:qualification_id) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:default_number_of_possible_exam_answers) }
  it { should validate_numericality_of(:default_number_of_possible_exam_answers) }

  it { should validate_presence_of(:description) }

  # callbacks
  it { should callback(:set_sorting_order).before(:create) }
  it { should callback(:calculate_best_possible_score).before(:save) }
  it { should callback(:sanitize_name_url).before(:save) }
  it { should callback(:recalculate_cme_count).before(:save) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ExamLevel).to respond_to(:all_active) }
  it { expect(ExamLevel).to respond_to(:all_in_order) }
  it { expect(ExamLevel).to respond_to(:all_with_exam_sections_enabled) }

  # class methods
  it { expect(ExamLevel).to respond_to(:get_by_name_url) }

  # instance methods
  it { should respond_to(:active_children) }
  it { should respond_to(:children) }
  it { should respond_to(:completed_by_user_or_guid) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:first_active_cme) }
  it { should respond_to(:full_name) }
  it { should respond_to(:number_complete_by_user_or_guid) }
  it { should respond_to(:parent) }
  it { should respond_to(:percentage_complete_by_user_or_guid) }

end
