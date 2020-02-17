# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::SystemSettingsController, type: :controller do
  let!(:_system) { create(:system_setting) }

  before :each do
    allow(controller).to receive(:logged_in_required).and_return(true)
    allow(controller).to receive(:ensure_user_has_access_rights).and_return(true)
  end

  describe 'GET index' do
    before { get :index }

    it 'assigns @_system' do
      expect(assigns(:system)).to eq(_system)
    end

    it 'renders the index template' do
      expect(response).to render_template('index')
    end
  end

  describe 'POST update' do
      let!(:update_params) { attributes_for(:system_setting) }

      before do
        patch :update, params: { id: _system.id, settings: update_params[:settings] }
      end

      it 'returns HTTP status 200' do
        expect(response).to be_redirect
        expect(response.status).to eq(302)
      end
    end
end
