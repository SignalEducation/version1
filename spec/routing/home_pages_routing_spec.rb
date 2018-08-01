# == Schema Information
#
# Table name: home_pages
#
#  id                            :integer          not null, primary key
#  seo_title                     :string
#  seo_description               :string
#  subscription_plan_category_id :integer
#  public_url                    :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  subject_course_id             :integer
#  custom_file_name              :string
#  group_id                      :integer
#  name                          :string
#  discourse_ids                 :string
#  home                          :boolean          default(FALSE)
#  header_heading                :string
#  header_paragraph              :text
#  header_button_text            :string
#  background_image              :string
#  header_button_link            :string
#  header_button_subtext         :string
#  footer_link                   :boolean          default(FALSE)
#  mailchimp_list_guid           :string
#  mailchimp_section_heading     :string
#  mailchimp_section_subheading  :string
#  mailchimp_subscribe_section   :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe HomePagesController, type: :routing do
  describe 'routing' do

    it 'routes to #home' do
      expect(get: '/').to route_to('home_pages#home')
    end

    it 'routes to #show' do
      expect(get: '/course_1').to route_to('home_pages#show', home_pages_public_url: 'course_1')
    end

    it 'routes to #home_page_subscribe' do
      expect(post: '/home_page_subscribe').to route_to('home_pages#subscribe')
    end

    it 'routes to #index' do
      expect(get: '/home_pages').to route_to('home_pages#index')
    end

    it 'routes to #new' do
      expect(get: '/home_pages/new').to route_to('home_pages#new')
    end

    it 'routes to #edit' do
      expect(get: '/home_pages/1/edit').to route_to('home_pages#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/home_pages').to route_to('home_pages#create')
    end

    it 'routes to #update' do
      expect(put: '/home_pages/1').to route_to('home_pages#update', id: '1')
    end

  end
end
