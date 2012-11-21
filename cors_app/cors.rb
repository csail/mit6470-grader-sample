require 'json'

# The one and only controller.
class CorsApp < Sinatra::Base
  get '/' do
    "You're talking to the wrong server."
  end

  # Emits CSRF headers, can be used in XHR requests.
  post '/xhr_post' do
    content_type :json
    { method: :post, params: params }.to_json
  end

  # This doesn't emit CSRF headers, but it can still be called.
  post '/post' do
    content_type :json
    { method: :post, params: params }.to_json
  end

  # This isn't useful yet. Perhaps we'll add JSONP support?
  get '/get' do
    content_type :json
    { method: :get, params: params }.to_json
  end

  enable :dump_errors, :logging
  set :protection, except: :json_csrf
  disable :sessions
end
