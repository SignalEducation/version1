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
#  verified     :boolean          default(TRUE)
#

require 'rails_helper'

describe PaypalWebhook do
  # validation
  it { should validate_presence_of(:guid) }

  it { should validate_presence_of(:payload) }

  it { should validate_presence_of(:event_type) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:process_sale_completed) }
  it { should respond_to(:process_sale_denied) }
  it { should respond_to(:process_subscription_cancelled) }
  it { should respond_to(:reprocess) }

end
