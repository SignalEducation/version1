# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorController, type: :controller do
  controller do
    def index
      internal_error
    end
  end

  describe 'GET redirect to 500 page' do
    it 'render 500 when hit index' do
      get :index
      expect(response.status).to eq(500)
    end
  end
end
