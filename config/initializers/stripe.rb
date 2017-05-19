Rails.configuration.stripe = {
        publishable_key: ENV['learnsignal_v3_stripe_public_key'],
        secret_key: ENV['learnsignal_v3_stripe_api_key']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
Stripe.api_version = '2017-04-06' #V01 version '2015-02-18'

unless defined? STRIPE_JS_HOST
  STRIPE_JS_HOST = 'https://js.stripe.com'
end