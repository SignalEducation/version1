# == Schema Information
#
# Table name: user_activity_logs
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  session_guid              :string(255)
#  signed_in                 :boolean          default(FALSE), not null
#  original_uri              :text
#  controller_name           :string(255)
#  action_name               :string(255)
#  params                    :text
#  alert_level               :integer          default(0)
#  created_at                :datetime
#  updated_at                :datetime
#  ip_address                :string(255)
#  browser                   :string(255)
#  operating_system          :string(255)
#  phone                     :boolean          default(FALSE), not null
#  tablet                    :boolean          default(FALSE), not null
#  computer                  :boolean          default(FALSE), not null
#  guid                      :string(255)
#  ip_address_id             :integer
#  browser_version           :string(255)
#  raw_user_agent            :string(255)
#  session_landing_page      :string(255)
#  post_sign_up_redirect_url :string(255)
#

require 'rails_helper'

describe UserActivityLog do

  # attr-accessible
  black_list = %w(id created_at updated_at ip_address_id browser_version)
  UserActivityLog.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(UserActivityLog.const_defined?(:ALERT_LEVELS)).to eq(true) }

  # relationships
  it { should belong_to(:tracked_ip_address) }
  it { should belong_to(:user) }

  # validation
  it { should_not validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:session_guid) }

  it { should validate_presence_of(:original_uri) }

  it { should validate_presence_of(:controller_name) }

  it { should validate_presence_of(:action_name) }

  it { should validate_presence_of(:ip_address) }

  # it { should validate_presence_of(:alert_level) }
  # it { should validate_numericality_of(:alert_level) }

  it { should validate_presence_of(:guid) }
  it { should validate_uniqueness_of(:guid) }

  # callbacks
  it { should callback(:add_to_rails_logger).after(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(UserActivityLog).to respond_to(:all_in_order) }
  it { expect(UserActivityLog).to respond_to(:for_session_guid) }
  it { expect(UserActivityLog).to respond_to(:for_unknown_users) }

  # class methods
  it { expect(UserActivityLog).to respond_to(:assign_user_to_session_guid) }
  it { expect(UserActivityLog).to respond_to(:for_user_or_session) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:display_class) }

end
