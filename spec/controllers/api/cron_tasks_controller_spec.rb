require 'rails_helper'

describe Api::CronTasksController, type: :controller do
  describe 'POST #create' do
    describe 'with a valid message' do
      it 'creates a new instance of PaypalWebhookService' do
        expect_any_instance_of(CronService).to receive(:initiate_task).with('test_task')

        post :create, params: { id: 'test_task' }
      end

      it 'returns 200 Ok' do
        allow(CronService).to receive(:new).and_return(double(initiate_task: true))

        post :create, params: { id: 'test_task' }
        expect(response.status).to eq(200)
      end
    end
  end
end
