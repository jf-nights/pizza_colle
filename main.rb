require 'sinatra'
require 'sinatra/reloader'
require 'mongo'
require 'bcrypt'
require 'carrier-pigeon'

connection = Mongo::Connection.new('localhost', 27272)
db = connection.db('pizza_colle')
coll = db.collection('test')

# session を使う
enable :sessions
set :session_secret, "My session secret"

# ページの方でもsession を使えるように
before do
  @session = session
end

# helper!!!!!!
helpers do
  def check_redirect_home
    if session[:user]
      redirect '/home'
    end
  end
  def check_redirect_login
    if session[:user] == nil
      redirect '/login_form'
    end
  end
end

get '/' do
  @title = 'ピザ・コレクション'
  erb :top
end

# ---------- ログイン関連 ----------
# ログイン画面
get '/login_form' do
  check_redirect_home
  @title = 'ログイン画面'
  erb :login_form
end

# ログインの時
post '/session' do
  check_redirect_home

  user_name = @params[:user_name]
  password = @params[:password]

  # 照合
  tmp_user = nil
  coll.find('name' => user_name).each {|row| tmp_user = row.to_h}
  if tmp_user != nil && tmp_user['password_hash'] == BCrypt::Engine.hash_secret(password, tmp_user['user_salt'])
    session[:user] = user_name
    redirect "/home"
  else
    redirect '/login_form'
  end
end

# ログアウトの時
get '/session' do
  check_redirect_login

  session.clear
  redirect '/'
end

# ユーザー登録画面
get '/regist_form' do
  check_redirect_home
  @title = '着任式'
  erb :regist_form
end

# 登録処理
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
    
    session[:user] = user_name
    redirect "/home"
  end
  #これで照合するらしい
end


# ---------- ユーザーページ! ----------
# ユーザーのホーム画面
get '/home' do
  check_redirect_login()
  @title = 'ホォム'
  erb :home
end

# ピッツァ
get '/pizza' do
  check_redirect_login()
  @title = 'ピッツァ'
  erb :pizza
end

# ---------- FAQ ----------
get '/faq' do
  @title = 'FAQ'
  erb :faq
end

# ---------- Support ----------
get '/support' do
  @title = 'サポォト'
  erb :support
end

post '/send_message' do
  name = @params[:name]
  message = @params[:message]
  slack = open('/home/jf712/.slack/ako').read.chomp
  pigeon = CarrierPigeon.new(:host => 'kmc-jp.xmpp.slack.com',
                             :port => 6667,
                             :nick => 'ako',
                             :password => slack,
                             :channel => '#pizza-colle',
                             :join => true
                            )
  message.gsub!("\n",' ')
  pigeon.message('#pizza-colle', "@jf712 #{message} by #{name}")
  pigeon.die

  redirect 'support'
end
