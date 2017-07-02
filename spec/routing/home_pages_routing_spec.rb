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
#

require 'rails_helper'

RSpec.describe HomePagesController, type: :routing do
  describe 'routing' do

    it 'routes to #home' do
      expect(get: '/').to route_to('home_pages#home')
    end

    it 'routes to #group' do
      expect(get: '/group/group_1').to route_to('home_pages#group', home_pages_public_url: 'group_1')
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
