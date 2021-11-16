# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rendering locals in a partial' do
  let(:gb_country)    { build_stubbed(:country, iso_code: 'GB') }
  let(:cn_country)    { build_stubbed(:country, iso_code: 'CN') }
  let(:gb_user)       { build_stubbed(:user, country: gb_country, video_player: :vimeo) }
  let(:cn_user)       { build_stubbed(:user, country: cn_country, video_player: :vimeo) }
  let(:vimeo_user)    { build_stubbed(:user, country: gb_country, video_player: :vimeo) }
  let(:dacast_user)   { build_stubbed(:user, country: gb_country, video_player: :dacast) }
  let(:vimeo_module)  { build_stubbed(:course_step, :video_step, :vimeo) }
  let(:dacast_module) { build_stubbed(:course_step, :video_step, :dacast) }

  context 'Vimeo player partial' do
    it 'shows as default players' do
      @vimeo_as_main = true
      stub_template 'courses/players/_vimeo.html.erb' => 'Vimeo partial - <%= cme.id %>'
      render partial: 'courses/video_player', locals: { cme: vimeo_module, responsive: false, autoPlay: false, current_user: gb_user }
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

  context ':user Preferred Player' do
    it 'if it is a user has vimeo as video_player' do
      @vimeo_as_main = true
      stub_template 'courses/players/_vimeo.html.erb' => 'Vimeo partial - <%= cme.id %>'
      render partial: 'courses/video_player', locals: { cme: vimeo_module, responsive: false, autoPlay: false, current_user: vimeo_user }
      expect(response).to render_template(partial: 'courses/players/_vimeo')
    end

    it 'if it is a user has dacast as video_player' do
      @vimeo_as_main = true
      stub_template 'courses/players/_dacast.html.erb' => 'Dacast partial - <%= cme.id %>'
      render partial: 'courses/video_player', locals: { cme: vimeo_module, responsive: false, autoPlay: false, current_user: dacast_user }
      expect(response).to render_template(partial: 'courses/players/_dacast')
    end
  end
end
