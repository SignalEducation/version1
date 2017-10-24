Rails.configuration.stripe = {
        publishable_key: ENV['LEARNSIGNAL_V3_STRIPE_PUBLIC_KEY'],
        secret_key: ENV['LEARNSIGNAL_V3_STRIPE_API_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
Stripe.api_version = '2017-06-05' #V01 version '2015-02-18'
