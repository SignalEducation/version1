# == Schema Information
#
# Table name: course_notes
#
#  id                       :integer          not null, primary key
#  course_step_id :integer
#  name                     :string(255)
#  web_url                  :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  upload_file_name         :string(255)
#  upload_content_type      :string(255)
#  upload_file_size         :integer
#  upload_updated_at        :datetime
#  destroyed_at             :datetime
#

require 'rails_helper'
require 'concerns/archivable_spec.rb'

describe CourseNote do
  describe 'relationships' do
    it { should belong_to(:course_step) }
  end

  describe 'validations' do
    it { should validate_presence_of(:course_step_id).on(:update) }
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(CourseNote).to respond_to(:all_in_order) }
    it { expect(CourseNote).to respond_to(:all_destroyed) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
  end

  describe 'Concern' do
    it_behaves_like 'archivable'
  end
end