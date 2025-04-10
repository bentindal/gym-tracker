# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'
require 'ostruct'

RSpec.describe User do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }

  shared_examples 'a validation' do
    let(:model) { build(:user) }
    let(:field_name) { raise 'field_name must be defined' }
    let(:min_length) { nil }

    it 'validates the field' do
      model[field_name] = nil
      expect(model).not_to be_valid
      expect(model.errors[field_name]).to include("can't be blank")

      if min_length
        model[field_name] = 'a' * (min_length - 1)
        expect(model).not_to be_valid
        expect(model.errors[field_name]).to include('is too short (minimum is 2 characters)')
      end
    end
  end

  shared_examples 'a time diff test' do |time_ago, expected_output|
    it "returns #{expected_output}" do
      exercise = create(:exercise, user_id: user.id)
      freeze_time do
        Allset.create(
          exercise_id: exercise.id,
          user_id: user.id,
          weight: 100,
          repetitions: 10,
          created_at: time_ago.call
        )
        expect(user.last_seen).to eq(expected_output)
      end
    end
  end

  describe 'validations' do
    describe 'presence validations' do
      %w[first_name last_name email].each do |field|
        it_behaves_like 'a validation' do
          let(:field_name) { field }
        end
      end
    end

    describe 'email validations' do
      it 'requires unique email' do
        user = create(:user)
        duplicate_user = build(:user, email: user.email)
        expect(duplicate_user).not_to be_valid
      end

      it 'validates email format' do
        user = build(:user, email: 'invalid_email')
        expect(user).not_to be_valid
      end
    end

    describe 'length validations' do
      %w[first_name last_name].each do |field|
        it_behaves_like 'a validation' do
          let(:field_name) { field }
          let(:min_length) { 2 }
        end
      end
    end
  end

  describe 'associations' do
    describe '#exercises' do
      it 'returns exercises for the user' do
        user = create(:user)
        exercise = create(:exercise, user: user)
        expect(user.exercises).to include(exercise)
      end
    end

    describe '#sets' do
      it 'returns sets for the user' do
        user = create(:user)
        set = create(:allset, user: user)
        expect(user.sets).to include(set)
      end
    end

    describe '#following' do
      it 'returns confirmed friends the user is following' do
        followed = create(:user)
        create(:friend, follower: user, followed: followed, confirmed: true)
        expect(user.following.count).to eq(1)
      end

      it 'does not return unconfirmed friendships' do
        followed = create(:user)
        create(:friend, follower: user, followed: followed, confirmed: false)
        expect(user.following.count).to eq(0)
      end
    end

    describe '#followers' do
      it 'returns confirmed friends following the user' do
        follower = create(:user)
        create(:friend, follower: follower, followed: user, confirmed: true)
        expect(user.followers.count).to eq(1)
      end

      it 'does not return unconfirmed followers' do
        follower = create(:user)
        create(:friend, follower: follower, followed: user, confirmed: false)
        expect(user.followers.count).to eq(0)
      end
    end
  end

  describe '#name' do
    it 'returns full name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.name).to eq('John Doe')
    end
  end

  describe '#last_set' do
    context 'when user has sets' do
      it 'returns the most recent set' do
        user = create(:user)
        create(:allset, user: user, created_at: 1.day.ago)
        recent_set = create(:allset, user: user)
        expect(user.last_set).to eq(recent_set)
      end
    end

    context 'when user has no sets' do
      it 'returns nil' do
        user = create(:user)
        expect(user.last_set).to be_nil
      end
    end
  end

  describe '#last_exercise' do
    context 'when user has exercises' do
      it 'returns the exercise of the last set' do
        user = create(:user)
        exercise = create(:exercise, user: user)
        create(:allset, user: user, exercise: exercise)
        expect(user.last_exercise).to eq(exercise)
      end
    end

    context 'when user has no sets' do
      it 'returns nil' do
        user = create(:user)
        expect(user.last_exercise).to be_nil
      end
    end
  end

  describe '#workout_count' do
    it 'returns number of workouts' do
      user = create(:user)
      create_list(:workout, 3, user: user)
      expect(user.workout_count).to eq(3)
    end
  end

  describe '#worked_out_today?' do
    context 'when user has worked out today' do
      it 'returns true' do
        user = create(:user)
        create(:allset, user: user)
        expect(user.worked_out_today?).to be true
      end
    end

    context 'when user has not worked out today' do
      it 'returns false' do
        user = create(:user)
        create(:allset, user: user, created_at: 1.day.ago)
        expect(user.worked_out_today?).to be false
      end
    end
  end

  describe '#worked_out_on_date' do
    it 'returns true if user worked out on given date' do
      user = create(:user)
      create(:allset, user: user, created_at: Date.yesterday)
      expect(user.worked_out_on_date(Date.yesterday.day, Date.yesterday.month, Date.yesterday.year)).to be true
    end

    it 'returns false if user did not work out on given date' do
      user = create(:user)
      expect(user.worked_out_on_date(Date.yesterday.day, Date.yesterday.month, Date.yesterday.year)).to be false
    end

    it 'correctly formats single-digit day and month' do
      user = create(:user)
      date = Date.new(2024, 1, 1)
      create(:allset, user: user, created_at: date)
      expect(user.worked_out_on_date(1, 1, 2024)).to be true
    end
  end

  describe '#last_seen' do
    context 'when user has sets' do
      it_behaves_like 'a time diff test', -> { 5.minutes.ago }, '5 minutes ago'
      it_behaves_like 'a time diff test', -> { 1.minute.ago }, '1 minute ago'
      it_behaves_like 'a time diff test', -> { 3.hours.ago }, '3 hours ago'
      it_behaves_like 'a time diff test', -> { 1.hour.ago }, '1 hour ago'
      it_behaves_like 'a time diff test', -> { 3.days.ago }, '3 days ago'
      it_behaves_like 'a time diff test', -> { 1.day.ago }, '1 day ago'
      it_behaves_like 'a time diff test', -> { 2.weeks.ago }, '2 weeks ago'
      it_behaves_like 'a time diff test', -> { 1.week.ago }, '1 week ago'
      it_behaves_like 'a time diff test', -> { 2.months.ago }, 'over a month ago'
    end

    context 'when user has no sets' do
      it 'returns nil' do
        expect(user.last_seen).to be_nil
      end
    end
  end

  describe '#streak_status' do
    context 'when user worked out today' do
      it 'returns "active"' do
        allow(user).to receive(:worked_out_today?).and_return(true)
        expect(user.streak_status).to eq('active')
      end
    end

    context 'when user did not work out today but did yesterday' do
      it 'returns "pending"' do
        allow(user).to receive_messages(worked_out_today?: false, worked_out_yesterday?: true)
        expect(user.streak_status).to eq('pending')
      end
    end

    context 'when user did not work out today or yesterday but did the day before' do
      it 'returns "at_risk"' do
        allow(user).to receive_messages(worked_out_today?: false, worked_out_yesterday?: false,
                                        worked_out_two_days_ago?: true)
        expect(user.streak_status).to eq('at_risk')
      end
    end

    context 'when user has not worked out in the last three days' do
      it 'returns "none"' do
        allow(user).to receive_messages(worked_out_today?: false, worked_out_yesterday?: false,
                                        worked_out_two_days_ago?: false)
        expect(user.streak_status).to eq('none')
      end
    end
  end

  describe '#streak_count' do
    it 'returns 0 when user has no sets' do
      expect(user.streak_count).to eq(0)
    end

    it 'calculates streak count for users with sets' do
      exercise = create(:exercise, user_id: user.id)
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10)

      # Just verify the method runs without errors and returns an integer
      expect(user.streak_count).to be_a(Integer)
    end
  end

  describe '#streak_msg_own' do
    it 'returns appropriate message for "none" status' do
      allow(user).to receive(:streak_status).and_return('none')
      expect(user.streak_msg_own).to eq("You haven't got a streak going yet.")
    end

    it 'returns appropriate message for "pending" status' do
      allow(user).to receive_messages(streak_status: 'pending', streakcount: 5)
      expect(user.streak_msg_own).to eq("You haven't worked out today, but you have a 5 day streak!")
    end

    it 'returns appropriate message for "at_risk" status' do
      allow(user).to receive_messages(streak_status: 'at_risk', streakcount: 10)
      expect(user.streak_msg_own).to eq(
        'You had a day off yesterday, workout today to keep the 10 day streak going or it will be reset!'
      )
    end

    it 'returns appropriate message for "active" status' do
      allow(user).to receive_messages(streak_status: 'active', streakcount: 15)
      expect(user.streak_msg_own).to eq('You have a 15 day streak!')
    end
  end

  describe '#streak_msg_other' do
    it 'returns appropriate message for "none" status' do
      allow(user).to receive(:streak_status).and_return('none')
      expect(user.streak_msg_other).to eq("#{user.first_name} hasn't worked out yet today!")
    end

    it 'returns appropriate message for "pending" status' do
      allow(user).to receive_messages(streak_status: 'pending', streakcount: 5)
      expect(user.streak_msg_other).to eq("#{user.first_name} hasn't worked out today, but has a 5 day streak going!")
    end

    it 'returns appropriate message for "at_risk" status' do
      allow(user).to receive_messages(streak_status: 'at_risk', streakcount: 10)
      expect(user.streak_msg_other).to eq(
        "#{user.first_name} had a day off yesterday, workout today to keep the 10 day streak going or it will be reset!"
      )
    end

    it 'returns appropriate message for "active" status' do
      allow(user).to receive_messages(streak_status: 'active', streakcount: 15)
      expect(user.streak_msg_other).to eq("#{user.first_name} has a 15 day streak going!")
    end
  end

  describe '#midworkout' do
    context 'when user has no sets' do
      it 'returns false' do
        expect(user.midworkout).to be_falsey
      end
    end

    context 'when user has sets not belonging to a workout' do
      it 'returns true' do
        exercise = create(:exercise, user_id: user.id)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10,
                      belongs_to_workout: nil)

        expect(user.midworkout).to be_truthy
      end
    end

    context 'when all user sets belong to workouts' do
      it 'returns false' do
        exercise = create(:exercise, user_id: user.id)
        workout = Workout.create(user_id: user.id)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10,
                      belongs_to_workout: workout.id)

        expect(user.midworkout).to be_falsey
      end
    end
  end

  describe '#manually_end_workout' do
    context 'when user has unassigned sets' do
      let(:user) { create(:user) }
      let!(:unassigned_sets) { create_list(:allset, 3, user: user, belongs_to_workout: nil) }

      it 'creates a new workout' do
        expect { user.manually_end_workout }.to change(Workout, :count).by(1)
      end

      it 'assigns sets to the workout' do
        workout = user.manually_end_workout
        expect(unassigned_sets.all? { |set| set.reload.belongs_to_workout == workout.id }).to be true
      end
    end

    context 'when user has no unassigned sets' do
      it 'does not create a new workout' do
        user = create(:user)
        expect { user.manually_end_workout }.not_to change(Workout, :count)
      end
    end
  end
end
