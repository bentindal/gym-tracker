require "sinatra"
require "sinatra/reloader"
require "require_all"

set :port, 1234

enable :sessions
set :session_secret, "$g]Rd2M/WbJ`~~<GZWdH@Fm'ESk2_gckCtLJJkySYG"

require_rel "db", "models"

get "/" do
  @page_name = "Workouts"
  redirect "/workouts"
end

get "/workouts" do
  if session[:LoggedIn]
    @target = DB[:EXERCISES].where(UserID: session[:UserID])
    @page_name = "Profile"
    erb :profile
  else
    @page_name = "Login"
    @hint = ""
    erb :login
  end
end

get "/logout" do 
  if session[:LoggedIn]
    session[:LoggedIn] = false
    session[:UserID] = "none"
    session[:Nickname] = "none"
    redirect "/"
  else
    # ERROR: Cant logout if your not signed in
    @page_name = "Login"
    erb :notsignedin
  end
end

post "/login" do
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

get "/workouts/exercise" do
  if session[:LoggedIn] && params[:id] != nil
    @workoutName = DB[:EXERCISES].first(ExID: params[:id])[:Name]
    @id = params[:id]
    @target = DB[:WORKOUTS].where(ExID: params[:id])
    @page_name = "Profile"
    erb :exercise
  else
    erb :notsignedin
  end
end

post "/workouts/exercise" do
  addSet(params[:id], params)
  redirect "/workouts/exercise?id="+params[:id]
end

post "/workouts" do
  addExerciseType(params)
  redirect "/workouts"
end

error 404 do
  erb :pagenotfound
end

