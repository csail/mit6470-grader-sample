require 'json'

# The one and only controller.
class TestApp < Sinatra::Base
  # Render the test file.
  get '/' do
    content_type :html
    GlobalState.html
  end

  # Store the test file.
  post '/' do
    GlobalState.html = params[:html]
    content_type :text
    'OK'
  end
end

# Global state that gets persisted across requests.
class GlobalStateClass
  # @return [String] test HTML
  attr_accessor :html
end
GlobalState = GlobalStateClass.new
