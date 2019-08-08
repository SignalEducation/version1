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

require 'rails_helper'

describe ExamBody do

  subject { FactoryBot.build(:exam_body) }

  # Constants

  # relationships
  it { should have_many(:enrollments) }
  it { should have_many(:exam_sittings) }
  it { should have_many(:subject_courses) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should validate_presence_of(:url) }

  it { should validate_presence_of(:landing_page_h1) }

  it { should validate_presence_of(:landing_page_paragraph) }


  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ExamBody).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
end
