function updateSliderValue(slider) {
  var otherSlider = (slider === 1) ? 2 : 1;
  var sliderValue = parseInt(document.querySelector("#slider" + slider).value);
  var otherValue = 100 - sliderValue;
  document.querySelector("#slider" + otherSlider).value = otherValue;
}
