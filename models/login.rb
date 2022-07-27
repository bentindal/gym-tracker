def validateLogin(usernameAttempt, passwordAttempt)
    users = DB[:USERS]
    users.each do |user|
        if (user[:Username].chomp == usernameAttempt.chomp && user[:Password].chomp == passwordAttempt.chomp)
            puts "Login was sucessful!"
            return [true, user[:UserID], user[:Nickname]]

        else
            puts "Login failed..."
        end
    end
    return [false, "", ""]
end

def registerUser(d)
    # First check username is unique
    DB[:USERS].each do |user|
        if (user[:Username]) == d[:username]
            return [false, "Account with that username already exists"]
        end
    end
    # Check password+retyped password are equal
    if (d[:password] != d[:password2])
        return [false, "Passwords did not match"]
    end
    # If both checks pass then add user to db
    DB[:USERS] << {Username: d[:username], Password: d[:password], Nickname: d[:nickname], Email: d[:email]}
    return [true, "Success"]
end