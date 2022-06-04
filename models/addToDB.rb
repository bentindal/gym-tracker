require "logger"
require "sequel"

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

class WORKOUTS < Sequel::Model
end

def editSet(sid, r, w, t, d)
    target = WORKOUTS.first(SetID: sid)
    puts "Was: #{target[:Reps]}"
    target[:Reps] = r
    puts "Now: #{target[:Reps]}"
    target.save_changes
    target[:Weight] = w
    target[:Time] = t
    target[:Date] = d
    puts "Successful edit of SetID #{sid}, #{r}"
end

def deleteSet(sid)
    target = WORKOUTS.first(SetID: sid)
    target.delete
end