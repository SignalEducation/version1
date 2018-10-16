require 'rails_helper'

RSpec.describe SubscriptionManagementController, :type => :controller do

  let(:user_management_user_group) { FactoryBot.create(:user_management_user_group) }
  let(:user_management_user) { FactoryBot.create(:user_management_user, user_group_id: user_management_user_group.id) }
  let!(:user_management_student_access) { FactoryBot.create(:complimentary_student_access, user_id: user_management_user.id) }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:valid_subscription_student) { FactoryBot.create(:valid_subscription_student, user_group_id: student_user_group.id) }
  let!(:valid_subscription_student_access) { FactoryBot.create(:trial_student_access, user_id: valid_subscription_student.id) }
  let!(:valid_subscription) { FactoryBot.create(:valid_subscription, user_id: valid_subscription_student.id,
                                                stripe_customer_id: valid_subscription_student.stripe_customer_id ) }

  #TODO - review all these tests
  context 'Logged in as a user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe "GET 'show'" do
      xit 'should see valid_subscription' do
        get :show, id: valid_subscription.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end

    describe "GET 'invoice'" do
      xit 'should see valid invoice' do
        get :invoice, id: valid_subscription.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:invoice)
      end

    end

    describe "GET 'pdf_invoice'" do
      xit 'should see valid invoice' do
        get :pdf_invoice, id: valid_subscription.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:pdf_invoice)
      end

    end

    describe "GET 'charge'" do
      xit 'should see valid invoice' do
        get :charge, id: valid_subscription.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:charge)
      end

    end

    describe "Post 'un_cancel_subscription'" do
      xit 'should see valid invoice' do
        post :un_cancel_subscription, id: valid_subscription.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:charge)
      end

    end

    describe "Post 'cancel'" do
      xit 'should see valid invoice' do
        post :cancel, id: valid_subscription.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:charge)
      end

    end


    describe "Post 'immediate_cancel'" do
      xit 'should see valid invoice' do
        post :immediate_cancel, id: valid_subscription.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:charge)
      end

    end

    describe "Post 'reactivate_subscription'" do
      xit 'should see valid invoice' do
        post :reactivate_subscription, id: valid_subscription.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:charge)
      end

    end



  end

end