require 'sinatra'
require 'sinatra/reloader'
require 'mongo'
require 'bcrypt'

connection = Mongo::Connection.new('localhost', 27272)
db = connection.db('pizza_colle')
coll = db.collection('test')

enable :sessions
set :session_secret, "My session secret"

before do
  @session = session
end

get '/' do
  p session
  @title = 'ピザ・コレクション'
  erb :index
end

get '/login_form' do
  @title = 'ログイン画面'
  if session[:user]
    redirect "#{session[:user]}/home"
  end
  erb :login_form
end

post '/session' do

  if session[:user]
    redirect "#{session[:user]}/home"
  end
  user_name = @params[:user_name]
  password = @params[:password]

  # 照合
  tmp_user = nil
  coll.find('name' => user_name).each {|row| tmp_user = row.to_h}
  if tmp_user != nil && tmp_user['password_hash'] == BCrypt::Engine.hash_secret(password, tmp_user['user_salt'])
    session[:user] = user_name
    redirect "#{user_name}/home"
  else
    redirect '/login_form'
  end
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
    password_hash = BCrypt::Engine.hash_secret(password, user_salt)
    doc = {
      'name' => user_name,
      'user_salt' => user_salt,
      'password_hash' => password_hash
    }
    coll.insert(doc)
    
    @user = user_name
    erb :regist_done
  end
  #これで照合するらしい
end

get '/:name/home' do
  if session[:user] == nil
    redirect '/login_form'
  else
    erb :home
  end
end
