
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

