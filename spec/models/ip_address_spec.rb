# == Schema Information
#
# Table name: ip_addresses
#
#  id          :integer          not null, primary key
#  ip_address  :string
#  latitude    :float
#  longitude   :float
#  country_id  :integer
#  alert_level :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

describe IpAddress do

  # attr-accessible
  black_list = %w(id created_at updated_at latitude longitude)
  IpAddress.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  subject { FactoryGirl.build(:ip_address) }

  # Constants
  #it { expect(IpAddress.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:country) }
  it { should have_many(:user_activity_logs) }

  # validation
  it { should validate_presence_of(:ip_address) }
  it { should validate_uniqueness_of(:ip_address) }
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
