class Exercise < ApplicationRecord
    def user
        return User.find(self.user_id)
    end
end
