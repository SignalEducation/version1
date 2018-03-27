# == Schema Information
#
# Table name: invoices
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
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

  let!(:student_user_invoice) { FactoryBot.create(:invoice,
                                  user_id: student_user.id) }
  let!(:tutor_user_invoice) { FactoryBot.create(:invoice,
                                  user_id: tutor_user.id) }
  let!(:content_manager_user_invoice) { FactoryBot.create(:invoice,
                                  user_id: content_manager_user.id) }
  let!(:admin_user_invoice) { FactoryBot.create(:invoice,
                                  user_id: admin_user.id) }
  let!(:comp_user_invoice) { FactoryBot.create(:invoice,
                                  user_id: comp_user.id) }
  let!(:valid_params) { FactoryBot.attributes_for(:invoice) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      xit'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'show/1'" do
      xit'should redirect to sign_in' do
        get :show, id: 1
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe "GET 'index'" do
      xit'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      xit'should see invoice' do
        get :show, id: student_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      xit'should return ERROR and redirect' do
        get :show, id: tutor_user_invoice.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'index'" do
      xit'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      xit'should see invoice' do
        get :show, id: comp_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      xit'should return ERROR and redirect' do
        get :show, id: student_user_invoice.id
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
      xit'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      xit'should see invoice' do
        get :show, id: tutor_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      xit'should return ERROR and redirect' do
        get :show, id: student_user_invoice.id
        expect_bounce_as_not_allowed
      end
    end


  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'index'" do
      xit'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      xit'should see invoice' do
        get :show, id: tutor_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      xit'should return ERROR and redirect' do
        get :show, id: student_user_invoice.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'index'" do
      xit'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      xit'should see invoice' do
        get :show, id: tutor_user_invoice.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      xit'should return ERROR and redirect' do
        get :show, id: student_user_invoice.id
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
      xit'should respond OK' do
        get :index
        expect_index_success_with_model('invoices', 6)
      end
    end

    describe "GET 'show/1'" do
      xit'should see invoice_1' do
        get :show, id: student_user_invoice.id
        expect_show_success_with_model('invoice', student_user_invoice.id)
      end

      # optional - some other object
      xit'should see invoice_2' do
        get :show, id: admin_user_invoice.id
        expect_show_success_with_model('invoice', admin_user_invoice.id)
      end
    end

  end

end
