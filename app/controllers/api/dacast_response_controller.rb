# frozen_string_literal: true

module Api
  class DacastResponseController < Api::BaseController
    protect_from_forgery except: :update

    def update
      redis    = Redis.new
      key      = params['title']
      id       = params['file_id']
      data     = JSON.parse(redis.get(key))
      response = Videos::Providers::Dacast.new.update(id, data)

      if response['error'].blank?
        CourseModuleElementVideo.find(data['object_id']).update(dacast_id: id)
        Rails.logger.info response
        render json: response, status: :ok
      else
        Rails.logger.error response
        render json: response, status: :error
      end
    end
  end
end
