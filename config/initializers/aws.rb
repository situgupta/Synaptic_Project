AWS.config(
  :access_key_id => Rails.application.credentials.dig(:aws_access_key_id),
  :secret_access_key => Rails.application.credentials.dig(:aws_secret_access_key)
)
S3_BUCKET =  AWS::S3.new.buckets[Rails.application.credentials.dig(:aws_s3_bucket)]