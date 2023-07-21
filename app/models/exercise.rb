class Exercise < ApplicationRecord
    def user
        return User.find(self.user_id)
    end
    def workouts
        return Workout.where(exercise_id: self.id)
    end
    def workouts_in_range(from, to)
        return Workout.where(exercise_id: self.id, created_at: from..to, isWarmup: false)
    end
    def workouts_on_date(date)
        return Workout.where(exercise_id: self.id, created_at: date.beginning_of_day..date.end_of_day, isWarmup: false)
    end
    def graph_total_volume(from, to)
        graph_data = {}

        startPoint = DateTime.parse(from)
        endPoint = DateTime.parse(to).end_of_day

        while startPoint < endPoint
            sets = self.workouts_on_date(startPoint)
            # Do something with sets e.g calculate total volume
            total_volume = 0
            sets.each do |set|
                # Skip any sets that have nil values
                if set.weight.nil? || set.repetitions.nil?
                    next
                end
                total_volume += set.weight * set.repetitions
            end

            # Only add to graph if there is data for this day
            if total_volume != 0
                graph_data[startPoint.strftime("%d/%m")] = total_volume
            #else
            #    graph_data[startPoint] = 0
            end
            
            # Iterate to next day and continue
            startPoint += 1.day
        end

        return graph_data
    end
    def graph_orm(from, to)
        
        graph_data = {}

        startPoint = DateTime.parse(from)
        endPoint = DateTime.parse(to).end_of_day

        while startPoint < endPoint
            
            sets = self.workouts_on_date(startPoint)
            # Do something with sets e.g calculate total volume
            highest_orm = 0
            sets.each do |set|
                orm = 0
                # Skip any sets that have nil values
                if set.weight.nil? || set.repetitions.nil?
                    next
                end
                orm = set.weight * (1 + (set.repetitions / 30.0))
                if orm > highest_orm
                    highest_orm = orm
                end
            end
            # Round to 2 decimal places
            highest_orm = highest_orm.round(2)

            # Only add to graph if there is data for this day
            if highest_orm != 0
                graph_data[startPoint.strftime("%d/%m")] = highest_orm
            #else
            #    graph_data[startPoint]
            end
            
            # Iterate to next day and continue
            startPoint += 1.day
        end

        return graph_data
    end
end
