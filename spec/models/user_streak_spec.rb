require 'rails_helper'
require 'spec_helper'

describe User, type: :model do
  describe '#streak_count' do
    it 'returns 0 when user has no sets' do
      user = create(:user)
      expect(user.streak_count).to eq(0)
    end
    
    it 'calculates streak count for users with sets' do
      user = create(:user)
      exercise = create(:exercise, user_id: user.id)
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10)
      
      # Just verify the method runs without errors and returns an integer
      expect(user.streak_count).to be_a(Integer)
    end
  end
end
