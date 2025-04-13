# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'
require 'ostruct'

RSpec.describe User, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user) }
  let(:workout) { create(:workout, user: user) }
  let(:exercise) { create(:exercise, user: user) }
  let(:set) { create(:set, exercise: exercise, user: user) }

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
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_length_of(:first_name).is_at_least(2) }
    it { should validate_length_of(:last_name).is_at_least(2) }
    it { should allow_value('user@example.com').for(:email) }
    it { should_not allow_value('invalid_email').for(:email) }
  end

  describe 'associations' do
    it { should have_many(:workouts).dependent(:destroy) }
    it { should have_many(:exercises).dependent(:destroy) }
    it { should have_many(:sets).class_name('Allset').dependent(:destroy) }

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
    it 'returns the full name' do
      expect(user.name).to eq("#{user.first_name} #{user.last_name}")
    end
  end

  describe '#workout_count' do
    it 'returns the number of workouts' do
      create(:workout, user: user)
      expect(user.workout_count).to eq(2)
    end
  end

  describe '#has_worked_out_today' do
    it 'returns true if user has worked out today' do
      create(:workout, user: user, started_at: Time.current)
      expect(user.has_worked_out_today).to be true
    end

    it 'returns false if user has not worked out today' do
      create(:workout, user: user, started_at: 1.day.ago)
      expect(user.has_worked_out_today).to be false
    end
  end

  describe '#worked_out_on_date' do
    it 'returns true if user worked out on the given date' do
      date = Date.current
      create(:workout, user: user, started_at: date)
      expect(user.worked_out_on_date(date.day, date.month, date.year)).to be true
    end

    it 'returns false if user did not work out on the given date' do
      date = Date.current
      create(:workout, user: user, started_at: date + 1.day)
      expect(user.worked_out_on_date(date.day, date.month, date.year)).to be false
    end
  end

  describe '#streak_count' do
    it 'returns 0 if user has never worked out' do
      expect(user.streak_count).to eq(0)
    end

    it 'returns 1 if user worked out today' do
      create(:workout, user: user, started_at: Time.current)
      expect(user.streak_count).to eq(1)
    end

    it 'returns 2 if user worked out today and yesterday' do
      create(:workout, user: user, started_at: Time.current)
      create(:workout, user: user, started_at: 1.day.ago)
      expect(user.streak_count).to eq(2)
    end

    it 'returns 0 if user worked out yesterday but not today' do
      create(:workout, user: user, started_at: 1.day.ago)
      expect(user.streak_count).to eq(0)
    end
  end

  describe '#midworkout' do
    it 'returns false if user has no sets' do
      expect(user.midworkout).to be false
    end

    it 'returns true if user has an active workout' do
      create(:set, user: user, belongs_to_workout: nil)
      expect(user.midworkout).to be true
    end

    it 'returns false if user has only completed workouts' do
      create(:set, user: user, belongs_to_workout: 1)
      expect(user.midworkout).to be false
    end
  end

  describe '#last_exercise' do
    it 'returns nil if user has no sets' do
      expect(user.last_exercise).to be_nil
    end

    it 'returns the last exercise' do
      exercise = create(:exercise, user: user)
      create(:set, exercise: exercise, user: user)
      expect(user.last_exercise).to eq(exercise)
    end
  end

  describe '#last_set' do
    it 'returns nil if user has no sets' do
      expect(user.last_set).to be_nil
    end

    it 'returns the last set' do
      set = create(:set, user: user)
      expect(user.last_set).to eq(set)
    end
  end

  describe '#last_seen' do
    it 'returns nil if user has no sets' do
      expect(user.last_seen).to be_nil
    end

    it 'returns "over a month ago" if last set was over a month ago' do
      create(:set, user: user, created_at: 2.months.ago)
      expect(user.last_seen).to eq('over a month ago')
    end

    it 'returns "X weeks ago" if last set was within a month' do
      create(:set, user: user, created_at: 2.weeks.ago)
      expect(user.last_seen).to eq('2 weeks ago')
    end

    it 'returns "X days ago" if last set was within a week' do
      create(:set, user: user, created_at: 2.days.ago)
      expect(user.last_seen).to eq('2 days ago')
    end

    it 'returns "X hours ago" if last set was within a day' do
      create(:set, user: user, created_at: 2.hours.ago)
      expect(user.last_seen).to eq('2 hours ago')
    end

    it 'returns "X minutes ago" if last set was within an hour' do
      create(:set, user: user, created_at: 2.minutes.ago)
      expect(user.last_seen).to eq('2 minutes ago')
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

  describe '#manually_end_workout' do
    context 'when user has unassigned sets' do
      let(:user) { create(:user) }
      let!(:unassigned_sets) { create_list(:allset, 3, user: user, belongs_to_workout: nil) }

      it 'creates a new workout' do
        expect { user.manually_end_workout }.to change(Workout, :count).by(1)
      end

      it 'assigns sets to the workout' do
        workout = user.manually_end_workout
        expect(unassigned_sets.all? { |set| set.reload.belongs_to_workout == workout }).to be true
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

