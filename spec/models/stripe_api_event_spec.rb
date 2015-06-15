# == Schema Information
#
# Table name: stripe_api_events
#
#  id            :integer          not null, primary key
#  guid          :string
#  api_version   :string
#  payload       :text
#  processed     :boolean          default(FALSE), not null
#  processed_at  :datetime
#  error         :boolean          default(FALSE), not null
#  error_message :string
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

describe StripeApiEvent do

  # attr-accessible
  black_list = %w(id created_at updated_at payload error_message processed_at processed error)
  StripeApiEvent.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end
  it { should allow_mass_assignment_of(:profile_url) }

  # Constants
  it { expect(StripeApiEvent.const_defined?(:KNOWN_API_VERSIONS)).to eq(true) }
  it { expect(StripeApiEvent.const_defined?(:KNOWN_PAYLOAD_TYPES)).to eq(true) }

  # relationships

  # validation
  it { should validate_presence_of(:guid) }
  it { should validate_uniqueness_of(:guid) }
  it { should validate_length_of(:guid).is_at_most(255) }

  it { should validate_inclusion_of(:api_version).in_array(StripeApiEvent::KNOWN_API_VERSIONS) }
  it { should validate_length_of(:api_version).is_at_most(255) }

  # callbacks
  it { should callback(:set_default_values).before(:validation).on(:create) }
  it { should callback(:get_data_from_stripe).before(:validation).on(:create) }
  it { should callback(:disseminate_payload).after(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(StripeApiEvent).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:disseminate_payload) }
  it { should respond_to(:get_data_from_stripe) }

end
