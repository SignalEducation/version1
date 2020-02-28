# == Schema Information
#
# Table name: external_banners
#
#  id                 :integer          not null, primary key
#  name               :string
#  sorting_order      :integer
#  active             :boolean          default("false")
#  background_colour  :string
#  text_content       :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_sessions      :boolean          default("false")
#  library            :boolean          default("false")
#  subscription_plans :boolean          default("false")
#  footer_pages       :boolean          default("false")
#  student_sign_ups   :boolean          default("false")
#  home_page_id       :integer
#  content_page_id    :integer
#  exam_body_id       :integer
#  basic_students     :boolean          default("false")
#  paid_students      :boolean          default("false")
#

require 'rails_helper'

describe ExternalBanner do

  subject { FactoryBot.build(:external_banner) }

  describe 'Should Respond' do
    it { should respond_to(:name) }
    it { should respond_to(:sorting_order) }
    it { should respond_to(:active) }
    it { should respond_to(:background_colour) }
    it { should respond_to(:text_content) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
    it { should respond_to(:exam_body_id) }
    it { should respond_to(:basic_students) }
    it { should respond_to(:paid_students) }
  end

  # Constants
  it { expect(ExternalBanner.const_defined?(:BANNER_CONTROLLERS)).to eq(true) }

  # relationships

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should validate_presence_of(:sorting_order) }
  it { should validate_numericality_of(:sorting_order) }

  it { should validate_presence_of(:background_colour) }

  it { should validate_presence_of(:text_content) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ExternalBanner).to respond_to(:all_active) }
  it { expect(ExternalBanner).to respond_to(:all_in_order) }
  it { expect(ExternalBanner).to respond_to(:all_without_parent) }
  it { expect(ExternalBanner).to respond_to(:for_home_page) }
  it { expect(ExternalBanner).to respond_to(:for_content_page) }
  it { expect(ExternalBanner).to respond_to(:render_for) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
