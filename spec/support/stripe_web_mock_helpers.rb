def stub_customer_get_request(url, response_body)
  uri = url
  response_body = response_body.to_json
  status = 200

  stub_request(:get, uri).
      with(
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Stripe-Version'=>'2017-06-05',
              'User-Agent'=>'Stripe/v1 RubyBindings/2.8.0',
              'X-Stripe-Client-User-Agent'=>'{"bindings_version":"2.8.0","lang":"ruby","lang_version":"2.2.9 p480 (2017-12-15)","platform":"x86_64-darwin17","engine":"ruby","publisher":"stripe","uname":"Darwin Jamess-MacBook-Pro.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Jun 21 22:53:14 PDT 2018; root:xnu-4570.71.2~1/RELEASE_X86_64 x86_64","hostname":"Jamess-MacBook-Pro.local"}'
          }).
      to_return(status: status, body: response_body, headers: {})

end


def stub_customer_create_request(url, request)
  uri = url
  request_body = request
  status = 200
  return_body = {'id': 'cus_DnTEm6Sl2naVIv', 'object': 'customer', }.to_json

  stub_request(:post, uri).
      with(
          body: request_body,
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Stripe-Version'=>'2017-06-05',
              'User-Agent'=>'Stripe/v1 RubyBindings/2.8.0',
          }).
      to_return(status: status, body: return_body, headers: {})
end


def stub_coupon_create_request(url, request, return_body)
  uri = url
  request_body = request
  return_body = return_body.to_json
  status = 200


  stub_request(:post, uri).
      with(
          body: request_body,
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Stripe-Version'=>'2017-06-05',
              'User-Agent'=>'Stripe/v1 RubyBindings/2.8.0',
              'X-Stripe-Client-User-Agent'=>'{"bindings_version":"2.8.0","lang":"ruby","lang_version":"2.2.9 p480 (2017-12-15)","platform":"x86_64-darwin17","engine":"ruby","publisher":"stripe","uname":"Darwin Jamess-MacBook-Pro.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Jun 21 22:53:14 PDT 2018; root:xnu-4570.71.2~1/RELEASE_X86_64 x86_64","hostname":"Jamess-MacBook-Pro.local"}'
          }).
      to_return(status: status, body: return_body, headers: {})

end


def stub_coupon_get_request(url, response_body)
  uri = url
  response_body = response_body.to_json
  status = 200

  stub_request(:get, uri).
      with(
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Stripe-Version'=>'2017-06-05',
              'User-Agent'=>'Stripe/v1 RubyBindings/2.8.0',
              'X-Stripe-Client-User-Agent'=>'{"bindings_version":"2.8.0","lang":"ruby","lang_version":"2.2.9 p480 (2017-12-15)","platform":"x86_64-darwin17","engine":"ruby","publisher":"stripe","uname":"Darwin Jamess-MacBook-Pro.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Jun 21 22:53:14 PDT 2018; root:xnu-4570.71.2~1/RELEASE_X86_64 x86_64","hostname":"Jamess-MacBook-Pro.local"}'
          }).
      to_return(status: status, body: response_body, headers: {})
end

def stub_coupon_delete_request(url, response_body)
  uri = url
  response_body = response_body.to_json
  status = 200

  stub_request(:delete, uri).
      with(
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Stripe-Version'=>'2017-06-05',
              'User-Agent'=>'Stripe/v1 RubyBindings/2.8.0',
              'X-Stripe-Client-User-Agent'=>'{"bindings_version":"2.8.0","lang":"ruby","lang_version":"2.2.9 p480 (2017-12-15)","platform":"x86_64-darwin17","engine":"ruby","publisher":"stripe","uname":"Darwin Jamess-MacBook-Pro.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Jun 21 22:53:14 PDT 2018; root:xnu-4570.71.2~1/RELEASE_X86_64 x86_64","hostname":"Jamess-MacBook-Pro.local"}'
          }).
      to_return(status: status, body: response_body, headers: {})
end

def stub_refund_create_request(url, request_body, response_body)
  uri = url
  request_body = request_body
  response_body = response_body.to_json
  status = 200

  stub_request(:post, uri).
      with(
          body: request_body,
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Stripe-Version'=>'2017-06-05',
              'User-Agent'=>'Stripe/v1 RubyBindings/2.8.0',
              'X-Stripe-Client-User-Agent'=>'{"bindings_version":"2.8.0","lang":"ruby","lang_version":"2.2.9 p480 (2017-12-15)","platform":"x86_64-darwin17","engine":"ruby","publisher":"stripe","uname":"Darwin Jamess-MacBook-Pro.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Jun 21 22:53:14 PDT 2018; root:xnu-4570.71.2~1/RELEASE_X86_64 x86_64","hostname":"Jamess-MacBook-Pro.local"}'
          }).
      to_return(status: status, body: response_body, headers: {})
end



def stub_subscription_post_request(url, request_body, response_body)
  uri = url
  request_body = request_body
  response_body = response_body.to_json
  status = 200

  stub_request(:post, uri).
      with(
          body: request_body,
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Stripe-Version'=>'2017-06-05',
              'User-Agent'=>'Stripe/v1 RubyBindings/2.8.0',
              'X-Stripe-Client-User-Agent'=>'{"bindings_version":"2.8.0","lang":"ruby","lang_version":"2.2.9 p480 (2017-12-15)","platform":"x86_64-darwin17","engine":"ruby","publisher":"stripe","uname":"Darwin Jamess-MacBook-Pro.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Jun 21 22:53:14 PDT 2018; root:xnu-4570.71.2~1/RELEASE_X86_64 x86_64","hostname":"Jamess-MacBook-Pro.local"}'
          }).
      to_return(status: status, body: response_body, headers: {})
end


def stub_subscription_get_request(url, response_body)
  uri = url
  response_body = response_body.to_json
  status = 200

  stub_request(:get, uri).
      with(
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Stripe-Version'=>'2017-06-05',
              'User-Agent'=>'Stripe/v1 RubyBindings/2.8.0',
              'X-Stripe-Client-User-Agent'=>'{"bindings_version":"2.8.0","lang":"ruby","lang_version":"2.2.9 p480 (2017-12-15)","platform":"x86_64-darwin17","engine":"ruby","publisher":"stripe","uname":"Darwin Jamess-MacBook-Pro.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Jun 21 22:53:14 PDT 2018; root:xnu-4570.71.2~1/RELEASE_X86_64 x86_64","hostname":"Jamess-MacBook-Pro.local"}'
          }).
      to_return(status: status, body: response_body, headers: {})
end


def stub_subscription_delete_request(url, response_body)
  uri = url
  response_body = response_body.to_json
  status = 200

  stub_request(:delete, uri).
      with(
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Stripe-Version'=>'2017-06-05',
              'User-Agent'=>'Stripe/v1 RubyBindings/2.8.0',
              'X-Stripe-Client-User-Agent'=>'{"bindings_version":"2.8.0","lang":"ruby","lang_version":"2.2.9 p480 (2017-12-15)","platform":"x86_64-darwin17","engine":"ruby","publisher":"stripe","uname":"Darwin Jamess-MacBook-Pro.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Jun 21 22:53:14 PDT 2018; root:xnu-4570.71.2~1/RELEASE_X86_64 x86_64","hostname":"Jamess-MacBook-Pro.local"}'
          }).
      to_return(status: status, body: response_body, headers: {})
end


def stub_event_get_request(url, response_body)
  uri = url
  response_body = response_body.to_json
  status = 200

  stub_request(:get, uri).
      with(
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Stripe-Version'=>'2017-06-05',
              'User-Agent'=>'Stripe/v1 RubyBindings/2.8.0',
              'X-Stripe-Client-User-Agent'=>'{"bindings_version":"2.8.0","lang":"ruby","lang_version":"2.2.9 p480 (2017-12-15)","platform":"x86_64-darwin17","engine":"ruby","publisher":"stripe","uname":"Darwin Jamess-MacBook-Pro.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Jun 21 22:53:14 PDT 2018; root:xnu-4570.71.2~1/RELEASE_X86_64 x86_64","hostname":"Jamess-MacBook-Pro.local"}'
          }).
      to_return(status: status, body: response_body, headers: {})

end

def stub_invoice_get_request(url, response_body)
  uri = url
  response_body = response_body.to_json
  status = 200

  stub_request(:get, uri).
      with(
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer sk_test_wEVy0Tzgi3HEzoeJk4t340vI',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'Stripe-Version'=>'2017-06-05',
              'User-Agent'=>'Stripe/v1 RubyBindings/2.8.0',
              'X-Stripe-Client-User-Agent'=>'{"bindings_version":"2.8.0","lang":"ruby","lang_version":"2.2.9 p480 (2017-12-15)","platform":"x86_64-darwin17","engine":"ruby","publisher":"stripe","uname":"Darwin Jamess-MacBook-Pro.local 17.7.0 Darwin Kernel Version 17.7.0: Thu Jun 21 22:53:14 PDT 2018; root:xnu-4570.71.2~1/RELEASE_X86_64 x86_64","hostname":"Jamess-MacBook-Pro.local"}'
          }).
      to_return(status: status, body: response_body, headers: {})
end

