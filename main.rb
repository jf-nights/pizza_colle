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
  
  # 重複チェック
  tmp = []
  coll.find('name' => user_name).each {|row| tmp << row}
  
  if tmp != []
    # 重複してる
    @duplicate = true
    erb :regist_form
  else
    # 登録
    user_salt = BCrypt::Engine.generate_salt
    doc = {
      'name' => user_name,
      'user_salt' => user_salt,
    }
    coll.insert(doc)
    
    @user = user_name
    erb :regist_done
  end
  #password_hash = BCrypt::Engine.hash_secret(password, user_salt)
  #これで照合するらしい
end

get '/:name/home' do
  erb :home
end
