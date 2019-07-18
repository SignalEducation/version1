# frozen_string_literal: true

namespace :videos do
  desc 'Migrate all videos without decast_id from vimeo.'

  task migrate_from_vimeo: :environment do
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Migrating videos from Vimeo to Dacast...'

    total_time = Benchmark.measure do
      videos_array = CourseModuleElementVideo.distinct.
                       where(dacast_id: nil).
                       where.not(vimeo_guid: nil).
                       in_groups_of(25)


      videos_array.each do |videos|
        ActiveRecord::Base.transaction do
          Rails.logger.info "======= #{videos.count} VIDEOS ========="
          bench_time = Benchmark.measure do
            videos.each do |video|
              vimeo_id   = video.vimeo_guid
              data       = Videos::Providers::Vimeo.new.data(vimeo_id)
              link       = video_link(data)
              response   = upload_video(link)
              next unless response['status'] == 202

              save_video_data(link, data, video)
            end
          end

          Rails.logger.info '============ Bench time execution ==============='
          Rails.logger.info bench_time.real
          Rails.logger.info '================================================='
        end
      end
    end

    Rails.logger.info '============ Total time execution ============'
    Rails.logger.info total_time.real
    Rails.logger.info '=============================================='
  end

  desc 'Delete all videos from decast.'
  task delete_from_dacast: :environment do
    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Deleting videos from Dacast...'

    total_time = Benchmark.measure do
      videos_array = CourseModuleElementVideo.distinct.
                       where.not(dacast_id: nil).
                       in_groups_of(25)

      [videos_array.first].each do |videos|
        ActiveRecord::Base.transaction do
          Rails.logger.info "======= #{videos.count} VIDEOS ========="
          bench_time = Benchmark.measure do
            videos.each do |video|
              response = delete_video(video.dacast_id)
              next unless response['status'] == 202

              video.find(id).update(dacast_id: nil)
            end
          end

          Rails.logger.info '============ Bench time execution ==============='
          Rails.logger.info bench_time.real
          Rails.logger.info '================================================='
        end
      end
    end

    Rails.logger.info '============ Total time execution ============'
    Rails.logger.info total_time.real
    Rails.logger.info '=============================================='
  end
end

def video_link(data)
  data['download'].first['link']
end

def file_name(link)
  URI.parse(link).request_uri.split('/').last
end

def upload_video(link)
  Videos::Providers::Dacast.new.upload(link)
end

def delete_video(id)
  Videos::Providers::Dacast.new.delete(id)
end

def save_video_data(link, data, video)
  redis = Redis.new
  data  = { 'object_id' => video.id }.merge(data)
  redis.set(file_name(link), data.to_json)
end

def update_video_data(id, data)
  Videos::Providers::Dacast.new.update(id, data)
end
