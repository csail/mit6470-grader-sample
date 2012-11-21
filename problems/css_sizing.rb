problem do
  param_name 'css_sizing'
  name 'CSS sizing'
  time_limit 5

  grade do
    browser.device_metrics = { width: 640, height: 480 }
    browser.page_events = true
    log 'Loading test page at 640x480'
    browser.navigate_to test_url
    log 'Waiting for load event'
    message = browser.wait_for type: WebkitRemote::Event::PageLoaded

    log 'Checking dimensions and offsets'
    box = browser.dom_root.query_selector '.red-box'
    rect = bounding_rect box

    assert_equal 320, rect[:width], 'Incorrect width'
    assert_equal 240, rect[:height], 'Incorrect height'
    assert_equal 160, rect[:left], 'Incorrect left offset'
    assert_equal 120, rect[:top], 'Incorrect top offset'


    browser.clear_all
    browser.device_metrics = { width: 1024, height: 768 }
    browser.page_events = true
    log 'Loading test page at 1024x768'
    browser.navigate_to test_url
    log 'Waiting for load event'
    message = browser.wait_for type: WebkitRemote::Event::PageLoaded

    log 'Checking dimensions and offsets'
    box = browser.dom_root.query_selector '.red-box'
    rect = bounding_rect box

    assert_equal 512, rect[:width], 'Incorrect width'
    assert_equal 384, rect[:height], 'Incorrect height'
    assert_equal 256, rect[:left], 'Incorrect left offset'
    assert_equal 192, rect[:top], 'Incorrect top offset'


    correct
  end
end

