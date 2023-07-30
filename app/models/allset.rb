class Allset < ApplicationRecord
    def user
        return User.find(self.user_id)
    end
    def exercise
        return Exercise.find(self.exercise_id)
    end
end
