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
  if session[:LoggedIn]
    session[:LoggedIn] = false
    session[:UserID] = "none"
    session[:Nickname] = "none"
    erb :main
  else
    # ERROR: Cant logout if your not signed in
    erb :notsignedin
  end
end

post "/validate_login" do
  usernameAttempt = params[:username]
  passwordAttempt = params[:password]
  results = validateLogin(usernameAttempt, passwordAttempt)
  session[:LoggedIn] = results[0]
  session[:UserID] = results[1]
  session[:Nickname] = results[2]
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

