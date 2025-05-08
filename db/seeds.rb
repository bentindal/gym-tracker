# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Create or update admin user
admin_user = User.find_or_initialize_by(email: 'admin@example.com')
admin_user.update!(
  first_name: 'Admin',
  last_name: 'User',
  password: 'password123',
  role: 'admin'
)

# Create or update demo user
demo_user = User.find_or_initialize_by(email: 'demo@example.com')
demo_user.update!(
  first_name: 'Demo',
  last_name: 'User',
  password: 'password123'
)

# Create exercises with their categories and units
exercises = [
  { name: 'Bench Press', group: 'Chest', unit: 'kg' },
  { name: 'Incline Bench Press', group: 'Chest', unit: 'kg' },
  { name: 'Squats', group: 'Legs', unit: 'kg' },
  { name: 'Deadlift', group: 'Back', unit: 'kg' },
  { name: 'Overhead Press', group: 'Shoulders', unit: 'kg' }
]

exercise_records = exercises.map do |exercise|
  Exercise.find_or_create_by!(
    name: exercise[:name],
    group: exercise[:group],
    unit: exercise[:unit],
    user: demo_user
  )
end

# Create workouts for the past week
workout_dates = [
  Time.zone.now - 6.days - 14.hours,  # 6 days ago at 10 AM
  Time.zone.now - 4.days - 15.hours,  # 4 days ago at 9 AM
  Time.zone.now - 3.days - 13.hours,  # 3 days ago at 11 AM
  Time.zone.now - 1.day - 14.hours # Yesterday at 10 AM
]

workout_dates.each do |date|
  # Select 3 random exercises for this workout
  workout_exercises = exercise_records.sample(3)

  workout = Workout.create!(
    user: demo_user,
    started_at: date,
    ended_at: date + 1.hour,
    title: "Workout on #{date.strftime('%A')}",
    exercises_used: workout_exercises.length,
    sets_completed: 12
  )

  # Add sets to each workout, one for each exercise
  workout_exercises.each do |exercise|
    3.times do
      Allset.create!(
        exercise: exercise,
        user: demo_user,
        weight: rand(50..150),
        repetitions: rand(5..12),
        belongs_to_workout: workout.id,
        created_at: date + rand(5..55).minutes
      )
    end
  end
end

# Create today's workout
today_exercises = exercise_records.sample(3)
today_time = Time.zone.now - 2.hours # 2 hours ago

today_workout = Workout.create!(
  user: demo_user,
  started_at: today_time,
  ended_at: today_time + 1.hour,
  title: "Today's Workout",
  exercises_used: today_exercises.length,
  sets_completed: 12
)

# Add sets to today's workout
today_exercises.each do |exercise|
  3.times do
    Allset.create!(
      exercise: exercise,
      user: demo_user,
      weight: rand(50..150),
      repetitions: rand(5..12),
      belongs_to_workout: today_workout.id,
      created_at: today_time + rand(5..55).minutes
    )
  end
end
