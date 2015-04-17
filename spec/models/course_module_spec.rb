# == Schema Information
#
# Table name: course_modules
#
#  id                        :integer          not null, primary key
#  institution_id            :integer
#  qualification_id          :integer
#  exam_level_id             :integer
#  exam_section_id           :integer
#  name                      :string(255)
#  name_url                  :string(255)
#  description               :text
#  tutor_id                  :integer
#  sorting_order             :integer
#  estimated_time_in_seconds :integer
#  active                    :boolean          default(FALSE), not null
#  created_at                :datetime
#  updated_at                :datetime
#  cme_count                 :integer          default(0)
#  seo_description           :string(255)
#  seo_no_index              :boolean          default(FALSE)
#

require 'rails_helper'

describe CourseModule do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  CourseModule.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()CourseModule.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should have_many(:course_module_elements) }
  it { should have_many(:course_module_element_quizzes) }
  it { should have_many(:course_module_element_videos) }
  it { should have_many(:course_module_element_user_logs) }
  it { should have_one(:course_module_jumbo_quiz) }
  it { should belong_to(:exam_level) }
  it { should belong_to(:exam_section) }
  it { should belong_to(:institution) }
  it { should belong_to(:qualification) }
  it { should have_many(:student_exam_tracks) }
  it { should belong_to(:tutor) }

  # validation
  it { should validate_presence_of(:institution_id) }
  it { should validate_numericality_of(:institution_id) }

  it { should validate_presence_of(:exam_level_id) }
  it { should validate_numericality_of(:exam_level_id) }

  it { should_not validate_presence_of(:exam_section_id) }
  it { should validate_numericality_of(:exam_section_id) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to([:exam_section_id, :exam_level_id]) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url).scoped_to([:exam_section_id, :exam_level_id]) }

  it { should validate_presence_of(:tutor_id) }
  it { should validate_numericality_of(:tutor_id) }

  it { should validate_presence_of(:sorting_order) }

  # callbacks
  it { should callback(:unify_hierarchy_ids).before(:validation) }
  it { should callback(:set_sorting_order).before(:create) }
  it { should callback(:calculate_estimated_time).before(:save) }
  it { should callback(:sanitize_name_url).before(:save) }
  it { should callback(:set_cme_count).before(:save) }
  it { should callback(:update_parent_cme_count).after(:commit) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModule).to respond_to(:all_in_order) }
  it { expect(CourseModule).to respond_to(:all_active) }
  it { expect(CourseModule).to respond_to(:all_inactive) }
  it { expect(CourseModule).to respond_to(:with_url) }

  # class methods

  # instance methods
  it { should respond_to(:array_of_sibling_ids) }
  it { should respond_to(:children) }
  it { should respond_to(:completed_by_user_or_guid) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:full_name) }
  it { should respond_to(:my_position_among_siblings) }
  it { should respond_to(:next_module) }
  it { should respond_to(:next_module_id) }
  it { should respond_to(:parent) }
  it { should respond_to(:previous_module) }
  it { should respond_to(:previous_module_id) }
  it { should respond_to(:recalculate_estimated_time) }


end
