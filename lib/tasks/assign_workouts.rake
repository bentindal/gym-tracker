# frozen_string_literal: true

desc 'Check for any unassigned workouts inactive for over an hour, and assign them to a workout.'
task assign_workouts: :environment do
  puts "[#{Time.zone.now}] Checking for unassigned workouts..."
  User.find_each do |user|
    @unassigned_sets = Allset.where(user_id: user.id, belongs_to_workout: nil).group_by(&:exercise)
    @sets = Allset.where(user_id: user.id, belongs_to_workout: nil)

    if @unassigned_sets.length.positive? && @sets.last.created_at <= 1.hour.ago
      @workout = Workout.new
      @workout.user_id = user.id
      @workout.started_at = @sets.first.created_at
      @workout.ended_at = @sets.last.created_at
      @workout.title = @unassigned_sets.keys.map(&:group).uniq.join(', ').reverse.sub(',', '& ').reverse
      @workout.exercises_used = @unassigned_sets.length
      @workout.sets_completed = @sets.length

      if @workout.save
        @sets.each do |item|
          item.belongs_to_workout = @workout.id
          item.save
        end
        puts "#{@sets.length} sets assigned to workout #{@workout.id} successfully for user #{user.id}"
      else
        Rails.logger.error "Failed to create workout for user #{user.id}: #{@workout.errors.full_messages.join(', ')}"
        puts "Failed to create workout for user #{user.id}: #{@workout.errors.full_messages.join(', ')}"
      end
    else
      puts "No sets for user #{user.id}."
    end
  rescue StandardError => e
    Rails.logger.error "Error processing user #{user.id}: #{e.message}\n#{e.backtrace.join("\n")}"
    puts "Error processing user #{user.id}: #{e.message}"
  end
rescue StandardError => e
  Rails.logger.error "Fatal error in assign_workouts task: #{e.message}\n#{e.backtrace.join("\n")}"
  puts "Fatal error in assign_workouts task: #{e.message}"
end
