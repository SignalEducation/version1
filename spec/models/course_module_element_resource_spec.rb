# == Schema Information
#
# Table name: course_module_element_resources
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  name                     :string
#  web_url                  :string
#  created_at               :datetime
#  updated_at               :datetime
#  upload_file_name         :string
#  upload_content_type      :string
#  upload_file_size         :bigint(8)
#  upload_updated_at        :datetime
#  destroyed_at             :datetime
#

require 'rails_helper'

describe CourseModuleElementResource do
  describe 'relationships' do
    it { should belong_to(:course_module_element) }
  end

  describe 'validations' do
    it { should validate_presence_of(:course_module_element_id).on(:update) }
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(CourseModuleElementResource).to respond_to(:all_in_order) }
    it { expect(CourseModuleElementResource).to respond_to(:all_destroyed) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
  end
end
