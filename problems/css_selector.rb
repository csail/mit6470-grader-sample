problem do
  param_name 'css_selector'
  name 'CSS selector'
  time_limit 5

  setup do
    data[:paragraphs] = 12
  end

  grade do
    browser.device_metrics = { width: 640, height: 480 }
    browser.page_events = true
    log 'Loading test page at 640x480'
    browser.navigate_to test_url
    log 'Waiting for load event'
    message = browser.wait_for type: WebkitRemote::Event::PageLoaded

    log 'Checking colors'
    paragraphs = browser.dom_root.query_selector_all 'p'

    paragraphs.each.with_index do |p, i|
      style = p.computed_style
      assert_equal 'rgb(0, 128, 0)', style[:color],
          "Incorrect color for paragraph number #{i + 1}"
    end

    correct
  end
end

