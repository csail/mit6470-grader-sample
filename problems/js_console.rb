problem do
  param_name 'js_console'
  name 'JS console'
  time_limit 5

  grade do
    browser.console_events = true
    log 'Loading test page'
    browser.navigate_to test_url
    log 'Waiting for console.log() call'
    message = browser.wait_for(type: WebkitRemote::Event::ConsoleMessage,
                               level: :log).last
    assert_equal 'Hello world', message.text, 'Wrong answer.'
    correct
  end
end
