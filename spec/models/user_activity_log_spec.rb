# == Schema Information
#
# Table name: user_activity_logs
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  session_guid    :string(255)
#  signed_in       :boolean          default(FALSE), not null
#  original_uri    :string(255)
#  controller_name :string(255)
#  action_name     :string(255)
#  params          :text
#  alert_level     :integer          default(0)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

describe UserActivityLog do

  # attr-accessible
  black_list = %w(id created_at updated_at)
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
  it { should belong_to(:user) }

  # validation
  it { should_not validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:session_guid) }
  it { should validate_numericality_of(:session_guid) }

  it { should validate_presence_of(:original_uri) }

  it { should validate_presence_of(:controller_name) }

  it { should validate_presence_of(:action_name) }

  it { should validate_presence_of(:alert_level) }
  it { should validate_numericality_of(:alert_level) }

  # callbacks
  it { should callback(:add_to_rails_logger).after(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(UserActivityLog).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
