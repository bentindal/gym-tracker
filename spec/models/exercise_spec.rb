require 'rails_helper'
require 'spec_helper'

describe Exercise, type: :model do
  let(:user) { create(:user) }
  let(:exercise) { create(:exercise, user_id: user.id) }
  
  describe '#user' do
    it 'returns the associated user' do
      expect(exercise.user).to eq(user)
    end
  end

  describe '#group_colour' do
    it 'returns primary for Chest exercises' do
      expect(exercise.group_colour).to eq('primary')
    end

    it 'returns danger for Back exercises' do
      back_exercise = create(:exercise, :back_exercise)
      expect(back_exercise.group_colour).to eq('danger')
    end

    it 'returns success for Legs exercises' do
      leg_exercise = create(:exercise, :leg_exercise)
      expect(leg_exercise.group_colour).to eq('success')
    end
  end

  describe '#sets' do
    before do
      3.times do
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, isWarmup: false)
      end
    end

    it 'returns all sets for the exercise' do
      expect(exercise.sets.count).to eq(3)
    end
  end
end
