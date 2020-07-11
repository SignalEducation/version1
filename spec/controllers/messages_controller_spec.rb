require 'rails_helper'
require 'authlogic/test_case'

RSpec.describe MessagesController, :type => :controller do

  let(:user ) { FactoryBot.create(:active_user ) }
  let(:message) { FactoryBot.create(:message) }

  context 'Get unsubscribe' do
    it 'returns success when given a valid guid' do
      get :unsubscribe, params: { message_guid: message.guid }
      expect(controller.params[:message_guid]).to eq(message.guid)
      expect(response.status).to eq(200)
      expect(response).to render_template(:unsubscribe)
      expect(flash[:error]).to be_nil
    end
  end
end
