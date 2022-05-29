def validateLogin(usernameAttempt, passwordAttempt)
    users = DB[:USERS]
    users.each do |user|
        if (user[:Username].chomp == usernameAttempt.chomp && user[:Password].chomp == passwordAttempt.chomp)
            puts "Login was sucessful!"
            return [true, user[:UserID], user[:Nickname]]

        else
            puts "Login failed..."
            return [false, "", ""]
        end
    end
end