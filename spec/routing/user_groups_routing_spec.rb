# == Schema Information
#
# Table name: user_groups
#
#  id                           :integer          not null, primary key
#  name                         :string
#  description                  :text
#  tutor                        :boolean          default(FALSE), not null
#  site_admin                   :boolean          default(FALSE), not null
#  created_at                   :datetime
#  updated_at                   :datetime
#  system_requirements_access   :boolean          default(FALSE)
#  content_management_access    :boolean          default(FALSE)
#  stripe_management_access     :boolean          default(FALSE)
#  user_management_access       :boolean          default(FALSE)
#  developer_access             :boolean          default(FALSE)
#  user_group_management_access :boolean          default(FALSE)
#  student_user                 :boolean          default(FALSE)
#  trial_or_sub_required        :boolean          default(FALSE)
#  blocked_user                 :boolean          default(FALSE)
#  marketing_resources_access   :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe UserGroupsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/user_groups').to route_to('user_groups#index')
    end

    it 'routes to #new' do
      expect(get: '/user_groups/new').to route_to('user_groups#new')
    end

    it 'routes to #show' do
      expect(get: '/user_groups/1').to route_to('user_groups#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/user_groups/1/edit').to route_to('user_groups#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/user_groups').to route_to('user_groups#create')
    end

    it 'routes to #update' do
      expect(put: '/user_groups/1').to route_to('user_groups#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/user_groups/1').to route_to('user_groups#destroy', id: '1')
    end

  end
end
