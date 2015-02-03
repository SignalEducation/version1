require 'digest'

class Transcoder

  attr_accessor :credentials, :inbox_file_name, :raw_video_file_id

  def initialize(credentials, inbox_file_name, guid_prefix)
    @inbox_file_name = inbox_file_name
    @guid_prefix = guid_prefix
    @aws_client = Aws::ElasticTranscoder::Client.new(credentials: credentials, region: 'eu-west-1')
    return @aws_client
  end

  def create
    if Rails.env.production? || RawVideoFile::FAKE_PRODUCTION_MODE
      output_base_folder_name = @guid_prefix + '-' + @inbox_file_name.split('.')[0..-2].join('.') + '/'
      pipeline_id = '1412960763862-osqzsg'
      output_key = Digest::SHA256.hexdigest(@inbox_file_name.encode('UTF-8'))
      output_formats = build_output_formats(output_key)
      playlist = build_playlist(output_formats)

      job = @aws_client.create_job(
              pipeline_id: pipeline_id,
              input: { key: @inbox_file_name },
              output_key_prefix: output_base_folder_name + 'hls/',
              outputs: output_formats,
              playlists: [ playlist ]
      )
      return job
    end
  end

  protected

  def build_playlist(output_formats)
    { name: 'master', format: 'HLSv3',
      output_keys: output_formats.map { |output| output[:key] }
    }
  end

  def build_output_formats(output_key)

    # Custom HLS Presets that will be used for an adaptive bitrate playlist
    hls_64k_audio_preset_id = '1412964182509-2m9v4d'
    hls_0200k_preset_id     = '1412963899975-0wm11p'
    hls_0400k_preset_id     = '1412963978443-y94kup'
    hls_1000k_preset_id     = '1412964027299-wee9kv'
    hls_2000k_preset_id     = '1412964058999-273n0j'

    # HLS Segment duration that will be targeted.
    segment_duration = '10'

    hls_audio = {
            key: 'hlsAudio/' + output_key,
            preset_id: hls_64k_audio_preset_id,
            segment_duration: segment_duration
    }

    hls_200k = {
            key: 'hls0200k/' + output_key,
            preset_id: hls_0200k_preset_id,
            segment_duration: segment_duration
    }

    hls_400k = {
            key: 'hls0400k/' + output_key,
            preset_id: hls_0400k_preset_id,
            segment_duration: segment_duration
    }

    hls_1000k = {
            key: 'hls1000k/' + output_key,
            preset_id: hls_1000k_preset_id,
            segment_duration: segment_duration
    }

    hls_2000k = {
            key: 'hls2000k/' + output_key,
            preset_id: hls_2000k_preset_id,
            segment_duration: segment_duration
    }

    [ hls_audio, hls_200k, hls_400k, hls_1000k, hls_2000k ]
  end

end
