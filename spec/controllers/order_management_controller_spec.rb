# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrderManagementController, type: :controller do
  let(:user_management_user_group)     { create(:user_management_user_group) }
  let(:user_management_user)           { create(:user_management_user, user_group_id: user_management_user_group.id) }
  let!(:active_order)                  { create(:order, id: rand(100_000), state: 'completed') }
  let!(:cancelled_order)               { create(:order, id: rand(100_000), state: 'cancelled') }

  context 'Logged in as a user_management_user: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe "GET 'show'" do
      it 'should see active_order' do
        get :show, params: { id: active_order.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end

    describe 'cancel order' do
      it 'should update to cancelled' do
        put :cancel_order, params: { order_management_id: active_order.id, order: { cancelled_by_id: user_management_user.id, cancellation_note: 'no longer needs product' } }
      end
    end

    describe 'reactivate order' do
      it 'should update to completed' do
        put :un_cancel_order, params: { order_management_id: cancelled_order.id }
      end
    end
  end
end
