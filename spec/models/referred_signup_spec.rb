require 'rails_helper'

describe ReferredSignup do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ReferredSignup.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(ReferredSignup.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:referral_code) }
  it { should belong_to(:user) }
  it { should belong_to(:subscription) }

  # validation
  it { should validate_presence_of(:referral_code_id) }
  it { should validate_numericality_of(:referral_code_id) }
  it { should validate_uniqueness_of(:referral_code_id).scoped_to(:user_id).with_message(I18n.t('models.referred_signups.user_can_be_referred_only_once')) }

  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_numericality_of(:subscription_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ReferredSignup).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
