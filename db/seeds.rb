# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create(first_name: "Ben", last_name: "Tindal", username: "bentindal", email: "ben@staff", password: "password")

Exercise.create(user_id: 1, name: "Bench Press", unit: "kg", group: "Chest")
Exercise.create(user_id: 1, name: "Incline Bench Press", unit: "kg", group: "Chest")
Exercise.create(user_id: 1, name: "Squat", unit: "kg", group: "Legs")

Workout.create(user_id: 1, exercise_id: 1, repetitions: 10, weight: 100)
Workout.create(user_id: 1, exercise_id: 1, repetitions: 9, weight: 100)
Workout.create(user_id: 1, exercise_id: 1, repetitions: 3, weight: 120)
Workout.create(user_id: 1, exercise_id: 1, repetitions: 8, weight: 100)
Workout.create(user_id: 1, exercise_id: 1, repetitions: 10, weight: 100)
Workout.create(user_id: 1, exercise_id: 1, repetitions: 4, weight: 100)
Workout.create(user_id: 1, exercise_id: 1, repetitions: 8, weight: 100)
Workout.create(user_id: 1, exercise_id: 1, repetitions: 8, weight: 100)

Workout.create(user_id: 1, exercise_id: 2, repetitions: 10, weight: 100)
Workout.create(user_id: 1, exercise_id: 2, repetitions: 9, weight: 100)
Workout.create(user_id: 1, exercise_id: 2, repetitions: 8, weight: 100)
Workout.create(user_id: 1, exercise_id: 2, repetitions: 8, weight: 100)