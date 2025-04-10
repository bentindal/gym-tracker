# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

describe Exercise do
  let(:user) { create(:user) }
  let(:exercise) { create(:exercise, user_id: user.id) }
  let(:today) { Time.zone.today }

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
    context 'with mixed sets' do
      before do
        create_set(weight: 100, reps: 10, warmup: false, date: today)
        create_set(weight: 110, reps: 8, warmup: false, date: today)
        create_set(weight: 120, reps: 6, warmup: true, date: today)
        create_set(weight: 90, reps: 12, warmup: false, date: 1.day.ago)
      end

      it 'excludes warmup sets' do
        result = exercise.workouts_on_date(today)
        expect(result.count).to eq(2)
      end

      it 'excludes sets from other dates' do
        result = exercise.workouts_on_date(today)
        expect(result.pluck(:created_at).map(&:to_date).uniq).to eq([today])
      end
    end

    context 'with regular sets' do
      let(:heavy_set) { create_set(weight: 120, reps: 6, warmup: false, date: today) }
      let(:medium_set) { create_set(weight: 110, reps: 8, warmup: false, date: today) }
      let(:light_set) { create_set(weight: 100, reps: 10, warmup: false, date: today) }

      it 'includes all sets for that date' do
        # Create the sets
        heavy_set
        medium_set
        light_set

        result = exercise.workouts_on_date(today)
        expect(result).to include(light_set, medium_set, heavy_set)
      end

      it 'returns the correct number of sets' do
        # Create the sets
        heavy_set
        medium_set
        light_set

        result = exercise.workouts_on_date(today)
        expect(result.count).to eq(3)
      end
    end
  end

  describe '#graph_total_volume' do
    let(:today) { Time.zone.now }
    let(:yesterday) { 1.day.ago }

    before do
      create_set(weight: 100, reps: 10, warmup: false, date: today)
      create_set(weight: 90, reps: 12, warmup: false, date: today)
      create_set(weight: 95, reps: 10, warmup: false, date: yesterday)
      create_set(weight: 50, reps: 15, warmup: true, date: today)
    end

    context 'with date range' do
      let(:result) { exercise.graph_total_volume(2.days.ago.to_s, Time.zone.now.to_s) }

      it 'returns data for the correct number of days' do
        expect(result.keys.count).to eq(2)
      end

      it 'calculates correct volume for today' do
        expect(result[today.strftime('%d/%m')]).to eq(2080) # (100 * 10) + (90 * 12)
      end

      it 'calculates correct volume for yesterday' do
        expect(result[yesterday.strftime('%d/%m')]).to eq(950) # 95 * 10
      end
    end
  end

  describe '#graph_orm' do
    let(:today) { Time.zone.now }
    let(:yesterday) { 1.day.ago }

    before do
      create_set(weight: 100, reps: 10, warmup: false, date: today)
      create_set(weight: 90, reps: 12, warmup: false, date: today)
      create_set(weight: 95, reps: 10, warmup: false, date: yesterday)
      create_set(weight: 50, reps: 15, warmup: true, date: today)
    end

    context 'with date range' do
      let(:result) { exercise.graph_orm(2.days.ago.to_s, Time.zone.now.to_s) }

      it 'returns data for the correct number of days' do
        expect(result.keys.count).to eq(2)
      end

      it 'calculates correct ORM for today' do
        expect(result[today.strftime('%d/%m')]).to eq(133.33) # 100 * (1 + (10/30))
      end

      it 'calculates correct ORM for yesterday' do
        expect(result[yesterday.strftime('%d/%m')]).to eq(126.67) # 95 * (1 + (10/30))
      end
    end
  end

  private

  def create_set(weight:, reps:, warmup:, date:)
    Allset.create(
      exercise_id: exercise.id,
      user_id: user.id,
      weight: weight,
      repetitions: reps,
      isWarmup: warmup,
      created_at: date.to_time
    )
  end
end
