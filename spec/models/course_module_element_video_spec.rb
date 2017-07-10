# == Schema Information
#
# Table name: course_module_element_videos
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  created_at               :datetime
#  updated_at               :datetime
#  destroyed_at             :datetime
#  video_id                 :string
#  duration                 :float
#  vimeo_guid               :string
#

require 'rails_helper'

describe CourseModuleElementVideo do

  # attr-accessible
  black_list = %w(id created_at updated_at destroyed_at)
  CourseModuleElementVideo.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:course_module_element) }

  # validation
  it { should validate_presence_of(:course_module_element_id).on(:update) }

  it { should validate_presence_of(:vimeo_guid) }
  it { should validate_length_of(:vimeo_guid).is_at_most(255) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleElementVideo).to respond_to(:all_in_order) }
  it { expect(CourseModuleElementVideo).to respond_to(:all_destroyed) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:parent) }

end
