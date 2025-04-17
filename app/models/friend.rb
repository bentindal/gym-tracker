# frozen_string_literal: true

class Friend < ApplicationRecord
  belongs_to :follower, class_name: 'User', foreign_key: 'user'
  belongs_to :followed, class_name: 'User', foreign_key: 'follows'
end
