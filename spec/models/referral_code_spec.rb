require 'rails_helper'

describe ReferralCode do

  let!(:tutor) { FactoryGirl.create(:tutor_user) }
  subject { FactoryGirl.create(:referral_code) }

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
  it { should have_many(:referred_users) }

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

end
