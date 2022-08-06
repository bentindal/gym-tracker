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