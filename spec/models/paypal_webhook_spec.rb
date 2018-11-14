# == Schema Information
#
# Table name: paypal_webhooks
#
#  id           :integer          not null, primary key
#  guid         :string
#  event_type   :string
#  payload      :text
#  processed_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  valid        :boolean          default(TRUE)
#

require 'rails_helper'

describe PaypalWebhook do

  # Constants
  #it { expect(PaypalWebhook.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships

  # validation
  it { should validate_presence_of(:guid) }

  it { should validate_presence_of(:payload) }

  it { should validate_presence_of(:processed_at) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(PaypalWebhook).to respond_to(:all_in_order) }

  # class methods
  #it { expect(PaypalWebhook).to respond_to(:method_name) }

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
