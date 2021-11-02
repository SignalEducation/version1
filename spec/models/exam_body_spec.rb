# == Schema Information
#
# Table name: exam_bodies
#
#  id                                 :integer          not null, primary key
#  name                               :string
#  url                                :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  active                             :boolean          default("false"), not null
#  has_sittings                       :boolean          default("false"), not null
#  preferred_payment_frequency        :integer
#  subscription_page_subheading_text  :string
#  constructed_response_intro_heading :string
#  constructed_response_intro_text    :text
#  logo_image                         :string
#  registration_form_heading          :string
#  login_form_heading                 :string
#  landing_page_h1                    :string
#  landing_page_paragraph             :text
#  has_products                       :boolean          default("false")
#  products_heading                   :string
#  products_subheading                :text
#  products_seo_title                 :string
#  products_seo_description           :string
#  emit_certificate                   :boolean          default("false")
#  pricing_heading                    :string
#  pricing_subheading                 :string
#  pricing_seo_title                  :string
#  pricing_seo_description            :string
#  hubspot_property                   :string
#  new_onboarding                     :boolean          default("false"), not null
#

require 'rails_helper'

describe ExamBody do

  subject { FactoryBot.build(:exam_body) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:url) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
    it { should respond_to(:active) }
    it { should respond_to(:has_sittings) }
    it { should respond_to(:preferred_payment_frequency) }
    it { should respond_to(:subscription_page_subheading_text) }
    it { should respond_to(:constructed_response_intro_heading) }
    it { should respond_to(:constructed_response_intro_text) }
    it { should respond_to(:logo_image) }
    it { should respond_to(:registration_form_heading) }
    it { should respond_to(:login_form_heading) }
    it { should respond_to(:landing_page_h1) }
    it { should respond_to(:landing_page_paragraph) }
    it { should respond_to(:has_products) }
    it { should respond_to(:products_heading) }
    it { should respond_to(:products_subheading) }
    it { should respond_to(:products_seo_title) }
    it { should respond_to(:products_seo_description) }
    it { should respond_to(:hubspot_property) }
  end

  # relationships
  it { should have_one(:group) }
  it { should have_many(:enrollments) }
  it { should have_many(:exam_sittings) }
  it { should have_many(:courses) }
  it { should have_many(:exam_body_user_details) }
  it { should have_many(:subscription_plans) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:landing_page_h1) }
  it { should validate_presence_of(:hubspot_property) }
  it { should validate_presence_of(:landing_page_paragraph) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_uniqueness_of(:hubspot_property) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ExamBody).to respond_to(:all_in_order) }
  it { expect(ExamBody).to respond_to(:all_active) }
  it { expect(ExamBody).to respond_to(:all_with_sittings) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
end
