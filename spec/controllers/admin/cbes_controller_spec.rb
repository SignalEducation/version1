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
end
