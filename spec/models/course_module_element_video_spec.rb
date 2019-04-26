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

  describe 'relationships' do
    it { should belong_to(:course_module_element) }
  end

  describe 'validations' do
    it { should validate_presence_of(:course_module_element_id).on(:update) }
    it { should validate_presence_of(:vimeo_guid) }
    it { should validate_length_of(:vimeo_guid).is_at_most(255) }
    it { should validate_presence_of(:duration) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(CourseModuleElementVideo).to respond_to(:all_in_order) }
    it { expect(CourseModuleElementVideo).to respond_to(:all_destroyed) }
  end

  describe 'instance methods' do
    it { should respond_to(:parent) }
    it { should respond_to(:destroyable?) }
  end

end
