# == Schema Information
#
# Table name: raw_video_files
#
#  id                     :integer          not null, primary key
#  file_name              :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  transcode_requested_at :datetime
#  transcode_request_guid :string(255)
#  transcode_result       :string(255)
#  transcode_completed_at :datetime
#  raw_file_modified_at   :datetime
#  aws_etag               :string(255)
#  duration_in_seconds    :integer          default(0)
#  guid_prefix            :string(255)
#

class RawVideoFile < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :file_name, :transcode_requested_at, :transcode_request_guid,
                  :transcode_result, :transcode_completed_at, :raw_file_modified_at, :aws_etag

  # Constants
  BASE_URL = 'https://s3-eu-west-1.amazonaws.com/'
  INBOX_BUCKET = 'learnsignal3-video-inbox'
  OUTBOX_BUCKET = 'learnsignal3-video-outbox'
  TRANSCODE_RESULTS = %w(done error in-progress)

  # relationships
  has_many :course_module_element_videos

  # validation
  validates :file_name, presence: true

  # callbacks

  # scopes
  scope :all_in_order, -> { order('lower(file_name)') }
  scope :not_yet_assigned, -> { includes(:course_module_element_videos).where('course_module_element_videos.id IS NULL').references(:course_module_element_videos) }

  # class methods
  def self.get_new_videos
    current_videos = RawVideoFile.all.map {|x| {file_name: x.file_name, raw_file_modified_at: x.raw_file_modified_at, aws_etag: x.aws_etag} }
    array_of_video_names_in_inbox.each do |remote_file|
      local_file = current_videos.find {|x| x[:aws_etag] == remote_file[:aws_etag] }

      if remote_file[:file_name] == local_file.try(:[], :file_name)
        if remote_file[:raw_file_modified_at] > local_file[:raw_file_modified_at]
          send_notifications(:file_updated, {remote_file: remote_file, local_file: local_file})
        end
      elsif remote_file[:aws_etag] == local_file.try(:[], :aws_etag)
        send_notifications(:file_renamed, {remote_file: remote_file, local_file: local_file})
      else
        x = RawVideoFile.new(remote_file)
        unless x.save
          Rails.logger.error "ERROR: RawVideoFile.self.get_new_videos failed to create a new record using remote_file: #{remote_file}. Errors: #{x.errors}."
        end
      end
    end
    true
  end

  # instance methods
  def destroyable?
    !Rails.env.production? && self.course_module_element_videos.empty?
  end

  def full_name
    self.file_name + " (#{self.status})"
  end

  def status
    if self.transcode_result.blank?
      if self.transcode_request_guid.blank?
        'No transcode request'
      else
        'Transcode requested'
      end
    else
      self.transcode_result.capitalize
    end
  end

  def url
    short_file_name = self.file_name.split('.')[0..-2].join('.') # kills the file extension .mov etc.
    if self.transcode_result == 'done'
      ##### AWS::S3 version
      # s3 = AWS::S3.new(
      #         access_key_id: ENV['LEARNSIGNAL3_S3_ACCESS_KEY_ID'],
      #         secret_access_key: ENV['LEARNSIGNAL3_S3_SECRET_ACCESS_KEY']
      # )
      # object = s3.buckets[OUTBOX_BUCKET].objects[short_file_name + '/hls/master.m3u8']
      # x = object.url_for(:get, { expires: 20.minutes.from_now, secure: true }).to_s
      #
      # x.gsub('learnsignal3-video-outbox.s3.amazonaws.com', 'dvetmi3t70548.cloudfront.net').split('?')[0]

      ##### Aws::S3 version (not working)
      #s3 = Aws::S3::Client.new(credentials: RawVideoFile::get_aws_credentials, region: 'eu-west-1')
      #file = s3.get_object(bucket: OUTBOX_BUCKET, key: short_file_name + '/hls/master.m3u8').public_url
      #file = s3.bucket(OUTBOX_BUCKET).object(short_file_name + '/hls/master.m3u8').public_url
      #BASE_URL + OUTBOX_BUCKET + '/' + short_file_name + '/hls/master.m3u8'

      ##### URL using CloudFront.net URL
      'https://dvetmi3t70548.cloudfront.net/' + short_file_name + '/hls/master.m3u8'
    else
      'https://s3-eu-west-1.amazonaws.com/signaleducation-output-videos/cfa1_2014_13.2/hls/master.m3u8'
      # todo: hard-code a static video
    end
  end

  protected

  def self.array_of_video_names_in_inbox
    # returns {file_name: 'file1.txt', modified_at: RubyTime, etag: 'abc123'}
    s3 = Aws::S3::Client.new(credentials: get_aws_credentials, region: 'eu-west-1')
    resp = s3.list_objects(bucket: INBOX_BUCKET)
    answer = resp.contents.map { |x| {file_name: x.key, raw_file_modified_at: x.last_modified, aws_etag: x.etag} }
    answer
  end

  def self.send_notifications(msg_type, payload)
    users = User.all_admins.where(active: true)
    if msg_type == :file_renamed
      users.each do |user|
        UserNotification.create(
                user_id: user.id,
                subject_line: 'S3 video file has been renamed',
                content: "During the sync process between the site and AWS:S3, we noticed that a file had been renamed (either on S3 or in the site). This will cause big problems (won't be able to find the video file). Please fix it.  The details: #{payload}.",
                message_type: 'system_alert',
                email_required: true, unread: true, falling_behind: false
        )
      end
    elsif msg_type == :file_updated
      users.each do |user|
        UserNotification.create(
                user_id: user.id,
                subject_line: 'S3 video file has been updated',
                content: "During the sync process between the site and AWS:S3, we noticed that a file had been updated on S3 since being uploaded. This will cause big problems (file won't be re-transcoded). Please fix it.  The details: #{payload}.",
                message_type: 'system_alert',
                email_required: true, unread: true, falling_behind: false
        )
      end
    else
      Rails.logger.error "ERROR: RawVideoFile.self.send_notifications unknown msg_type encountered. MsgType: #{msg_type}; Payload: #{payload}"
    end
  end

  def self.get_aws_credentials
    Aws::Credentials.new(
            ENV['LEARNSIGNAL3_S3_ACCESS_KEY_ID'],
            ENV['LEARNSIGNAL3_S3_SECRET_ACCESS_KEY']
    )
  end

  def production_requests_transcode
    if Rails.env.production?
      credentials = RawVideoFile.get_aws_credentials
      Rails.logger.debug "DEBUG: credentials: #{credentials.inspect}"
      request = Transcoder.new(credentials, self.file_name, self.id)
      Rails.logger.debug "DEBUG: request: #{request.inspect}"
      self.update_attributes(
              transcode_request_guid: request.create['job']['id'],
              transcode_requested_at: Proc.new{ Time.now }.call,
              transcode_result: 'in-progress')
    end
    true # ensures a happy answer, as this is a callback.
  end

end
