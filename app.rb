require "sinatra"
require "sinatra/reloader"
require "require_all"
require "date"

enable :sessions
set :session_secret, "154a6e0b931dabbdcd78db7eac23bfabc421785aa5a149970a1f3c8c2271ce29"


require_rel "../db", "models"

get "/" do
  @page_name = "Workouts"
  redirect "/workouts"
end

get "/test" do
  erb :test
end

get "/welcome" do
  if session[:LoggedIn]
    @target = DB[:EXERCISES].where(UserID: session[:UserID])
    erb :welcome_screen
  end
end
get "/stats" do
  if session[:LoggedIn]
    @page_name = "Stats"
    @user = DB[:USERS].first(UserID: session[:UserID])
    if params[:month] == nil
      redirect "/stats?month=#{Date.today.strftime("%m").to_i.to_s}&year=#{Date.today.strftime("%Y")}"
      #@days = getDaysForThisMonth(@user[:UserID])
      #@monthName = Date.today.strftime("%B")
      #@daysInThisMonth = Date.today.strftime("%d").to_i
    else
      @days = getDaysForMonth(@user[:UserID], params[:month], params[:year])
      @monthName = numberToMonth(params[:month])
      @monthNum = params[:month]
      @year = params[:year]
      @daysInThisMonth = Date.new(@year.to_i, params[:month].to_i, -1).strftime("%d").to_i
      @nextDate = nextMonthYear(params[:month].to_i, params[:year].to_i)
      @prevDate = previousMonthYear(params[:month].to_i, params[:year].to_i)
    end
    erb :stats
  else
    erb :notsignedin
  end
end

get "/test" do
  puts params
  redirect "/welcome"
end

get "/profile2" do
  if session[:LoggedIn]
    puts "filter results: #{params[:filter]}"
    @filterResults = [];
    @filterList = [];
    params[:filter].split(",").each do |filter|
      @filterList.push(filter);
      @filterResults.push(DB[:EXERCISES].where(UserID: session[:UserID], GroupName: filter));
    end
    erb :profile2
  end
end
get "/workouts" do
  if session[:LoggedIn]
    if params[:filter] != "All" && params[:filter] != nil
      @target = DB[:EXERCISES].where(UserID: session[:UserID])
      @target = @target.where(GroupName: params[:filter])
    else
      @target = DB[:EXERCISES].where(UserID: session[:UserID])
    end
    @filterType = params[:filter]
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

get "/contactus" do
  erb :contactus
end
get "/workouts/exercise" do
  @page_name = "Profile"
  if session[:LoggedIn] && params[:id] != nil
    @workoutName = DB[:EXERCISES].first(ExID: params[:id])[:Name]
    @unit = DB[:EXERCISES].first(ExID: params[:id])[:Unit]
    @id = params[:id]
    if params[:filter] == "recent"
      @filter_type = "Recent"
      @target = DB[:WORKOUTS].where(ExID: params[:id]).where(Date: getLastWorkoutDate(session[:UserID], params[:id]))
    elsif params[:filter] == "all"
      @filter_type = "All"
      @target = DB[:WORKOUTS].where(ExID: params[:id])
    elsif params[:filter] == "yesterday"
      @filter_type = "Yesterday"
      @target = DB[:WORKOUTS].where(ExID: params[:id]).where(Date: Date.today.prev_day.strftime("%d/%m/%Y"))
    else
      @filter_type = "Recent"
      @target = DB[:WORKOUTS].where(ExID: params[:id]).where(Date: getLastWorkoutDate(session[:UserID], params[:id]))
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
  redirect "/workouts/exercise?id="+params[:exid]
end

get "/delete-set" do
  if params[:id] != nil && session[:LoggedIn]
    deleteSet(params[:id])
    redirect "/"
  else
    erb :notsignedin
  end
end

get "/edit-exercise" do
  if params[:id] != nil
    @exid = params[:id]
    @exercise = DB[:EXERCISES].first(ExID: @exid)
    erb :editexercise
  else
    erb :pagenotfound
  end
end

post "/edit-exercise" do
  n = params[:Name]
  u = params[:Unit]
  g = params[:GroupName]
  editExercise(params[:id], n,u,g)
  redirect "/"
end

get "/delete-exercise" do
  if params[:id] != nil && session[:LoggedIn]
    deleteExercise(params[:id])
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
    erb :notsignedin
  end
end

get "/register" do
  session[:LoggedIn] = false
  session[:UserID] = "none"
  session[:Nickname] = "none"
  erb :register
end

post "/register" do
  result = registerUser(params)
  puts result
  if result[0]
    redirect "/"
  else
    @hint = result[1]
    erb :register
  end
end

error 404 do
  erb :pagenotfound
end

