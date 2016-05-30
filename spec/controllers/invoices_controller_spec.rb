# == Schema Information
#
# Table name: invoices
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  corporate_customer_id       :integer
#  subscription_transaction_id :integer
#  subscription_id             :integer
#  number_of_users             :integer
#  currency_id                 :integer
#  vat_rate_id                 :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  issued_at                   :datetime
#  stripe_guid                 :string
#  sub_total                   :decimal(, )      default(0.0)
#  total                       :decimal(, )      default(0.0)
#  total_tax                   :decimal(, )      default(0.0)
#  stripe_customer_guid        :string
#  object_type                 :string           default("invoice")
#  payment_attempted           :boolean          default(FALSE)
#  payment_closed              :boolean          default(FALSE)
#  forgiven                    :boolean          default(FALSE)
#  paid                        :boolean          default(FALSE)
#  livemode                    :boolean          default(FALSE)
#  attempt_count               :integer          default(0)
#  amount_due                  :decimal(, )      default(0.0)
#  next_payment_attempt_at     :datetime
#  webhooks_delivered_at       :datetime
#  charge_guid                 :string
#  subscription_guid           :string
#  tax_percent                 :decimal(, )
#  tax                         :decimal(, )
#  original_stripe_data        :text
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe InvoicesController, type: :controller do

  include_context 'users_and_groups_setup'

  # todo: Try to create children for individual_student_user_invoice
  let!(:individual_student_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: individual_student_user.id) }
  let!(:corporate_student_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: corporate_student_user.id) }
  let!(:tutor_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: tutor_user.id) }
  let!(:content_manager_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: content_manager_user.id) }
  let!(:blogger_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: blogger_user.id) }
  let!(:corporate_customer_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: corporate_customer_user.id) }
  let!(:forum_manager_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: forum_manager_user.id) }
  let!(:admin_user_invoice) { FactoryGirl.create(:invoice,
                                  user_id: admin_user.id) }
  let!(:valid_params) { FactoryGirl.attributes_for(:invoice) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to sign_in' do
        get :show, id: 1
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: individual_student_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: corporate_student_user_invoice.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: tutor_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: individual_student_user_invoice.id
        expect_bounce_as_not_allowed
      end
    end


  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: corporate_student_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: individual_student_user_invoice.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: corporate_customer_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: individual_student_user_invoice.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: blogger_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: corporate_student_user_invoice.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: forum_manager_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: corporate_student_user_invoice.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice' do
        get :show, id: content_manager_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should return ERROR and redirect' do
        get :show, id: corporate_student_user_invoice.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('invoices', 8)
      end
    end

    describe "GET 'show/1'" do
      it 'should see invoice_1' do
        get :show, id: individual_student_user_invoice.id
        expect_show_success_with_model('invoice', individual_student_user_invoice.id)
      end

      # optional - some other object
      it 'should see invoice_2' do
        get :show, id: admin_user_invoice.id
        expect_show_success_with_model('invoice', admin_user_invoice.id)
      end
    end

  end

end
