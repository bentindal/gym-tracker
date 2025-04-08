# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe Exercise do
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

    it 'returns warning for Shoulders exercises' do
      shoulder_exercise = create(:exercise, group: 'Shoulders')
      expect(shoulder_exercise.group_colour).to eq('warning')
    end

    it 'returns info for Triceps exercises' do
      triceps_exercise = create(:exercise, group: 'Triceps')
      expect(triceps_exercise.group_colour).to eq('info')
    end

    it 'returns info for Biceps exercises' do
      biceps_exercise = create(:exercise, group: 'Biceps')
      expect(biceps_exercise.group_colour).to eq('info')
    end

    it 'returns info for other exercise groups' do
      other_exercise = create(:exercise, group: 'Other')
      expect(other_exercise.group_colour).to eq('info')
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

  describe '#workouts_in_range' do
    before do
      # Create sets on different dates
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, isWarmup: false,
                    created_at: 2.days.ago)
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 110, repetitions: 8, isWarmup: false,
                    created_at: 1.day.ago)
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 120, repetitions: 6, isWarmup: true,
                    created_at: Time.zone.now)
    end

    it 'returns sets within the given date range excluding warmup sets' do
      from = 3.days.ago.to_s
      to = Time.zone.now.to_s
      result = exercise.workouts_in_range(from, to)
      expect(result.count).to eq(2)
    end
  end

  describe '#workouts_on_date' do
    before do
      @today = Time.zone.now
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, isWarmup: false,
                    created_at: @today)
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 110, repetitions: 8, isWarmup: false,
                    created_at: @today)
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 120, repetitions: 6, isWarmup: true,
                    created_at: @today)
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 90, repetitions: 12, isWarmup: false,
                    created_at: 1.day.ago)
    end

    it 'returns sets created on the given date excluding warmup sets' do
      result = exercise.workouts_on_date(@today)
      expect(result.count).to eq(2)
    end
  end

  describe '#graph_total_volume' do
    before do
      today = Time.zone.now
      yesterday = 1.day.ago

      # Create sets for today
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, isWarmup: false,
                    created_at: today)
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 90, repetitions: 12, isWarmup: false,
                    created_at: today)

      # Create sets for yesterday
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 95, repetitions: 10, isWarmup: false,
                    created_at: yesterday)

      # Create a warmup set that should be excluded
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 50, repetitions: 15, isWarmup: true,
                    created_at: today)
    end

    it 'calculates total volume for each day in range' do
      from = 2.days.ago.to_s
      to = Time.zone.now.to_s

      result = exercise.graph_total_volume(from, to)

      # Should have entries for 2 days (with actual workouts)
      expect(result.keys.count).to eq(2)

      # Today's volume: (100 * 10) + (90 * 12) = 1000 + 1080 = 2080
      today_key = Time.zone.now.strftime('%d/%m')
      expect(result[today_key]).to eq(2080)

      # Yesterday's volume: 95 * 10 = 950
      yesterday_key = 1.day.ago.strftime('%d/%m')
      expect(result[yesterday_key]).to eq(950)
    end
  end

  describe '#graph_orm' do
    before do
      today = Time.zone.now
      yesterday = 1.day.ago

      # Create sets for today
      # ORM formula: weight * (1 + (reps / 30.0))
      # Set 1: 100 * (1 + (10/30)) = 100 * 1.33 = 133.33
      # Set 2: 90 * (1 + (12/30)) = 90 * 1.4 = 126
      # Highest is 133.33
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, isWarmup: false,
                    created_at: today)
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 90, repetitions: 12, isWarmup: false,
                    created_at: today)

      # Create sets for yesterday
      # ORM: 95 * (1 + (10/30)) = 95 * 1.33 = 126.67
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 95, repetitions: 10, isWarmup: false,
                    created_at: yesterday)

      # Create a warmup set that should be excluded
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 50, repetitions: 15, isWarmup: true,
                    created_at: today)
    end

    it 'calculates highest ORM for each day in range' do
      from = 2.days.ago.to_s
      to = Time.zone.now.to_s

      result = exercise.graph_orm(from, to)

      # Should have entries for 2 days (with actual workouts)
      expect(result.keys.count).to eq(2)

      # Today's ORM: 100 * (1 + (10/30)) rounded to 2 decimal places = 133.33
      today_key = Time.zone.now.strftime('%d/%m')
      expect(result[today_key]).to eq(133.33)

      # Yesterday's ORM: 95 * (1 + (10/30)) rounded to 2 decimal places = 126.67
      yesterday_key = 1.day.ago.strftime('%d/%m')
      expect(result[yesterday_key]).to eq(126.67)
    end
  end
end
