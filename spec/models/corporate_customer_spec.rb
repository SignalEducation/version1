# == Schema Information
#
# Table name: corporate_customers
#
#  id                   :integer          not null, primary key
#  organisation_name    :string(255)
#  address              :text
#  country_id           :integer
#  payments_by_card     :boolean          default(FALSE), not null
#  is_university        :boolean          default(FALSE), not null
#  owner_id             :integer
#  stripe_customer_guid :string(255)
#  can_restrict_content :boolean          default(FALSE), not null
#  created_at           :datetime
#  updated_at           :datetime
#

require 'rails_helper'

describe CorporateCustomer do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  CorporateCustomer.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(CorporateCustomer.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  xit { should have_many(:corporate_customer_prices) }
  xit { should have_many(:corporate_customer_users) }
  it { should have_many(:course_module_element_user_logs) }
  it { should have_many(:invoices) }
  it { should belong_to(:country) }
  it { should belong_to(:owner) }
  it { should have_many(:students) }
  it { should have_many(:subscriptions) }

  # validation
  it { should validate_presence_of(:organisation_name) }

  it { should validate_presence_of(:address) }

  it { should validate_presence_of(:country_id) }
  it { should validate_numericality_of(:country_id) }

  it { should validate_presence_of(:owner_id) }
  it { should validate_numericality_of(:owner_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CorporateCustomer).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
