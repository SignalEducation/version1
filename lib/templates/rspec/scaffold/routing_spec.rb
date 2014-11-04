require 'rails_helper'

RSpec.describe <%= controller_class_name %>Controller, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(get: '/<%= table_name -%>').to route_to('<%= table_name -%>#index')
    end

    it 'routes to #new' do
      expect(get: '/<%= table_name %>/new').to route_to('<%= table_name -%>#new')
    end

    it 'routes to #show' do
      expect(get: '/<%= table_name -%>/1').to route_to('<%= table_name -%>#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/<%= table_name -%>/1/edit').to route_to('<%= table_name -%>#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/<%= table_name -%>').to route_to('<%= table_name -%>#create')
    end

    it 'routes to #update' do
      expect(put: '/<%= table_name -%>/1').to route_to('<%= table_name -%>#update', id: '1')
    end

    <%- if attributes.map(&:name).includes?('sorting_order') -%>
    it 'routes to #reorder' do
      expect(post: '/<%= table_name -%>/reorder').to route_to('<%= table_name -%>#reorder')
    end
    # todo move this to routes.rb ABOVE the resource:
    # post '<%= table_name -%>/reorder', to: '<%= table_name -%>#reorder'
    <%- end -%>

    it 'routes to #destroy' do
      expect(delete: '/<%= table_name -%>/1').to route_to('<%= table_name -%>#destroy', id: '1')
    end

  end
end
