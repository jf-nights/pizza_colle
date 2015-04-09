require 'sinatra'
require 'sinatra/reloader'

get '/' do
  @title = 'ピザ・コレクション'
  erb :index
end
