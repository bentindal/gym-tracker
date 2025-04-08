# frozen_string_literal: true

desc 'Check for any workouts with a missing field and recalculate its values.'
task fix_workouts: :environment do
  puts "[#{Time.now}] Checking for empty fields in workouts..."
  Workout.all.each do |workout|
    next unless [nil,
                 ''].include?(workout.title) || workout.exercises_used == ' ' || workout.exercises_used.nil? || workout.sets_completed == ' ' || workout.sets_completed.nil?

    puts "Workout #{workout.id} has a missing field. Fixing..."
    workout.title = Allset.where(belongs_to_workout: workout.id).group_by(&:exercise).keys.map(&:group).uniq.join(', ').reverse.sub(
      ',', '& '
    ).reverse
    workout.exercises_used = Allset.where(belongs_to_workout: workout.id).group_by(&:exercise).length
    workout.sets_completed = Allset.where(belongs_to_workout: workout.id).length
    workout.save
    puts "Workout #{workout.id} fixed successfully."
  end
end
