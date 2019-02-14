# == Schema Information
#
# Table name: user_groups
#
#  id                           :integer          not null, primary key
#  name                         :string
#  description                  :text
#  tutor                        :boolean          default(FALSE), not null
#  site_admin                   :boolean          default(FALSE), not null
#  created_at                   :datetime
#  updated_at                   :datetime
#  system_requirements_access   :boolean          default(FALSE)
#  content_management_access    :boolean          default(FALSE)
#  stripe_management_access     :boolean          default(FALSE)
#  user_management_access       :boolean          default(FALSE)
#  developer_access             :boolean          default(FALSE)
#  user_group_management_access :boolean          default(FALSE)
#  student_user                 :boolean          default(FALSE)
#  trial_or_sub_required        :boolean          default(FALSE)
#  blocked_user                 :boolean          default(FALSE)
#  marketing_resources_access   :boolean          default(FALSE)
#

require 'rails_helper'

describe UserGroup do
  subject { FactoryBot.build(:user_group) }

  # Constants

  # relationships
  it { should have_many(:users) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:description) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(UserGroup).to respond_to(:all_in_order) }
  it { expect(UserGroup).to respond_to(:all_not_student) }
  it { expect(UserGroup).to respond_to(:all_not_admin) }
  it { expect(UserGroup).to respond_to(:all_student) }
  it { expect(UserGroup).to respond_to(:all_trial_or_sub) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
