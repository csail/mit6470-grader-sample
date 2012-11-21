require 'bundler'
Bundler.require :default, :cors

require './cors_app/cors.rb'

# Allow cross-domain XHR for routes starting with "/xhr_".
use Rack::Cors do
  allow do
    origins '*'
    resource '/xhr_*', headers: :any
  end
end

run CorsApp
