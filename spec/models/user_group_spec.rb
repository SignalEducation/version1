# == Schema Information
#
# Table name: user_groups
#
#  id                           :integer          not null, primary key
#  name                         :string
#  description                  :text
#  individual_student           :boolean          default(FALSE), not null
#  tutor                        :boolean          default(FALSE), not null
#  content_manager              :boolean          default(FALSE), not null
#  blogger                      :boolean          default(FALSE), not null
#  site_admin                   :boolean          default(FALSE), not null
#  created_at                   :datetime
#  updated_at                   :datetime
#  complimentary                :boolean          default(FALSE)
#  customer_support             :boolean          default(FALSE)
#  marketing_support            :boolean          default(FALSE)
#  system_requirements_access   :boolean          default(FALSE)
#  content_management_access    :boolean          default(FALSE)
#  stripe_management_access     :boolean          default(FALSE)
#  user_management_access       :boolean          default(FALSE)
#  developer_access             :boolean          default(FALSE)
#  home_pages_access            :boolean          default(FALSE)
#  user_group_management_access :boolean          default(FALSE)
#  student_user                 :boolean          default(FALSE)
#  trial_or_sub_required        :boolean          default(FALSE)
#  blocked_user                 :boolean          default(FALSE)
#

require 'rails_helper'

describe UserGroup do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  UserGroup.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  subject { FactoryGirl.build(:user_group) }

  # Constants
  it { expect(UserGroup.const_defined?(:FEATURES)).to eq(true) }

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

  # class methods
  it { expect(UserGroup).to respond_to(:default_admin_user_group) }
  it { expect(UserGroup).to respond_to(:default_complimentary_user_group) }
  it { expect(UserGroup).to respond_to(:default_student_user_group) }
  it { expect(UserGroup).to respond_to(:default_tutor_user_group) }
  it { expect(UserGroup).to respond_to(:default_content_manager_user_group) }
  it { expect(UserGroup).to respond_to(:default_customer_support_user_group) }
  it { expect(UserGroup).to respond_to(:default_marketing_support_user_group) }

  # instance methods
  it { should respond_to(:destroyable?) }

end
