# == Schema Information
#
# Table name: content_page_sections
#
#  id                :integer          not null, primary key
#  content_page_id   :integer
#  text_content      :text
#  panel_colour      :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  subject_course_id :integer
#  sorting_order     :integer
#

require 'rails_helper'

describe ContentPageSection do

  describe 'relationships' do
    it { should belong_to(:content_page) }
    it { should belong_to(:subject_course) }
  end

  describe 'validations' do
    it { should validate_presence_of(:content_page_id).on(:update) }
    it { should validate_presence_of(:text_content) }
    it { should validate_presence_of(:panel_colour) }
    it { should validate_presence_of(:sorting_order) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(ContentPageSection).to respond_to(:all_in_order) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
  end

end
