require "logger"
require "sequel"

def getAllGroupNames(userID)
    t = DB[:EXERCISES].where(UserID: userID)
    list = []
    x=0
    t.each do |e|
        list[x] = e[:GroupName]
        x += 1
    end
    list.uniq!
end

def getLastWorkoutDate(userID, exID)
    allUsersExercises = DB[:EXERCISES].where(ExID: exID)
    list = []
    x=0
    allUsersExercises.each do |ex|
        t = DB[:WORKOUTS].where(ExID: ex[:ExID]) # Gets all sets for that exercise
        t.each do |set|
            list[x] = set[:Date]
            x += 1
        end
    end
    list.uniq!
    list = list.sort_by{|d| m,d,y=d.split("/");[y,m,d]}
    list = list[list.length-1]
end
