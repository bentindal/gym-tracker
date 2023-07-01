class Workout < ApplicationRecord
    def user
        return User.find(self.user_id)
    end
    def exercise
        Exercise.find(self.exercise_id)
    end
end
