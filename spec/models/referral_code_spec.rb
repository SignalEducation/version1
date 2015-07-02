# == Schema Information
#
# Table name: referral_codes
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  code       :string(7)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'support/users_and_groups_setup'

describe ReferralCode do
  include_context 'users_and_groups_setup'

  subject { FactoryGirl.create(:referral_code, user_id: tutor_user.id) }

  # attr-accessible
  black_list = %w(id code created_at updated_at)
  ReferralCode.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # relationships
  it { should belong_to(:user) }
  it { should have_many(:referred_signups) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }
  it { should validate_uniqueness_of(:user_id) }

  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:code) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:create_code).before(:validation).on(:create) }

  # scopes
  it { expect(ReferralCode).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:payed_referred_signups) }
  it { should respond_to(:unpayed_referred_signups) }
  it { should respond_to(:referred_signups_ready_for_paying) }

  describe "user groups" do
    it "should create valid referral code for students, corporate students and tutors" do
      [individual_student_user, corporate_student_user, tutor_user].each do |allowed_user|
        expect(allowed_user.create_referral_code).to be_valid
      end
    end

    it "should not create valid referral code for not allowed types of users" do
      [content_manager_user, corporate_customer_user, forum_manager_user, admin_user].each do |not_allowed_user|
        expect(not_allowed_user.create_referral_code).not_to be_valid
      end
    end
  end
end
