
def x_stub_mandrill_verification_request(url, email, template, verification_code)
  uri = url
  status = 200
  return_body = {'id': 'cus_DnTEm6Sl2naVIv', 'object': 'customer', }.to_json

  stub_request(:post, uri).
      with(
          body: "{\"template_name\":\"#{template}\",\"template_content\":null,\"message\":{\"html\":null,\"text\":null,\"subject\":\"Welcome to LearnSignal - Please verify your email address\",\"from_email\":\"team@learnsignal.com\",\"from_name\":\"Learn Signal\",\"to\":[{\"email\":\"#{email}\",\"type\":\"to\",\"name\":\"Test Student\"}],\"headers\":null,\"important\":false,\"track_opens\":null,\"track_clicks\":null,\"auto_text\":null,\"auto_html\":null,\"inline_css\":null,\"url_strip_qs\":null,\"preserve_recipients\":null,\"view_content_link\":null,\"bcc_address\":null,\"tracking_domain\":null,\"signing_domain\":null,\"return_path_domain\":null,\"merge\":true,\"merge_language\":\"mailchimp\",\"global_merge_vars\":[{\"name\":\"FNAME\",\"content\":\"Test\"},{\"name\":\"LNAME\",\"content\":\"Student\"},{\"name\":\"COMPANY\",\"content\":\"Signal Education\"},{\"name\":\"COMPANYURL\",\"content\":\"https://learnsignal.com\"},{\"name\":\"VERIFICATIONURL\",\"content\":\"http://test.host/user_verification/#{verification_code}\"}],\"merge_vars\":[],\"tags\":[],\"subaccount\":null,\"google_analytics_domains\":[],\"google_analytics_campaign\":null,\"metadata\":{},\"recipient_metadata\":[],\"attachments\":[],\"images\":[]},\"async\":false,\"ip_pool\":null,\"send_at\":null,\"key\":\"uKK_pGl-9PK54IhUzx5Ajg\"}",
          headers: {
              'Content-Type'=>'application/json',
              'Host'=>'mandrillapp.com:443',
              'User-Agent'=>'excon/0.45.4'
          }).
      to_return(status: status, body: '', headers: {})

end

def stub_mandrill_verification_request(url)
  uri = url
  status = 200
  return_body = {'id': 'cus_DnTEm6Sl2naVIv', 'object': 'customer', }.to_json

  stub_request(:post, uri).
      with(
          headers: {
              'Content-Type'=>'application/json',
              'Host'=>'mandrillapp.com:443',
              'User-Agent'=>'excon/0.45.4'
          }).
      to_return(status: status, body: '', headers: {})

end
