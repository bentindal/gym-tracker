class Workout < ApplicationRecord
    def user
        return User.find(self.user_id)
    end
    def exercise
        # If an exercise cannot be found, return "n/a"
        Exercise.find_by(id: self.exercise_id) || "n/a"
    end
end
