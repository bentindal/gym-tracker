class Workout < ApplicationRecord
    def allsets
        return Allset.where(belongs_to_workout: self.id)
    end
    def feed
        # Put into feed format [date, user, [[exercises, sets]]]
        @feed = []
        all = []
        # Get all sets that belong_to_workout this
        all_sets = Allset.where(belongs_to_workout: self.id)
        # Split all_sets into groups by exercise
        all_sets_by_exercise = all_sets.group_by(&:exercise)
        # Change from hash to list
        all_sets_by_exercise = all_sets_by_exercise.to_a

        return all_sets_by_exercise
    end
    def likes_count
        return Like.where(workout_id: self.id).length
    end
    def liked_by
        # List of users who liked this workout as their names
        @liked_by = []
        likes = Like.where(workout_id: self.id)
        likes.each do |like|
            user = User.find(like.user_id)
            @liked_by.push(user.name)
        end
        return @liked_by
    end
    def user
        return User.find(self.user_id)
    end
    def group_colour
        return Allset.where(belongs_to_workout: self.id).first.exercise.group_colour
    end
    def length_string
        length_in_seconds = (self.ended_at - self.started_at).to_i
        # Convert to hr, min, sec
        hours = length_in_seconds / 3600
        minutes = (length_in_seconds - (hours * 3600)) / 60
        seconds = length_in_seconds - (hours * 3600) - (minutes * 60)
        # Convert to string
        length = ""
        if hours > 0
            length = "#{hours}h #{minutes}m #{seconds}s"
        else
            length = "#{minutes}m #{seconds}s"
        end
    end
end
