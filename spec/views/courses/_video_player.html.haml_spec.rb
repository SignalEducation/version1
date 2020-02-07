# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rendering locals in a partial' do
  let(:gb_country)    { double(Country, iso_code: 'GB') }
  let(:cn_country)    { double(Country, iso_code: 'CN') }
  let(:gb_user)       { double(User, country: gb_country) }
  let(:cn_user)       { double(User, country: cn_country) }
  let(:vimeo_module)  { build_stubbed(:course_module_element, :cme_video, :vimeo) }
  let(:dacast_module) { build_stubbed(:course_module_element, :cme_video, :dacast) }

  context 'Vimeo player partial' do
    it 'shows as default players' do
      @vimeo_as_main = true
      stub_template 'courses/players/_vimeo.html.erb' => 'Vimeo partial - <%= cme.id %>'
      render partial: 'courses/video_player', locals: { cme: vimeo_module, current_user: gb_user }
      expect(response).to render_template(partial: 'courses/players/_vimeo')
    end
  end

  context 'Dacast player partial' do
    it 'if it is a user from China' do
      stub_template 'courses/players/_dacast.html.erb' => 'Dacast partial - <%= cme.id %>'

      render partial: 'courses/video_player', locals: { cme: dacast_module, current_user: cn_user }
      expect(response).to render_template(partial: 'courses/players/_dacast')
    end
  end
end
