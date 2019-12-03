Aws.config.update({
  region: 'eu-west-1',
  credentials: Aws::Credentials.new(ENV['LEARNSIGNAL3_S3_ACCESS_KEY_ID'], ENV['LEARNSIGNAL3_S3_SECRET_ACCESS_KEY'])
})

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['LEARNSIGNAL3_BUCKET_NAME']) if ENV['LEARNSIGNAL3_BUCKET_NAME'].present?