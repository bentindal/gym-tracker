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

# Stats Page
def getNumberOfWorkoutsLogged(userID)
    allUsersExercises = DB[:EXERCISES].where(UserID: userID)
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
    return list.length
end

def getDaysForThisMonth(userID)
    todaysMonth = Date.today.strftime("%m")
    allUsersExercises = DB[:EXERCISES].where(UserID: userID)
    list = []
    x=0
    allUsersExercises.each do |ex|
        t = DB[:WORKOUTS].where(ExID: ex[:ExID]) # Gets all sets for that exercise
        t.each do |set|
            month = set[:Date][3...5]
            if todaysMonth == month
                list[x] = set[:Date][0...2].to_i
            else
            end
            x += 1
        end
    end
    list.uniq!
    if list.length > 0
        list.sort!
    else
        return []
    end
end
