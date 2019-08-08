# == Schema Information
#
# Table name: exam_bodies
#
#  id                                 :integer          not null, primary key
#  name                               :string
#  url                                :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  active                             :boolean          default(FALSE), not null
#  has_sittings                       :boolean          default(FALSE), not null
#  preferred_payment_frequency        :integer
#  subscription_page_subheading_text  :string
#  constructed_response_intro_heading :string
#  constructed_response_intro_text    :text
#  logo_image                         :string
#  registration_form_heading          :string
#  login_form_heading                 :string
#  landing_page_h1                    :string
#  landing_page_paragraph             :text
#

FactoryBot.define do
  factory :exam_body do
    sequence(:name)           { |n| "ACCA #{n}" }
    url { 'accaglobal.com/ie/en.html' }
    active                    { true }
    constructed_response_intro_heading {'Intro Heading'}
    constructed_response_intro_text {'Intro Text'}
    landing_page_h1 {'Header H1'}
    landing_page_paragraph {'Header P Text'}
  end
end
