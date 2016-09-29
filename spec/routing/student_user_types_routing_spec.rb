# == Schema Information
#
# Table name: student_user_types
#
#  id            :integer          not null, primary key
#  name          :string
#  description   :text
#  subscription  :boolean          default(FALSE)
#  product_order :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe StudentUserTypesController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/student_user_types').to route_to('student_user_types#index')
    end

    it 'routes to #new' do
      expect(get: '/student_user_types/new').to route_to('student_user_types#new')
    end

    it 'routes to #show' do
      expect(get: '/student_user_types/1').to route_to('student_user_types#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/student_user_types/1/edit').to route_to('student_user_types#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/student_user_types').to route_to('student_user_types#create')
    end

    it 'routes to #update' do
      expect(put: '/student_user_types/1').to route_to('student_user_types#update', id: '1')
    end


    it 'routes to #destroy' do
      expect(delete: '/student_user_types/1').to route_to('student_user_types#destroy', id: '1')
    end

  end
end
