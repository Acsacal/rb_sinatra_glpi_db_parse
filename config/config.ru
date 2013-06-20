require './test.rb'

root=Dir.pwd

Rack::Handler::Thin.run Sinatra::Application, :Port => 8080, :Host => "0.0.0.0"