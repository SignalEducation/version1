require 'rails_helper'

describe Api::StripeDevController, type: :controller do

  let!(:admin_user_1) { FactoryGirl.create(:admin_user, email: 'dan@learnsignal.com')}
  let!(:admin_user_2) { FactoryGirl.create(:admin_user, email: 'site.admin@example.com')}
  let!(:some_params_1) { {dev_name: 'dan', id: 'thing_123', some_param: '123', some_other_param: 456} }
  let!(:some_params_2) { {dev_name: 'steve', id: 'thing_123', some_param: '123', some_other_param: 456} }

  describe "POST 'create'" do
    describe 'preliminary functionality: ' do
      it 'returns 204 when called with no payload (to support Stripe Pings)' do
        expect(Rails.logger).to receive(:error)
        post :create
        expect(response.status).to eq(204)
      end
    end

    describe 'send some data in' do
      describe 'for Dan' do
        it 'should return 200 and store data' do
          post :create, some_params_1
          expect(response.code).to eq('200')
          expect(StripeDeveloperCall.all.count).to eq(1)
          expect(StripeDeveloperCall.first.user_id).to eq(admin_user_1.id)
        end
      end

      describe 'for Steve (an unknown admin)' do
        it 'should return 200 and store data' do
          post :create, {dev_name: 'steve', some_param: '123', some_other_param: 456}
          expect(response.code).to eq('200')
          expect(StripeDeveloperCall.all.count).to eq(1)
          expect(StripeDeveloperCall.first.user_id).to eq(admin_user_2.id)
        end
      end
    end
  end

end
