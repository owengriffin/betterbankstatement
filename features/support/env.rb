
lib =  File.expand_path(File.dirname(__FILE__) + "../../../lib")
puts lib
$: << lib

appfile = File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. lib betterbankstatement server.rb]))
puts appfile
require 'betterbankstatement.rb'

require appfile
# Force the application name because polyglot breaks the auto-detection logic.
Sinatra::Application.app_file = appfile

# Ensure that the database connections are created
BetterBankStatement.load

require 'spec/expectations'
require 'webrat'
require 'rack/test'
require 'test/unit'

Webrat.configure do |config|
  config.mode = :rack
end
 
class MyWorld
  include Test::Unit::Assertions
  include Rack::Test::Methods
  include Webrat::Methods
  include Webrat::Matchers
 
  Webrat::Methods.delegate_to_session :response_code, :response_body

  def app
    Sinatra::Application
  end
end

World{MyWorld.new}
