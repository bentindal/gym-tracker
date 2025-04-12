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
    {
      'Chest' => 'primary',
      'Back' => 'danger',
      'Legs' => 'success',
      'Shoulders' => 'warning',
      'Triceps' => 'info',
      'Biceps' => 'info',
      'Other' => 'info'
    }.each do |group, colour|
      it "returns #{colour} for #{group} exercises" do
        exercise = build(:exercise, group: group)
        expect(exercise.group_colour).to eq(colour)
      end
    end
  end

  describe '#sets' do
    it 'returns all sets for the exercise' do
      exercise = create(:exercise)
      set = create(:allset, exercise: exercise)
      expect(exercise.sets).to include(set)
    end
  end

  describe '#workouts_in_range' do
    it 'returns sets within the given date range excluding warmup sets' do
      exercise = create(:exercise)
      included_set = create(:allset, exercise: exercise, created_at: 1.day.ago)
      excluded_set = create(:allset, exercise: exercise, created_at: 3.days.ago)
      warmup_set = create(:allset, exercise: exercise, created_at: 1.day.ago, isWarmup: true)

      sets = exercise.workouts_in_range(2.days.ago, Time.zone.now)

      expect(sets).to include(included_set)
      expect(sets).not_to include(excluded_set)
      expect(sets).not_to include(warmup_set)
    end
  end

  describe '#workouts_on_date' do
    context 'with mixed sets' do
      let(:exercise) { create(:exercise) }
      let(:date) { Time.zone.today }
      let!(:regular_set) { create(:allset, exercise: exercise, created_at: date.noon) }
      let!(:warmup_set) { create(:allset, exercise: exercise, created_at: date.noon, isWarmup: true) }
      let!(:other_date_set) { create(:allset, exercise: exercise, created_at: 1.day.ago) }

      it 'excludes warmup sets' do
        sets = exercise.workouts_on_date(date.day, date.month, date.year)
        expect(sets).not_to include(warmup_set)
      end

      it 'excludes sets from other dates' do
        sets = exercise.workouts_on_date(date.day, date.month, date.year)
        expect(sets).not_to include(other_date_set)
      end
    end

    context 'with regular sets' do
      let(:exercise) { create(:exercise) }
      let(:date) { Time.zone.today }

      before do
        @sets = create_list(:allset, 3, exercise: exercise, created_at: date.noon)
      end

      it 'includes all sets for that date' do
        sets = exercise.workouts_on_date(date.day, date.month, date.year)
        @sets.each { |set| expect(sets).to include(set) }
      end

      it 'returns the correct number of sets' do
        sets = exercise.workouts_on_date(date.day, date.month, date.year)
        expect(sets.count).to eq(3)
      end
    end
  end

  describe '#graph_total_volume' do
    context 'with date range' do
      let(:exercise) { create(:exercise) }
      let(:today) { Time.zone.today }
      let(:yesterday) { 1.day.ago.to_date }

      before do
        create(:allset, exercise: exercise, weight: 100, repetitions: 10, created_at: today.noon)
        create(:allset, exercise: exercise, weight: 90, repetitions: 12, created_at: yesterday.noon)
      end

      it 'returns data for the correct number of days' do
        data = exercise.graph_total_volume(yesterday.strftime('%Y-%m-%d'), today.strftime('%Y-%m-%d'))
        expect(data.length).to eq(2)
      end

      it 'calculates correct volume for today' do
        data = exercise.graph_total_volume(today.strftime('%Y-%m-%d'), today.strftime('%Y-%m-%d'))
        expect(data[today.strftime('%d/%m')]).to eq(1000) # 100 * 10
      end

      it 'calculates correct volume for yesterday' do
        data = exercise.graph_total_volume(yesterday.strftime('%Y-%m-%d'), yesterday.strftime('%Y-%m-%d'))
        expect(data[yesterday.strftime('%d/%m')]).to eq(1080) # 90 * 12
      end
    end
  end

  describe '#graph_orm' do
    context 'with date range' do
      let(:exercise) { create(:exercise) }
      let(:today) { Time.zone.today }
      let(:yesterday) { 1.day.ago.to_date }

      before do
        create(:allset, exercise: exercise, weight: 100, repetitions: 10, created_at: today.noon)
        create(:allset, exercise: exercise, weight: 90, repetitions: 12, created_at: yesterday.noon)
      end

      it 'returns data for the correct number of days' do
        data = exercise.graph_orm(yesterday.strftime('%Y-%m-%d'), today.strftime('%Y-%m-%d'))
        expect(data.length).to eq(2)
      end

      it 'calculates correct ORM for today' do
        data = exercise.graph_orm(today.strftime('%Y-%m-%d'), today.strftime('%Y-%m-%d'))
        expect(data[today.strftime('%d/%m')]).to eq(133) # Using Brzycki formula
      end

      it 'calculates correct ORM for yesterday' do
        data = exercise.graph_orm(yesterday.strftime('%Y-%m-%d'), yesterday.strftime('%Y-%m-%d'))
        expect(data[yesterday.strftime('%d/%m')]).to eq(126) # Using Brzycki formula
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
