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

  describe 'constants' do
    it { expect(StripeApiEvent.const_defined?(:KNOWN_API_VERSIONS)).to eq(true) }
    it { expect(StripeApiEvent.const_defined?(:KNOWN_PAYLOAD_TYPES)).to eq(true) }
    it { expect(StripeApiEvent.const_defined?(:DELAYED_TYPES)).to eq(true) }
  end

  describe 'relationships' do
    it { should have_many(:charges)}
  end

  describe 'validations' do
    it { should validate_presence_of(:guid) }
    xit { should validate_uniqueness_of(:guid) }
    xit { should validate_length_of(:guid).is_at_most(255) }
    it { should validate_inclusion_of(:api_version).in_array(StripeApiEvent::KNOWN_API_VERSIONS) }
    it { should validate_length_of(:api_version).is_at_most(255) }
    it { should validate_presence_of(:payload) }
  end

  describe 'callbacks' do
    it { should callback(:set_default_values).before(:validation).on(:create) }
    it { should callback(:get_data_from_stripe).before(:validation).on(:create) }
    it { should callback(:disseminate_payload).after(:create) }
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(StripeApiEvent).to respond_to(:all_in_order) }
  end

  describe 'instance methods' do
    it { should respond_to(:destroyable?) }
    it { should respond_to(:disseminate_payload) }
    it { should respond_to(:get_data_from_stripe) }
  end
end
