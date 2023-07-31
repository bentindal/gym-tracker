desc 'Check for any unassigned workouts inactive for over an hour, and assign them to a workout.'
task :assign_workouts => :environment do
  puts "[#{Time.now}] Checking for unassigned workouts..."
  User.all.each do |user|
    
      @unassigned_sets = Allset.where(user_id: user.id, belongs_to_workout: nil).group_by(&:exercise)
      @sets = Allset.where(user_id: user.id, belongs_to_workout: nil)
      
      if @unassigned_sets.length > 0 && @sets.last.created_at <= Time.now - 1.hour
          @workout = Workout.new
          @workout.user_id = user.id
          @workout.started_at = @sets.first.created_at
          @workout.ended_at = @sets.last.created_at
          @workout.save

          @sets.each do |item|
          item.belongs_to_workout = @workout.id
          item.save
          end

          puts "#{@sets.length} sets assigned to workout #{@workout.id} successfully for user #{user.id}"
      else
          puts "No sets for user #{user.id}."
      end
  end
end
