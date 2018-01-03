require 'spec_helper'
require 'rack/test'
require './main.rb'
describe 'money' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
  URL = '/api/money'
  context 'when the request with NO authentication header' do
    it 'should respond with forbidden' do
    get URL
    expect(last_response).to have_http_status(401)
    end
  end
end
