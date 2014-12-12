# == Schema Information
#
# Table name: course_module_element_resources
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  name                     :string(255)
#  description              :text
#  web_url                  :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  upload_file_name         :string(255)
#  upload_content_type      :string(255)
#  upload_file_size         :integer
#  upload_updated_at        :datetime
#

require 'rails_helper'

describe CourseModuleElementResource do

  # attr-accessible
  black_list = %w(id created_at updated_at upload_file_name upload_content_type upload_file_size upload_updated_at)
  CourseModuleElementResource.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()CourseModuleElementResource.const_defined?(:CONSTANT_NAME).to eq(true) }

  # relationships
  it { should belong_to(:course_module_element) }

  # validation
  it { should validate_presence_of(:course_module_element_id) }
  it { should validate_numericality_of(:course_module_element_id) }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:description) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleElementResource).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
