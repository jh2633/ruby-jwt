require 'json'
require 'jwt'
require 'sinatra/base'
require 'dotenv/load'
require_relative 'jwt_auth'
class Api < Sinatra::Base
  use JwtAuth


  def initialize
    super

    @accounts = {
      tomdelonge: 10000,
      markhoppus: 50000,
      travisbarker: 1000000000
    }
  end

  get '/money' do
    scopes, user = request.env.values_at(:scopes, :user)
    username = user['username'].to_sym

    if scopes.include?('view_money') && @accounts.has_key?(username)
      content_type :json
      { money: @accounts[username] }.to_json
    else
      halt 403
    end
  end

  post '/money' do
    scopes, user = request.env.values_at :scopes, :user
    username = user['username'].to_sym

    if scopes.include?('add_money') && @accounts.has_key?(username)
      amount = request[:amount]
      @accounts[username] += amount.to_i

      content_type :json
      { money: @accounts[username] }.to_json
    else
      halt 403
    end
  end


  delete '/money' do
    scopes, user = request.env.values_at :scopes, :user
    username = user['username'].to_sym

    if scopes.include?('remove_money') && @accounts.has_key?(username)
      amount = request[:amount]

      @accounts[username] -= amount.to_i
      if @accounts[username] < 0
        @accounts[username] = 0
      end

      content_type :json
      { money: @accounts[username] }.to_json
    else
      halt 403
    end
  end
end

class Public < Sinatra::Base

  def initialize
    super

    @logins = {
      tomdelonge: 'allthesmallthings',
      markhoppus: 'therockshow',
      travisbarker: 'whatsmyageagain'
    }
  end

  post '/login' do
    username = params[:username]
    password = params[:password]

    if @logins[username.to_sym] == password
      content_type :json
      { token: token(username) }.to_json
    else
      halt 401
    end
  end

  def token(username)
    JWT.encode payload(username), ENV['JWT_SECRET'], 'HS256'
  end

  def payload(username)
    {
      exp: Time.now.to_i + 60 * 60,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      scopes: ['add_money', 'remove_money', 'view_money'],
      user: {
        username: username
      },
    }
  end


end
