# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

User.create(first_name: "test1", last_name: "test1", username: "test1", email: "test1", password: "test1")
User.create(first_name: "test2", last_name: "test2", username: "test2", email: "test2", password: "test2")

Exercise.create(user_id: 1, name: "Bench Press", unit: "kg", group: "Chest")
Exercise.create(user_id: 1, name: "Incline Bench Press", unit: "kg", group: "Chest")
Exercise.create(user_id: 1, name: "Dips", unit: "kg", group: "Legs")

Exercise.create(user_id: 2, name: "Machine Shoulder Press", unit: "kg", group: "Back")
Exercise.create(user_id: 2, name: "Dumbbell Bicep Curls", unit: "kg/db", group: "Back")

Workout.create(user_id: 1, exercise_id: 1, repetitions: 10, weight: 100)
Workout.create(user_id: 1, exercise_id: 1, repetitions: 9, weight: 100)
Workout.create(user_id: 1, exercise_id: 1, repetitions: 3, weight: 120)

Workout.create(user_id: 1, exercise_id: 2, repetitions: 8, weight: 100)
Workout.create(user_id: 1, exercise_id: 2, repetitions: 10, weight: 100)
Workout.create(user_id: 1, exercise_id: 2, repetitions: 4, weight: 100)

Workout.create(user_id: 1, exercise_id: 3, repetitions: 8, weight: 0)
Workout.create(user_id: 1, exercise_id: 3, repetitions: 8, weight: 0)

Workout.create(user_id: 2, exercise_id: 4, repetitions: 10, weight: 100)
Workout.create(user_id: 2, exercise_id: 4, repetitions: 9, weight: 100)

Workout.create(user_id: 2, exercise_id: 5, repetitions: 8, weight: 100)
Workout.create(user_id: 2, exercise_id: 5, repetitions: 8, weight: 100)