problem do
  param_name 'js_sliders'
  name 'JS sliders'
  time_limit 10

  grade do
    browser.page_events = true
    browser.console_events = true
    log 'Loading test page'
    browser.navigate_to test_url
    log 'Waiting for page load event'
    browser.wait_for type: WebkitRemote::Event::PageLoaded

    round 1, 60, [60, 40]
    round 1, 73, [73, 27]
    round 2, 0, [100, 0]
    round 1, 50, [50, 50]
    round 2, 70, [30, 70]
    round 1, 15, [15, 85]

    correct
  end


  def round(slider, value, golden)
    log "Setting slider #{slider} to #{value}"
    sliders = %w(#slider1 #slider2).map do |css_selector|
      browser.dom_root.query_selector css_selector
    end

    log 'Dispatching change event'
    set_input_value sliders[slider - 1], value
    browser.remote_eval <<JS_END
(function() {
  var event = document.createEvent("Event");
  event.initEvent("change", true, false);
  var slider = document.querySelector("#slider#{slider}");
  slider.dispatchEvent(event);
})();
JS_END

    log 'Checking sliders'
    slider_values = sliders.map { |slider| input_value(slider).to_i }
    assert_each_close_to golden, slider_values, 2, 'Wrong slider values'
  end
end
