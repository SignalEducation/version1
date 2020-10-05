# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CbesController, type: :controller do
  let(:user_group)   { create(:content_management_user_group) }
  let(:user)         { create(:content_management_user, user_group_id: user_group.id) }
  let(:cbe)          { create(:cbe) }
  let(:cbe_resource) { create(:cbe_resource) }

  before :each do
    allow(controller).to receive(:logged_in_required).and_return(true)
    allow(controller).to receive(:ensure_user_has_access_rights).and_return(true)
  end

  describe 'GET index' do
    before { get :index }

    it 'assigns @cbe' do
      expect(assigns(:cbes)).to eq([cbe])
    end

    it 'renders the index template' do
      expect(response).to render_template('index')
    end
  end

  describe 'GET show' do
    before { get :show, params: { id: cbe.id } }

    it 'assigns @cbe' do
      expect(assigns(:cbe)).to eq(cbe)
    end

    it 'renders the index template' do
      expect(response).to render_template('show')
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'renders the new template' do
      expect(response).to render_template('new')
    end
  end

  describe '#clone' do
    context 'clone cbe' do
      it 'should duplicate cbe' do
        allow(controller).to receive(:current_user).and_return(user)
        allow(CbeCloneWorker).to receive(:perform_async).and_return(true)

        post :clone, params: { id: cbe_resource.cbe.id }

        expect(response.status).to eq(302)
        expect(response).to redirect_to(admin_cbes_path)
        expect(flash[:success]).to be_present
        expect(flash[:success]).to eq('CBE is cloning now, you will receive an email when finished.')
      end
    end
  end
end
