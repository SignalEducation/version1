# == Schema Information
#
# Table name: static_pages
#
#  id                            :integer          not null, primary key
#  name                          :string
#  publish_from                  :datetime
#  publish_to                    :datetime
#  allow_multiples               :boolean          default(FALSE), not null
#  public_url                    :string
#  use_standard_page_template    :boolean          default(FALSE), not null
#  head_content                  :text
#  body_content                  :text
#  created_by                    :integer
#  updated_by                    :integer
#  add_to_navbar                 :boolean          default(FALSE), not null
#  add_to_footer                 :boolean          default(FALSE), not null
#  menu_label                    :string
#  tooltip_text                  :string
#  language                      :string
#  mark_as_noindex               :boolean          default(FALSE), not null
#  mark_as_nofollow              :boolean          default(FALSE), not null
#  seo_title                     :string
#  seo_description               :string
#  approved_country_ids          :text
#  default_page_for_this_url     :boolean          default(FALSE), not null
#  make_this_page_sticky         :boolean          default(FALSE), not null
#  logged_in_required            :boolean          default(FALSE), not null
#  created_at                    :datetime
#  updated_at                    :datetime
#  show_standard_footer          :boolean          default(TRUE)
#  post_sign_up_redirect_url     :string
#  subscription_plan_category_id :integer
#  student_sign_up_h1            :string
#  student_sign_up_sub_head      :string
#

require 'rails_helper'

RSpec.describe StaticPagesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/static_pages').to route_to('static_pages#index')
    end

    it 'routes to #new' do
      expect(get: '/static_pages/new').to route_to('static_pages#new')
    end

    it 'routes to #show' do
      expect(get: '/static_pages/1').to route_to('static_pages#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/static_pages/1/edit').to route_to('static_pages#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/static_pages').to route_to('static_pages#create')
    end

    it 'routes to #update' do
      expect(put: '/static_pages/1').to route_to('static_pages#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/static_pages/1').to route_to('static_pages#destroy', id: '1')
    end

  end
end
