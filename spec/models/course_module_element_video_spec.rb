require 'rails_helper'

describe CourseModuleElementVideo do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  CourseModuleElementVideo.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { CourseModuleElementVideo.const_defined?(:CONSTANT_NAME) }

  # relationships
  it { should belong_to(:course_module_element) }
  it { should belong_to(:raw_video_file) }
  it { should belong_to(:tutor) }

  # validation
  it { should validate_presence_of(:course_module_element_id) }
  it { should validate_numericality_of(:course_module_element_id) }

  it { should validate_presence_of(:raw_video_file_id) }
  it { should validate_numericality_of(:raw_video_file_id) }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:run_time_in_seconds) }

  it { should validate_presence_of(:tutor_id) }
  it { should validate_numericality_of(:tutor_id) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:tags) }

  it { should validate_presence_of(:difficulty_level) }

  it { should validate_presence_of(:estimated_study_time_seconds) }

  it { should validate_presence_of(:transcript) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleElementVideo).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
