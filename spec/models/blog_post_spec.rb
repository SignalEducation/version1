# == Schema Information
#
# Table name: blog_posts
#
#  id                 :integer          not null, primary key
#  home_page_id       :integer
#  sorting_order      :integer
#  title              :string
#  description        :text
#  url                :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :bigint(8)
#  image_updated_at   :datetime
#

require 'rails_helper'

describe BlogPost do

  describe 'relationships' do
    it { should belong_to(:home_page) }
  end

  describe 'validations' do
    it { should validate_presence_of(:home_page_id).on(:update) }
    it { should validate_numericality_of(:home_page_id).on(:update) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:url) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(BlogPost).to respond_to(:all_in_order) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
  end

end
