# == Schema Information
#
# Table name: home_pages
#
#  id                            :integer          not null, primary key
#  seo_title                     :string
#  seo_description               :string
#  subscription_plan_category_id :integer
#  public_url                    :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  course_id                     :integer
#  custom_file_name              :string
#  group_id                      :integer
#  name                          :string
#  home                          :boolean          default("false")
#  logo_image                    :string
#  footer_link                   :boolean          default("false")
#  mailchimp_list_guid           :string
#  registration_form             :boolean          default("false"), not null
#  pricing_section               :boolean          default("false"), not null
#  seo_no_index                  :boolean          default("false"), not null
#  login_form                    :boolean          default("false"), not null
#  preferred_payment_frequency   :integer
#  header_h1                     :string
#  header_paragraph              :string
#  registration_form_heading     :string
#  login_form_heading            :string
#  footer_option                 :string           default("white")
#  video_guid                    :string
#  header_h3                     :string
#  background_image              :string
#  usp_section                   :boolean          default("true")
#  stats_content                 :text
#  course_description            :text
#  header_description            :text
#  onboarding_welcome_heading    :string
#  onboarding_welcome_subheading :text
#  onboarding_level_heading      :string
#  onboarding_level_subheading   :text
#

require 'rails_helper'

describe HomePage do

  subject { FactoryBot.build(:home_page) }

  describe 'Should Respond' do
    it { should respond_to(:seo_title) }
    it { should respond_to(:seo_description) }
    it { should respond_to(:subscription_plan_category_id) }
    it { should respond_to(:public_url) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
    it { should respond_to(:course_id) }
    it { should respond_to(:custom_file_name) }
    it { should respond_to(:group_id) }
    it { should respond_to(:name) }
    it { should respond_to(:home) }
    it { should respond_to(:logo_image) }
    it { should respond_to(:footer_link) }
    it { should respond_to(:mailchimp_list_guid) }
    it { should respond_to(:registration_form) }
    it { should respond_to(:pricing_section) }
    it { should respond_to(:seo_no_index) }
    it { should respond_to(:login_form) }

    it { should respond_to(:preferred_payment_frequency) }
    it { should respond_to(:header_h1) }
    it { should respond_to(:header_paragraph) }
    it { should respond_to(:registration_form_heading) }
    it { should respond_to(:login_form_heading) }
    it { should respond_to(:footer_option) }
    it { should respond_to(:video_guid) }
    it { should respond_to(:header_h3) }
    it { should respond_to(:background_image) }
    it { should respond_to(:usp_section) }
    it { should respond_to(:stats_content) }
    it { should respond_to(:course_description) }
    it { should respond_to(:header_description) }
    it { should respond_to(:onboarding_welcome_heading) }
    it { should respond_to(:onboarding_welcome_subheading) }
    it { should respond_to(:onboarding_level_heading) }
    it { should respond_to(:onboarding_level_subheading) }
  end

  # relationships
  it { should belong_to(:subscription_plan_category) }
  it { should belong_to(:group) }
  it { should belong_to(:course) }
  it { should have_many(:blog_posts) }
  it { should have_many(:external_banners) }
  it { should have_many(:users) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:seo_title) }
  it { should validate_uniqueness_of(:seo_title) }
  it { should validate_length_of(:seo_title).is_at_most(255) }

  it { should validate_presence_of(:seo_description) }
  it { should validate_length_of(:seo_description).is_at_most(255) }

  it { should validate_presence_of(:public_url) }
  it { should validate_uniqueness_of(:public_url) }
  it { should validate_length_of(:public_url).is_at_most(255) }

  it { should_not validate_presence_of(:custom_file_name) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(HomePage).to respond_to(:all_in_order) }
  it { expect(HomePage).to respond_to(:for_courses) }
  it { expect(HomePage).to respond_to(:for_groups) }
  it { expect(HomePage).to respond_to(:for_footer) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:default_home_page) }
  it { should respond_to(:course) }

end
