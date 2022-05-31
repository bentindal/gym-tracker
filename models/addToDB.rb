def addSet(exID, params)
    date = Time.now.strftime("%d/%m/%Y")
    time = Time.now.strftime("%H:%M:%S")
    DB[:WORKOUTS] << {ExID: exID, Reps: params[:Reps], Weight: params[:Weight], Date: date, Time: time}
end

def addExerciseType(params)
    # check if not duplicate etc..
    puts "session id is #{session[:UserID]}"
    DB[:EXERCISES] << {Name: params[:Name], UserID: session[:UserID]}
end