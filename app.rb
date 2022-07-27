require "sinatra"
require "sinatra/reloader"
require "require_all"
require "date"

set :port, 80

enable :sessions
set :session_secret, "$g]Rd2M/WbJ`~~<GZWdH@Fm'ESk2_gckCtLJJkySYG"

require_rel "../db", "models"

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
  @page_name = "Profile"
  if session[:LoggedIn] && params[:id] != nil
    @workoutName = DB[:EXERCISES].first(ExID: params[:id])[:Name]
    @id = params[:id]
    if params[:filter] == "today"
      @filter_type = "Today"
      @target = DB[:WORKOUTS].where(ExID: params[:id]).where(Date: Time.now.strftime("%d/%m/%Y"))
    elsif params[:filter] == "all"
      @filter_type = "All"
      @target = DB[:WORKOUTS].where(ExID: params[:id])
    elsif params[:filter] == "yesterday"
      @filter_type = "Yesterday"
      @target = DB[:WORKOUTS].where(ExID: params[:id]).where(Date: Date.today.prev_day.strftime("%d/%m/%Y"))
    else
      @filter_type = "Today"
      @target = @target = DB[:WORKOUTS].where(ExID: params[:id]).where(Date: Time.now.strftime("%d/%m/%Y"))
    end
    erb :exercise
  else
    erb :notsignedin
  end
end

post "/workouts/exercise" do
  addSet(params[:id], params)
  puts params[:filter]
  redirect "/workouts/exercise?id="+params[:id]+"&filter="+params[:filter]
end

post "/workouts" do
  addExerciseType(params)
  redirect "/workouts"
end

get "/edit-set" do
  if params[:id] != nil
    @setid = params[:id]
    @workout = DB[:WORKOUTS].first(SetID: @setid)
    erb :editset
  else
    erb :pagenotfound
  end
end

post "/edit-set" do
  i = params[:id]
  r = params[:Reps]
  w = params[:Weight]
  t = params[:Time]
  d = params[:Date]
  editSet(i, r, w, t, d)
  redirect "/"
end

get "/delete-set" do
  if params[:id] != nil && session[:LoggedIn]
    deleteSet(params[:id])
    redirect "/"
  else
    erb :notsignedin
  end
end

get "/summary" do
  if session[:LoggedIn]
    @allUsersExercises = DB[:EXERCISES].where(UserID: session[:UserID])
    erb :summary
  else
    erb:notsignedin
  end
end

error 404 do
  erb :pagenotfound
end

