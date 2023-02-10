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
    list = list.sort_by{|d| d,m,y=d.split("/");[y,m,d]}
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

def getDaysForMonth(userID, monthNum, yearNum)
    allUsersExercises = DB[:EXERCISES].where(UserID: userID)
    list = []
    x=0
    allUsersExercises.each do |ex|
        t = DB[:WORKOUTS].where(ExID: ex[:ExID]) # Gets all sets for that exercise
        t.each do |set|
            month = set[:Date][3...5]
            year = set[:Date][6...10]
            if monthNum == month && yearNum == year
                if set[:Date][0...2].to_i # If the day is a number
                    list[x] = set[:Date][0...2].to_i
                end
            else
            end
            x += 1
        end
    end
    list.uniq!
    if list[0].class != Integer
        list[0] = -1
    end
    if list[list.length-1].class != Integer
        list[list.length-1] = -1
    end
    if list.length > 0
        bubbleSort(list)
    else
        return []
    end
end

def bubbleSort(list)
    n = list.length
    loop do
        swapped = false
        (n-1).times do |i|
            begin
                if list[i] > list[i+1]
                    list[i], list[i+1] = list[i+1], list[i]
                    swapped = true
                end
            rescue ArgumentError, NoMethodError => e
                puts "Error Captured: (#{e}), happened whilst comparing #{list[i]} and #{list[i+1]}"
            end
        end
        break if not swapped
    end
    list
end

def daysInMonth(month)
    Date.new(2022, month.to_i, -1).day
end

def numberToMonth(num)
    case num
    when "1"
        return "January"
    when "2"
        return "February"
    when "3"
        return "March"
    when "4"
        return "April"
    when "5"
        return "May"
    when "6"
        return "June"
    when "7"
        return "July"
    when "8"
        return "August"
    when "9"
        return "September"
    when "10"
        return "October"
    when "11"
        return "November"
    when "12"
        return "December"
    end
end

def getAllWorkoutDatesByID(userID)
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
end

def nextMonthYear(month, year)
    if month == 12
        return 1, year+1
    else
        return month+1, year
    end
end

def previousMonthYear(month, year)
    if month == 1
        return 12, year-1
    else
        return month-1, year
    end
end