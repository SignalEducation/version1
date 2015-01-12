# == Schema Information
#
# Table name: student_exam_tracks
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  exam_level_id                   :integer
#  exam_section_id                 :integer
#  latest_course_module_element_id :integer
#  exam_schedule_id                :integer
#  created_at                      :datetime
#  updated_at                      :datetime
#  session_guid                    :string(255)
#  course_module_id                :integer
#  jumbo_quiz_taken                :boolean          default(FALSE)
#

require 'rails_helper'

describe StudentExamTrack do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  StudentExamTrack.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()StudentExamTrack.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:exam_level) }
  it { should belong_to(:exam_section) }
  it { should belong_to(:latest_course_module_element) }
  xit { should belong_to(:exam_schedule) }

  # validation
  it { should_not validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:exam_level_id) }
  it { should validate_numericality_of(:exam_level_id) }

  it { should validate_presence_of(:exam_section_id) }
  it { should validate_numericality_of(:exam_section_id) }

  it { should_not validate_presence_of(:latest_course_module_element_id) }
  it { should validate_numericality_of(:latest_course_module_element_id) }

  it { should_not validate_presence_of(:exam_schedule_id) }
  it { should validate_numericality_of(:exam_schedule_id) }

  it { should validate_presence_of(:session_guid) }

  it { should validate_presence_of(:course_module_id) }
  it { should validate_numericality_of(:course_module_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(StudentExamTrack).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
