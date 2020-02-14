# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::CbesController, type: :controller do
  let(:cbe) { create(:cbe) }

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
        post :clone, params: { id: cbe.id }

        expect(response.status).to eq(302)
        expect(response).to redirect_to(admin_cbes_path)
        expect(flash[:success]).to be_present
        expect(flash[:success]).to eq('Cbe successfully duplicaded')
      end

      it 'should not duplicate cbe' do
        allow_any_instance_of(Cbe).to receive(:update).and_return(false)

        post :clone, params: { id: cbe.id }

        expect(response.status).to eq(302)
        expect(response).to redirect_to(admin_cbes_path)
        expect(flash[:error]).to be_present
        expect(flash[:error]).to eq('Cbe not successfully duplicaded')
      end
    end
  end
end
