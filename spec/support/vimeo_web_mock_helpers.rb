
def stub_vimeo_post_request(url, redirect_url, vimeo_request_body)
  vimeo_response_body = "{\"upload_link_secure\":\"https://1512435600.cloud.vimeo.com/upload?ticket_id=179762678&video_file_id=1124492995&signature=37cd4c009a8a8d80a173b3f093ac7d08&v6=1&redirect_url=https%3A%2F%2Fvimeo.com%2Fupload%2Fapi%3Fvideo_file_id%3D1124492995%26app_id%3D103619%26ticket_id%3D179762678%26signature%3D13fa4de3521167e72b9926b7be91e2f97201f558%26redirect%3Dhttp%253A%252F%252Flocalhost%253A3000%252Fen%252Fcourse_module_elements%252Fnew%253Fcm_id%253D24%2526type%253Dvideo\"}"

  uri = url
  vimeo_request_body = vimeo_request_body
  redirect_url = redirect_url
  status = 200

  stub_request(:post, uri).
      with(
          body: vimeo_request_body,
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer a3b067f4c5605adb58d0fc1f599d76a6',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'User-Agent'=>'Ruby'
          }).
      to_return(status: status, body: vimeo_response_body, headers: {})

end



def stub_vimeo_delete_request(url)
  uri = url
  status = 200

  stub_request(:delete, uri).
      with(
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer a3b067f4c5605adb58d0fc1f599d76a6',
              'User-Agent'=>'Ruby'
          }).
      to_return(status: status, body: '', headers: {})

end


#Vimeo - verify_upload Call
def stub_vimeo_patch_request(url, request_body)
  uri = url
  status = 200
  request_body = request_body

  stub_request(:patch, uri).
      with(
          body: request_body,
          headers: {
              'Accept'=>'*/*',
              'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
              'Authorization'=>'Bearer a3b067f4c5605adb58d0fc1f599d76a6',
              'Content-Type'=>'application/x-www-form-urlencoded',
              'User-Agent'=>'Ruby'
          }).
      to_return(status: status, body: '', headers: {})

end
