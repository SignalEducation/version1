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
#  course_id :integer
#  sorting_order     :integer
#

require 'rails_helper'

describe ContentPageSection do

  describe 'relationships' do
    it { should belong_to(:content_page) }
    it { should belong_to(:course) }
  end

  describe 'validations' do
    it 'is invalid without a product' do
      expect(build_stubbed(:content_page_section, content_page: nil)).not_to be_valid
    end

    it { should validate_presence_of(:text_content) }
    it { should validate_presence_of(:panel_colour) }
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
