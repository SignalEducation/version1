# == Schema Information
#
# Table name: ip_addresses
#
#  id           :integer          not null, primary key
#  ip_address   :string(255)
#  latitude     :float
#  longitude    :float
#  country_id   :integer
#  alert_level  :integer
#  created_at   :datetime
#  updated_at   :datetime
#  rechecked_on :datetime
#

require 'rails_helper'

describe IpAddress do
  subject { FactoryBot.build(:ip_address) }

  # Constants

  # relationships
  it { should belong_to(:country) }

  # validation
  it { should validate_presence_of(:ip_address) }
  it { should validate_uniqueness_of(:ip_address).case_insensitive }
  it { should validate_length_of(:ip_address).is_at_most(255) }

  it { should validate_presence_of(:latitude) }

  it { should validate_presence_of(:longitude) }

  # callbacks
  it { should callback(:geo_locate).before(:validation).on(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(IpAddress).to respond_to(:all_in_order) }

  # class methods
  it { expect(IpAddress).to respond_to(:get_country) }

  # instance methods
  it { should respond_to(:destroyable?) }

end
