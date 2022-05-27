require "sinatra"
require "sinatra/reloader"
require "require_all"

set :port, 1234

enable :sessions
set :session_secret, "$g]Rd2M/WbJ`~~<GZWdH@Fm'ESk2_gckCtLJJkySYG"

require_rel "db", "models"

get "/" do
  @page_name = "Home"
  erb :main
end

get "/login" do
  @page_name = "Login"
  @hint = ""
  erb :login
end

get "/logout" do 
  session[:loggedIn] = false
  session[:userID] = nil
  erb :logout
end

post "/validate_login" do
  usernameAttempt = params[:username]
  passwordAttempt = params[:password]
  results = validateLogin(usernameAttempt, passwordAttempt)
  session[:loggedIn] = results[0]
  session[:userID] = results[1]
  if results[0] == true
    redirect "/"
  else
    @page_name = "Login"
    @hint = "Incorrect username or password"
    erb :login
  end
end

error 404 do
  erb :pagenotfound
end

