# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::BearersController, type: :controller do
  let(:user_group)       { create(:admin_user_group) }
  let(:user)             { create(:admin_user, user_group_id: user_group.id) }
  let(:bearer)           { create(:bearer, :active) }
  let(:active_bearers)   { create_list(:bearer, 5, :active) }
  let(:inactive_bearers) { create_list(:bearer, 5, :inactive) }

  before :each do
    allow(controller).to receive(:logged_in_required).and_return(true)
    allow(controller).to receive(:ensure_user_has_access_rights).and_return(true)
  end

  describe 'GET index' do
    before { get :index }

    it 'assigns @bearers' do
      expect(assigns(:bearers)).to eq(active_bearers + inactive_bearers)
    end

    it 'renders the index template' do
      expect(response).to render_template('index')
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'assigns @bearer' do
      expect(assigns(:bearer)).to be_a_new(Bearer)
    end

    it 'renders the new template' do
      expect(response).to render_template('new')
    end
  end

  describe 'POST create' do
    context 'valid bearer' do
      let!(:valid_params) { attributes_for(:bearer, api_key: nil) }

      before { post :create, params: { bearer: valid_params } }

      it 'returns HTTP status 302' do
        expect(response).to have_http_status 302
      end

      it 'redirect to index ' do
        expect(response).to redirect_to(admin_bearers_path)
      end

      it 'shows flash message' do
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.bearers.create.flash.success'))
      end
    end

    context 'invalid bearer' do
      let!(:invalid_params) { attributes_for(:bearer, api_key: nil, slug: 'Invalid Value Here!!!') }

      before { post :create, params: { bearer: invalid_params } }

      it 'returns HTTP status 200' do
        expect(response).to have_http_status 200
      end

      it 'render to new ' do
        expect(response).to render_template(:new)
      end

      it 'shows flash message' do
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.bearers.create.flash.error'))
      end
    end
  end

  describe 'GET edit' do
    before { get :edit, params: { id: bearer.id } }

    it 'assigns @bearer' do
      expect(assigns(:bearer)).to eq(bearer)
    end

    it 'renders the edit template' do
      expect(response).to render_template('edit')
    end
  end

  describe 'PUT update' do
    context 'valid bearer' do
      before do
        bearer.name = Faker::Company.name

        put :update, params: { id: bearer.id, bearer: bearer.attributes }
      end

      it 'returns HTTP status 302' do
        expect(response).to have_http_status 302
      end

      it 'redirect to index ' do
        expect(response).to redirect_to(admin_bearers_path)
      end

      it 'shows flash message' do
        expect(flash[:error]).to be_nil
        expect(flash[:success]).to eq(I18n.t('controllers.bearers.update.flash.success'))
      end
    end

    context 'invalid bearer' do
      before do
        bearer.slug = 'Invalid Value Here!!!'

        put :update, params: { id: bearer.id, bearer: bearer.attributes }
      end

      it 'returns HTTP status 302' do
        expect(response).to have_http_status 302
      end

      it 'redirect to edit ' do
        expect(response).to redirect_to(edit_admin_bearer_path(bearer))
      end

      it 'shows flash message' do
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.bearers.update.flash.error'))
      end
    end
  end
end
