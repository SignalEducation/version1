require 'rails_helper'

describe InvoicesController, type: :controller do
  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end

  let(:admin_user_group) { FactoryBot.create(:admin_user_group) }
  let(:admin_user) { FactoryBot.create(:admin_user, user_group_id: admin_user_group.id) }

  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:basic_student) { FactoryBot.create(:basic_student, user_group_id: student_user_group.id) }

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group, exam_body_id: exam_body_1.id) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course, group_id: group_1.id, exam_body_id: exam_body_1.id) }
  let!(:scul_1) { FactoryBot.create(:subject_course_user_log, user_id: basic_student.id, subject_course_id: subject_course_1.id, percentage_complete: 1) }
  let!(:enrollment_1) { FactoryBot.create(:enrollment, user_id: basic_student.id, subject_course_id: subject_course_1.id, exam_body_id: exam_body_1.id, subject_course_user_log_id: scul_1.id) }

  let!(:gbp) { create(:gbp) }
  let!(:uk) { create(:uk, currency: gbp) }
  let!(:uk_vat_code) { create(:vat_code, country: uk) }
  let!(:uk_vat_rate) { create(:vat_rate, vat_code: uk_vat_code) }
  let!(:subscription_plan_gbp_m) {
    create(
        :student_subscription_plan_m,
        currency: gbp, price: 7.50, stripe_guid: 'stripe_plan_guid_m',
        payment_frequency_in_months: 3
    )
  }
  let!(:valid_subscription) { create(:valid_subscription, user: basic_student,
                                     subscription_plan: subscription_plan_gbp_m,
                                     stripe_customer_id: basic_student.stripe_customer_id ) }
  let!(:default_card) { create(:subscription_payment_card, user: basic_student,
                               is_default_card: true, stripe_card_guid: 'guid_222',
                               status: 'card-live' ) }
  let!(:invoice) { create(:invoice, user: basic_student,
                           subscription_id: valid_subscription.id, issued_at: Time.now, vat_rate: uk_vat_rate) }

  context 'Logged in as an admin' do
    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe 'show' do
      it 'should render pdf' do
        get :show, params: { id: invoice.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
      end
    end

    describe 'pdf' do
      it 'should render pdf' do
        get :pdf, params: { id: invoice.id, format: :pdf }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
      end
    end
  end

  context 'Logged in as a valid_subscription_student' do
    before(:each) do
      activate_authlogic
      UserSession.create!(basic_student)
    end

    describe 'index' do
      it 'should render index' do
        get :index, params: { user_id: invoice.user.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
      end
    end

    describe 'pdf' do
      it 'should render pdf' do
        get :pdf, params: { id: invoice.id, format: :pdf }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
      end
    end
  end
end
