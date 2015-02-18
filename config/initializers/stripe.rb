Rails.configuration.stripe = {
        publishable_key: ENV['learnsignal_v3_stripe_public_key'],
        secret_key: ENV['learnsignal_v3_stripe_api_key=']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
