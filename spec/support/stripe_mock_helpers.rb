# frozen_string_literal: true

module StripeMockHelpers

  STRIPE_HEADERS = {
    'Accept'=>'*/*',
    'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
    'Content-Type'=>'application/x-www-form-urlencoded',
    'Stripe-Version'=>'2019-05-16',
    'User-Agent'=>'Stripe/v1 RubyBindings/4.21.3'
  }

  def stub_customer_get_request(url, response_body)
    stub_request(:get, url).
      with(headers: STRIPE_HEADERS).
      to_return(status: 200, body: response_body.to_json, headers: {})
  end

  def stub_customer_create_request(url, request)
    return_body = {'id': 'cus_DnTEm6Sl2naVIv', 'object': 'customer' }.to_json

    stub_request(:post, url).
      with(body: request, headers: STRIPE_HEADERS).
      to_return(status: 200, body: return_body, headers: {})
  end

  def stub_customer_update_request(url, request, return_body)  
    stub_request(:post, url).
      with(body: request, headers: STRIPE_HEADERS).
      to_return(status: 200, body: return_body, headers: {})
  end

  def stub_coupon_create_request(url, request, return_body)
    stub_request(:post, url).
      with(body: request, headers: STRIPE_HEADERS).
      to_return(status: 200, body: return_body.to_json, headers: {})
  end

  def stub_coupon_get_request(url, response_body)
    stub_request(:get, url).
      with(headers: STRIPE_HEADERS).
      to_return(status: 200, body: response_body.to_json, headers: {})
  end

  def stub_coupon_delete_request(url, response_body)
    stub_request(:delete, url).
      with(headers: STRIPE_HEADERS).
      to_return(status: 200, body: response_body.to_json, headers: {})
  end

  def stub_refund_create_request(url, request_body, response_body)
    stub_request(:post, url).
      with(body: request_body, headers: STRIPE_HEADERS).
      to_return(status: 200, body: response_body.to_json, headers: {})
  end

  def stub_subscription_post_request(url, request_body, response_body)
    stub_request(:post, url).
      with(body: request_body, headers: STRIPE_HEADERS).
      to_return(status: 200, body: response_body.to_json, headers: {})
  end

  def stub_subscription_get_request(url, response_body)
    stub_request(:get, url).
      with(headers: STRIPE_HEADERS).
      to_return(status: 200, body: response_body.to_json, headers: {})
  end

  def stub_subscription_delete_request(url, response_body)
    stub_request(:delete, url).
      with(headers: STRIPE_HEADERS).
      to_return(status: 200, body: response_body.to_json, headers: {})
  end

  def stub_event_get_request(url, response_body)
    stub_request(:get, url).
        with(headers: STRIPE_HEADERS).
        to_return(status: 200, body: response_body.to_json, headers: {})
  end

  def stub_invoice_get_request(url, response_body)
    stub_request(:get, url).
      with(headers: STRIPE_HEADERS).
      to_return(status: 200, body: response_body.to_json, headers: {})
  end

  def stub_coupon_get_request(url, response_body)
    stub_request(:get, url).
        with(headers: STRIPE_HEADERS).
        to_return(status: 200, body: response_body.to_json, headers: {})
  end

  def stub_post_cards_request(url, request_body, response_body)
    stub_request(:post, url).
      with(body: request_body, headers: STRIPE_HEADERS).
      to_return(status: 200, body: response_body.to_json, headers: {})
  end
end
