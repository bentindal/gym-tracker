# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_04_13_162610) do
  create_table "allsets", force: :cascade do |t|
    t.integer "exercise_id", null: false
    t.integer "user_id", null: false
    t.decimal "weight", precision: 5, scale: 1
    t.integer "repetitions"
    t.boolean "warmup", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "isFailure", default: false
    t.boolean "isDropset", default: false
    t.boolean "isWarmup", default: false
    t.integer "workout_id"
    t.index ["exercise_id"], name: "index_allsets_on_exercise_id"
    t.index ["user_id"], name: "index_allsets_on_user_id"
    t.index ["workout_id"], name: "index_allsets_on_workout_id"
  end

  create_table "exercises", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "unit"
    t.string "group"
    t.datetime "last_set", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "friends", force: :cascade do |t|
    t.integer "user"
    t.integer "follows"
    t.boolean "confirmed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "workout_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_public"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workout_analyses", force: :cascade do |t|
    t.integer "workout_id", null: false
    t.decimal "total_volume", precision: 10, scale: 2
    t.integer "total_sets"
    t.integer "total_reps"
    t.decimal "average_weight", precision: 10, scale: 2
    t.text "feedback"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workout_id"], name: "index_workout_analyses_on_workout_id"
  end

  create_table "workouts", force: :cascade do |t|
    t.datetime "started_at", precision: nil
    t.datetime "ended_at", precision: nil
    t.integer "user_id"
    t.string "title"
    t.integer "exercises_used"
    t.integer "sets_completed"
    t.integer "allset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allset_id"], name: "index_workouts_on_allset_id"
  end

  add_foreign_key "allsets", "exercises"
  add_foreign_key "allsets", "users"
  add_foreign_key "workout_analyses", "workouts"
  add_foreign_key "workouts", "allsets"
end
