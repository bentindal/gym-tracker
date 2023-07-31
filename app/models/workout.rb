class Workout < ApplicationRecord
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
        
        # Go through each exercise get its group name
        groups = []
        all_sets_by_exercise.each do |exerciseandsets|
            groups.push(exerciseandsets[0].group)
        end
        # Get rid of duplicates
        groups = groups.uniq
        # Get rid of nils
        groups = groups.compact
        
        group_title = ""
        if groups.length == 1
            group_title = groups[0]
        elsif groups.length == 2
            group_title = "#{groups[0]} and #{groups[1]}"
        else
            group_title = groups[0..-2].join(", ") + " and #{groups[-1]}"
        end
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
        statistics = {"total_exercises" => all_sets_by_exercise.length, "total_groups" => groups.uniq.length, "total_sets" => all_sets.length, "length" => length, "length_in_seconds" => (self.ended_at - self.started_at).to_i}
        return [self.started_at, User.find(self.user_id), all_sets_by_exercise, [groups.first, group_title], statistics]
    end
end
