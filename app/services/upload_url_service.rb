# frozen_string_literal: true

class UploadUrlService
  attr_reader :content_type, :filename, :url

  # @note It is important to have a single source of truth (Rails) for
  #   content-type, as clients may return mismatched content-types versus
  #   what Rails deduces, resulting in s3 signature errors.
  #
  # @example
  #   upload_url_service = UploadUrlService.new(filename)
  #   upload_url_service.call
  #
  # @param filename [String]
  #
  def initialize(filename)
    @filename = filename
    @content_type = MIME::Types.type_for(filename).first.content_type
  end

  # @return [Boolean] Generation successful
  def call
    obj = S3_BUCKET.object("uploads/tinymce/#{SecureRandom.uuid}/#{@filename}")
    @url = obj.presigned_url(:put, acl: 'public-read').to_s
    true
  end
end
