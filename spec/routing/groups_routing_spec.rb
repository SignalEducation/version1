# == Schema Information
#
# Table name: groups
#
#  id                    :integer          not null, primary key
#  name                  :string
#  name_url              :string
#  active                :boolean          default(FALSE), not null
#  sorting_order         :integer
#  description           :text
#  subject_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  corporate_customer_id :integer
#  destroyed_at          :datetime
#  image_file_name       :string
#  image_content_type    :string
#  image_file_size       :integer
#  image_updated_at      :datetime
#

require 'rails_helper'

RSpec.describe GroupsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/groups').to route_to('groups#index')
    end

    it 'routes to #new' do
      expect(get: '/groups/new').to route_to('groups#new')
    end

    it 'routes to #show' do
      expect(get: '/groups/1').to route_to('groups#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/groups/1/edit').to route_to('groups#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/groups').to route_to('groups#create')
    end

    it 'routes to #update' do
      expect(put: '/groups/1').to route_to('groups#update', id: '1')
    end

    it 'routes to #reorder' do
      expect(post: '/groups/reorder').to route_to('groups#reorder')
    end
    # todo move this to routes.rb ABOVE the resource:
    # post 'groups/reorder', to: 'groups#reorder'

    it 'routes to #destroy' do
      expect(delete: '/groups/1').to route_to('groups#destroy', id: '1')
    end

  end
end
