require 'rails_helper'

describe Api::DacastResponseController, type: :controller do
  describe 'POST #update' do
    let(:dacast_class)  { Videos::Providers::Dacast.new }
    let(:dacast_params) { { 'file_id' => 'SOME_ID_HERE', 'filename' => 'FILENAME', 'title' => 'SOME_TITLE' } }
    let(:cmev)          { build_stubbed(:course_module_element_video) }
    let(:redis_data)    { { object_id: cmev.id, title: 'SOME_TITLE' } }

    context 'sucess' do
      before do
        expect(dacast_class).to receive(:update).and_return(true)
        # expect(Api::DacastResponseController.new).to receive(:update).and_return(true)
        Redis.new.set(cmev.course_module_element.name_url, redis_data.to_json)
        post 'update', params: dacast_params
      end

      # it 'returns HTTP status 200' do
      #   expect(response).to have_http_status 200
      # end

      # it 'return a subscription object.' do
      #   body = JSON.parse(response.body)

      #   expect(body['subscriber_id']).to eq(subscriber.id)
      #   expect(body['status']).to        eq(valid_team_subscription.status)
      #   expect(body['competition']).to   eq(valid_team_subscription.competition)
      #   expect(body['data_type']).to     eq(valid_team_subscription.data_type)
      #   expect(body['filters']).to       eq(valid_team_subscription.filters)
      # end
    end
  end
end
