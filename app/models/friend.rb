# frozen_string_literal: true

# Represents a friendship relationship between two users
class Friend < ApplicationRecord
  belongs_to :follower, class_name: 'User', foreign_key: 'user', inverse_of: :friends
  belongs_to :followed, class_name: 'User', foreign_key: 'follows', inverse_of: :followed_by
end
