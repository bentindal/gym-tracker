# frozen_string_literal: true

class Set < ApplicationRecord
  belongs_to :exercise
  validates :reps, presence: true
  validates :weight, presence: true
end 