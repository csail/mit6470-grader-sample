require 'json'

problem do
  param_name 'js_cors'
  name 'JS cors'
  time_limit 10

  setup do
    data[:cors_url] = URI.join(cors_app_url, 'xhr_post').to_s
  end

  grade do
    browser.network_events = true
    log 'Loading test page'
    browser.navigate_to test_url

    log 'Waiting for POST request'
    event = nil
    loop do
      event = browser.wait_for(type: WebkitRemote::Event::NetworkRequest).last
      http_method = event.resource.request.method
      http_url = event.resource.request.url
      log "#{event.class.name} #{http_method} #{http_url}"
      if /^#{data[:cors_url]}/ =~ http_url
        if http_method == :post
          break
        else
          log "Got #{http_method.to_s.upcase}, waiting for a POST request"
        end
      end
    end
    assert_equal data[:cors_url], event.resource.request.url,
                 'Wrong request URL.'

    log 'Waiting for POST response'
    loop do
      event = browser.wait_for(type: WebkitRemote::Event::NetworkResponse).last
      break if /^#{data[:cors_url]}/ =~ event.resource.request.url
    end
    assert_equal false, event.resource.canceled, 'POST request blocked.'
    assert_equal data[:cors_url], event.resource.request.url,
                 'Wrong request URL.'

    begin
      json = JSON.parse event.resource.body
    rescue JSON::ParserError
      wrong 'POST response corrupted.'
    end
    log "POST response: #{json.inspect}"
    assert_equal 'yes', json['params']['matched'],
        'Incorrect "matched" parameter value.'

    correct
  end
end
