require 'sinatra'
require 'sinatra/reloader'
require 'mongo'
require 'bcrypt'

connection = Mongo::Connection.new('localhost', 27272)
db = connection.db('pizza_colle')
coll = db.collection('test')


get '/' do
  @title = 'ピザ・コレクション'
  erb :index
end

get '/regist_form' do
  @title = '着任式'
  erb :regist_form
end

post '/regist_user' do
  user_name = @params[:user_name]
  password = @params[:password]
  user_salt = BCrypt::Engine.generate_salt
  #password_hash = BCrypt::Engine.hash_secret(password, user_salt)
  #これで照合するらしい
  
  # 登録
  doc = {
    'name' => user_name,
    'password_salt' => password_salt,
  }
  coll.insert(doc)
end
