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
#  compulsory                :boolean          default(FALSE), not null
#  active                    :boolean          default(FALSE), not null
#  created_at                :datetime
#  updated_at                :datetime
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
  #it { CourseModule.const_defined?(:CONSTANT_NAME) }

  # relationships
  it { should belong_to(:institution) }
  it { should belong_to(:exam_level) }
  it { should belong_to(:exam_section) }
  it { should belong_to(:qualification) }
  it { should belong_to(:tutor) }
  it { should have_many(:course_module_elements) }
  it { should have_many(:course_module_element_user_logs) }
  it { should have_many(:course_module_jumbo_quizzes) }

  # validation
  it { should validate_presence_of(:institution_id) }
  it { should validate_numericality_of(:institution_id) }

  it { should validate_presence_of(:exam_level_id) }
  it { should validate_numericality_of(:exam_level_id) }

  it { should_not validate_presence_of(:exam_section_id) }
  it { should validate_numericality_of(:exam_section_id) }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:name_url) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:tutor_id) }
  it { should validate_numericality_of(:tutor_id) }

  it { should validate_presence_of(:sorting_order) }

  context 'if active...' do
    before { allow(subject).to receive_messages(active: true) }
    it { should validate_presence_of(:estimated_time_in_seconds) }
  end

  context 'if inactive...' do
    before { allow(subject).to receive_messages(active: false) }
    it { should_not validate_presence_of(:estimated_time_in_seconds) }
  end

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModule).to respond_to(:all_in_order) }
  it { expect(CourseModule).to respond_to(:all_active) }
  it { expect(CourseModule).to respond_to(:all_inactive) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
