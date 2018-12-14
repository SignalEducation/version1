# == Schema Information
#
# Table name: orders
#
#  id                        :integer          not null, primary key
#  product_id                :integer
#  subject_course_id         :integer
#  user_id                   :integer
#  stripe_guid               :string
#  stripe_customer_id        :string
#  live_mode                 :boolean          default(FALSE)
#  current_status            :string
#  coupon_code               :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  stripe_order_payment_data :text
#  mock_exam_id              :integer
#  terms_and_conditions      :boolean          default(FALSE)
#  reference_guid            :string
#  paypal_guid               :string
#  paypal_status             :string
#

require 'rails_helper'

describe OrdersController, type: :controller do

  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:valid_subscription_student) { FactoryBot.create(:valid_subscription_student, user_group_id: student_user_group.id) }
  let!(:valid_subscription_student_access) { FactoryBot.create(:trial_student_access, user_id: valid_subscription_student.id) }
  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:mock_exam_1) { FactoryBot.create(:mock_exam) }
  let!(:product_1) { FactoryBot.create(:product, currency_id: gbp.id, mock_exam_id: mock_exam_1.id, price: '99.9') }
  let!(:product_2) { FactoryBot.create(:product, currency_id: gbp.id) }
  let!(:order_1) { FactoryBot.create(:order, product_id: product_1.id) }
  let!(:order_2) { FactoryBot.create(:order) }
  let!(:valid_params) { FactoryBot.attributes_for(:order) }


  context 'Logged in as a valid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see order_1' do
        get :show, id: order_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see order_2' do
        get :show, id: order_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, product_id: product_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
      end
    end

    describe "POST 'create'" do
      #TODO fix this to test stripe orders
      xit 'should report OK for valid params' do
        post :create, order: valid_params
        expect_create_success_with_model('order', orders_url)
      end

      xit 'should report error for invalid params' do
        post :create, order: {valid_params.keys.first => ''}
        expect_create_error_with_model('order')
      end
    end

  end

end
