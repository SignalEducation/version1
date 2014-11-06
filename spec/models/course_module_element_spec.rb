require 'rails_helper'

describe CourseModuleElement do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  CourseModuleElement.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { CourseModuleElement.const_defined?(:CONSTANT_NAME) }

  # relationships
  it { should belong_to(:course_module) }
  it { should belong_to(:course_video) }
  it { should belong_to(:course_quiz) }
  it { should belong_to(:forum_topic) }
  it { should belong_to(:tutor) }
  it { should belong_to(:related_quiz) }
  it { should belong_to(:related_video) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:name_url) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:estimated_time_in_seconds) }

  it { should validate_presence_of(:course_module_id) }
  it { should validate_numericality_of(:course_module_id) }

  it { should validate_presence_of(:course_video_id) }
  it { should validate_numericality_of(:course_video_id) }

  it { should validate_presence_of(:course_quiz_id) }
  it { should validate_numericality_of(:course_quiz_id) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:forum_topic_id) }
  it { should validate_numericality_of(:forum_topic_id) }

  it { should validate_presence_of(:tutor_id) }
  it { should validate_numericality_of(:tutor_id) }

  it { should validate_presence_of(:related_quiz_id) }
  it { should validate_numericality_of(:related_quiz_id) }

  it { should validate_presence_of(:related_video_id) }
  it { should validate_numericality_of(:related_video_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleElement).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
