require 'rails_helper'
require 'support/users_and_groups_setup'

RSpec.describe OperationalMailer, :type => :mailer do

  include_context 'users_and_groups_setup'

  let!(:reset_user) { FactoryGirl.create(:user_with_reset_requested)}

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  it 'activate account' do
    OperationalMailer.activate_account(inactive_individual_student_user).deliver
    expect_delivery_to_from_and_subject_success(inactive_individual_student_user.email, 'operational','activate_account')
  end

  it 'your password has changed' do
    OperationalMailer.your_password_has_changed(individual_student_user).deliver
    expect_delivery_to_from_and_subject_success(individual_student_user.email, 'operational','your_password_has_changed')
  end

  it 'reset your password' do
    OperationalMailer.reset_your_password(reset_user).deliver
    expect_delivery_to_from_and_subject_success(reset_user.email, 'operational','reset_your_password')
  end

end
