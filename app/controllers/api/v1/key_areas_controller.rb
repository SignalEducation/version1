# frozen_string_literal: true

module Api
  module V1
    class KeyAreasController < Api::V1::ApiController
      def index
        @group = Group.find_by(name_url: params[:group])

        @key_areas =
          if @group
            @group.key_areas.all_active.all_in_order
          else
            @key_areas = KeyArea.all_active.all_in_order
          end

        render 'api/v1/key_areas/index.json'
      end
    end
  end
end
