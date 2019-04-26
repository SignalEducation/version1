# == Schema Information
#
# Table name: content_pages
#
#  id              :integer          not null, primary key
#  name            :string
#  public_url      :string
#  seo_title       :string
#  seo_description :text
#  text_content    :text
#  h1_text         :string
#  h1_subtext      :string
#  nav_type        :string
#  footer_link     :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  active          :boolean          default(FALSE)
#

require 'rails_helper'

describe ContentPage do

  subject { FactoryBot.build(:content_page) }

  describe 'constants' do
    it { expect(ContentPage.const_defined?(:NAV_OPTIONS)).to eq(true) }
  end

  describe 'relationships' do
    it { should have_many(:external_banners) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(255) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_presence_of(:public_url) }
    it { should validate_length_of(:public_url).is_at_most(255) }
    it { should validate_uniqueness_of(:public_url) }
    it { should validate_presence_of(:seo_title) }
    it { should validate_length_of(:seo_title).is_at_most(255) }
    it { should validate_uniqueness_of(:seo_title) }
    it { should validate_presence_of(:seo_description) }
    it { should_not validate_presence_of(:text_content) }
    it { should_not validate_presence_of(:h1_text) }
    it { should_not validate_presence_of(:h1_subtext) }
    it { should_not validate_presence_of(:nav_type) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
    it { should callback(:remove_empty_banner).before(:validation) }
  end

  describe 'scopes' do
    it { expect(ContentPage).to respond_to(:all_in_order) }
    it { expect(ContentPage).to respond_to(:all_active) }
    it { expect(ContentPage).to respond_to(:for_footer) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
    it { should respond_to(:standard_nav?) }
    it { should respond_to(:transparent_nav?) }
  end


end
