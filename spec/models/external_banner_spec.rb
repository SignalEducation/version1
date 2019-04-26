# == Schema Information
#
# Table name: external_banners
#
#  id                 :integer          not null, primary key
#  name               :string
#  sorting_order      :integer
#  active             :boolean          default(FALSE)
#  background_colour  :string
#  text_content       :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_sessions      :boolean          default(FALSE)
#  library            :boolean          default(FALSE)
#  subscription_plans :boolean          default(FALSE)
#  footer_pages       :boolean          default(FALSE)
#  student_sign_ups   :boolean          default(FALSE)
#  home_page_id       :integer
#  content_page_id    :integer
#

require 'rails_helper'

describe ExternalBanner do

  subject { FactoryBot.build(:external_banner) }

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
