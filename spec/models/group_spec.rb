# == Schema Information
#
# Table name: groups
#
#  id                            :integer          not null, primary key
#  name                          :string
#  name_url                      :string
#  active                        :boolean          default("false"), not null
#  sorting_order                 :integer
#  description                   :text
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  destroyed_at                  :datetime
#  image_file_name               :string
#  image_content_type            :string
#  image_file_size               :integer
#  image_updated_at              :datetime
#  background_image_file_name    :string
#  background_image_content_type :string
#  background_image_file_size    :integer
#  background_image_updated_at   :datetime
#  exam_body_id                  :bigint
#  background_colour             :string
#  seo_title                     :string
#  seo_description               :string
#  short_description             :string
#  onboarding_level_subheading   :text
#  onboarding_level_heading      :string
#  tab_view                      :boolean          default("false"), not null
#  disclaimer                    :text
#

require 'rails_helper'
require 'concerns/archivable_spec.rb'

describe Group do
  subject { FactoryBot.build(:group) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:name_url) }
    it { should respond_to(:active) }
    it { should respond_to(:sorting_order) }
    it { should respond_to(:description) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
    it { should respond_to(:destroyed_at) }
    it { should respond_to(:image_file_name) }
    it { should respond_to(:image_content_type) }
    it { should respond_to(:image_file_size) }
    it { should respond_to(:image_updated_at) }
    it { should respond_to(:background_image_file_name) }
    it { should respond_to(:background_image_content_type) }
    it { should respond_to(:background_image_file_size) }
    it { should respond_to(:background_image_updated_at) }
    it { should respond_to(:background_colour) }
    it { should respond_to(:exam_body_id) }
    it { should respond_to(:seo_title) }
    it { should respond_to(:seo_description) }
    it { should respond_to(:short_description) }
    it { should respond_to(:onboarding_level_subheading) }
    it { should respond_to(:onboarding_level_heading) }
    it { should respond_to(:tab_view) }
    it { should respond_to(:category_id) }
    it { should respond_to(:sub_category_id) }
  end

  # relationships
  it { should belong_to(:category) }
  it { should belong_to(:sub_category) }
  it { should have_many(:courses) }
  it { should have_many(:home_pages) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url) }
  it { should validate_length_of(:name_url).is_at_most(255) }

  it { should validate_presence_of(:description) }

  it { should_not validate_presence_of(:image) }
  it { should_not validate_presence_of(:background_image) }

  # callbacks
  it { should callback(:filter_disclaimer_text).before(:save) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Group).to respond_to(:all_in_order) }
  it { expect(Group).to respond_to(:all_active) }
  it { expect(Group).to respond_to(:with_active_body) }

  # class methods

  # instance methods
  it { should respond_to(:active_children) }
  it { should respond_to(:children) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }

  describe 'Concern' do
    it_behaves_like 'archivable'
  end
end
