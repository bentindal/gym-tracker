# frozen_string_literal: true

class Allset < ApplicationRecord
  def user
    User.find(user_id)
  end

  def exercise
    Exercise.find(exercise_id)
  end
end
