class Transcoder

  attr_accessor :credentials, :inbox_file_name

  def initialize(credentials, inbox_file_name)
    puts credentials.inspect
    puts inbox_file_name
  end

  def create
    job_id = 'JOB abc123'
    return job_id
  end

end
