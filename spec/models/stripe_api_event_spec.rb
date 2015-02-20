# == Schema Information
#
# Table name: stripe_api_events
#
#  id            :integer          not null, primary key
#  guid          :string(255)
#  api_version   :string(255)
#  payload       :text
#  processed     :boolean          default(FALSE), not null
#  processed_at  :datetime
#  error         :boolean          default(FALSE), not null
#  error_message :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

describe StripeApiEvent do

  # attr-accessible
  black_list = %w(id created_at updated_at error_message processed_at)
  StripeApiEvent.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(StripeApiEvent.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships

  # validation
  it { should validate_presence_of(:guid) }
  it { should validate_uniqueness_of(:guid) }

  it { should validate_presence_of(:api_version) }

  it { should validate_presence_of(:payload) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(StripeApiEvent).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
