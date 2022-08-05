require "logger"
require "sequel"

def getCurrentDate
    date = Time.now.strftime("%d/%m/%Y")
    return date
end

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

class EXERCISES < Sequel::Model
end
class WORKOUTS < Sequel::Model
end

def editSet(sid, r, w, t, d)
    target = WORKOUTS.first(SetID: sid)
    puts "Was: #{target[:Date]}"
    target[:Reps] = r
    target[:Weight] = w
    target[:Time] = t
    target[:Date] = d
    target.save_changes
    puts "Now: #{target[:Date]}"
    puts "Successful edit of SetID #{sid}, #{d}"
end

def deleteSet(sid)
    target = WORKOUTS.first(SetID: sid)
    target.delete
end

def editExercise(eid, n,u,g)
    target = EXERCISES.first(ExID: eid)
    target[:Name] = n
    target[:Unit] = u
    target[:GroupName] = g
    target.save_changes
end

def deleteExercise(eid)
    target = EXERCISES.first(ExID: eid)
    target.delete
end
