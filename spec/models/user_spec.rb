require 'rails_helper'
require 'spec_helper'
require 'ostruct'

describe User, type: :model do
  let(:user) { create(:user) }
  
  describe 'validations' do
    it 'requires presence of first_name, last_name, and email' do
      # Test first_name presence
      user_without_first_name = build(:user, first_name: nil)
      expect(user_without_first_name).not_to be_valid
      expect(user_without_first_name.errors[:first_name]).to include("can't be blank")
      
      # Test last_name presence
      user_without_last_name = build(:user, last_name: nil)
      expect(user_without_last_name).not_to be_valid
      expect(user_without_last_name.errors[:last_name]).to include("can't be blank")
      
      # Test email presence
      user_without_email = build(:user, email: nil)
      expect(user_without_email).not_to be_valid
      expect(user_without_email.errors[:email]).to include("can't be blank")
    end
    
    it 'requires unique email' do
      create(:user, email: 'test@example.com')
      duplicate_user = build(:user, email: 'test@example.com')
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include("has already been taken")
    end
    
    it 'requires minimum length of first_name and last_name' do
      user_with_short_first_name = build(:user, first_name: 'A')
      expect(user_with_short_first_name).not_to be_valid
      expect(user_with_short_first_name.errors[:first_name]).to include("is too short (minimum is 2 characters)")
      
      user_with_short_last_name = build(:user, last_name: 'B')
      expect(user_with_short_last_name).not_to be_valid
      expect(user_with_short_last_name.errors[:last_name]).to include("is too short (minimum is 2 characters)")
    end
    
    it 'validates email format' do
      valid_user = build(:user, email: 'valid@example.com')
      expect(valid_user).to be_valid
      
      invalid_user = build(:user, email: 'invalid-email')
      expect(invalid_user).not_to be_valid
      expect(invalid_user.errors[:email]).to include("is invalid")
    end
  end
  
  describe 'associations' do
    describe '#exercises' do
      it 'returns exercises for the user' do
        exercise = create(:exercise, user_id: user.id)
        expect(user.exercises).to include(exercise)
      end
    end
    
    describe '#sets' do
      it 'returns sets for the user' do
        exercise = create(:exercise, user_id: user.id)
        set = Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10)
        expect(user.sets).to include(set)
      end
    end
    
    describe '#following' do
      it 'returns confirmed friends the user is following' do
        other_user = create(:user)
        friendship = Friend.create(user: user.id, follows: other_user.id, confirmed: true)
        expect(user.following.count).to eq(1)
      end
      
      it 'does not return unconfirmed friendships' do
        other_user = create(:user)
        friendship = Friend.create(user: user.id, follows: other_user.id, confirmed: false)
        expect(user.following.count).to eq(0)
      end
    end
    
    describe '#followers' do
      it 'returns confirmed friends following the user' do
        other_user = create(:user)
        friendship = Friend.create(user: other_user.id, follows: user.id, confirmed: true)
        expect(user.followers.count).to eq(1)
      end
      
      it 'does not return unconfirmed followers' do
        other_user = create(:user)
        friendship = Friend.create(user: other_user.id, follows: user.id, confirmed: false)
        expect(user.followers.count).to eq(0)
      end
    end
  end
  
  describe '#name' do
    it 'returns full name' do
      expect(user.name).to eq("John Doe")
    end
  end
  
  describe '#last_set' do
    context 'when user has sets' do
      it 'returns the most recent set' do
        exercise = create(:exercise, user_id: user.id)
        set1 = Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 90, repetitions: 10, created_at: 1.day.ago)
        set2 = Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 8, created_at: Time.now)
        
        expect(user.last_set).to eq(set2)
      end
    end
    
    context 'when user has no sets' do
      it 'returns nil' do
        expect(user.last_set).to be_nil
      end
    end
  end
  
  describe '#last_exercise' do
    context 'when user has exercises' do
      it 'returns the exercise of the last set' do
        exercise = create(:exercise, user_id: user.id)
        set = Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 8)
        
        expect(user.last_exercise).to eq(exercise)
      end
    end
    
    context 'when user has no sets' do
      it 'returns nil' do
        expect(user.last_exercise).to be_nil
      end
    end
  end
  
  describe '#workout_count' do
    it 'returns number of workouts' do
      Workout.create(user_id: user.id, started_at: 1.day.ago, ended_at: 1.day.ago + 1.hour)
      Workout.create(user_id: user.id, started_at: 2.days.ago, ended_at: 2.days.ago + 1.hour)
      
      expect(user.workout_count).to eq(2)
    end
  end
  
  describe '#has_worked_out_today' do
    context 'when user has worked out today' do
      it 'returns true' do
        exercise = create(:exercise, user_id: user.id)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, created_at: Time.now)
        
        expect(user.has_worked_out_today).to be true
      end
    end
    
    context 'when user has not worked out today' do
      it 'returns false' do
        exercise = create(:exercise, user_id: user.id)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, created_at: 1.day.ago)
        
        expect(user.has_worked_out_today).to be false
      end
    end
  end
  
  describe '#worked_out_on_date' do
    it 'returns true if user worked out on given date' do
      exercise = create(:exercise, user_id: user.id)
      date = Date.today
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, created_at: date.to_time)
      
      expect(user.worked_out_on_date(date.day, date.month, date.year)).to be true
    end
    
    it 'returns false if user did not work out on given date' do
      exercise = create(:exercise, user_id: user.id)
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, created_at: 1.day.ago)
      date = Date.today - 2.days
      
      expect(user.worked_out_on_date(date.day, date.month, date.year)).to be false
    end
    
    it 'correctly formats single-digit day and month' do
      exercise = create(:exercise, user_id: user.id)
      date = Date.new(2025, 1, 1)  # January 1st
      Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, created_at: date.to_time)
      
      expect(user.worked_out_on_date(1, 1, 2025)).to be true
    end
  end
  
  describe '#last_seen' do
    context 'when user has sets' do
      it 'returns human-readable time diff for minutes' do
        exercise = create(:exercise, user_id: user.id)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, created_at: 5.minutes.ago)
        
        expect(user.last_seen).to match(/minutes ago/)
      end
      
      it 'returns singular form for 1 minute' do
        exercise = create(:exercise, user_id: user.id)
        allow_any_instance_of(Allset).to receive(:created_at).and_return(1.minute.ago)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10)
        
        expect(user.last_seen).to eq("1 minute ago")
      end
      
      it 'returns human-readable time diff for hours' do
        exercise = create(:exercise, user_id: user.id)
        allow_any_instance_of(Allset).to receive(:created_at).and_return(3.hours.ago)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10)
        
        expect(user.last_seen).to eq("3 hours ago")
      end
      
      it 'returns singular form for 1 hour' do
        exercise = create(:exercise, user_id: user.id)
        allow_any_instance_of(Allset).to receive(:created_at).and_return(1.hour.ago)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10)
        
        expect(user.last_seen).to eq("1 hour ago")
      end
      
      it 'returns human-readable time diff for days' do
        exercise = create(:exercise, user_id: user.id)
        allow_any_instance_of(Allset).to receive(:created_at).and_return(3.days.ago)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10)
        
        expect(user.last_seen).to eq("3 days ago")
      end
      
      it 'returns singular form for 1 day' do
        exercise = create(:exercise, user_id: user.id)
        allow_any_instance_of(Allset).to receive(:created_at).and_return(1.day.ago)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10)
        
        expect(user.last_seen).to eq("1 day ago")
      end
      
      it 'returns human-readable time diff for weeks' do
        exercise = create(:exercise, user_id: user.id)
        allow_any_instance_of(Allset).to receive(:created_at).and_return(2.weeks.ago)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10)
        
        expect(user.last_seen).to eq("2 weeks ago")
      end
      
      it 'returns singular form for 1 week' do
        exercise = create(:exercise, user_id: user.id)
        allow_any_instance_of(Allset).to receive(:created_at).and_return(1.week.ago)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10)
        
        expect(user.last_seen).to eq("1 week ago")
      end
      
      it 'returns "over a month ago" for older dates' do
        exercise = create(:exercise, user_id: user.id)
        allow_any_instance_of(Allset).to receive(:created_at).and_return(2.months.ago)
        Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10)
        
        expect(user.last_seen).to eq("over a month ago")
      end
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
        exercise = create(:exercise, user_id: user.id)
        allow(user).to receive(:has_worked_out_today).and_return(true)
        
        expect(user.streak_status).to eq("active")
      end
    end
    
    context 'when user did not work out today but did yesterday' do
      it 'returns "pending"' do
        exercise = create(:exercise, user_id: user.id)
        allow(user).to receive(:has_worked_out_today).and_return(false)
        allow(user).to receive(:worked_out_on_date).with(Date.yesterday.day, Date.yesterday.month, Date.yesterday.year).and_return(true)
        
        expect(user.streak_status).to eq("pending")
      end
    end
    
    context 'when user did not work out today or yesterday but did the day before' do
      it 'returns "at_risk"' do
        exercise = create(:exercise, user_id: user.id)
        allow(user).to receive(:has_worked_out_today).and_return(false)
        allow(user).to receive(:worked_out_on_date).with(Date.yesterday.day, Date.yesterday.month, Date.yesterday.year).and_return(false)
        allow(user).to receive(:worked_out_on_date).with(Date.yesterday.yesterday.day, Date.yesterday.yesterday.month, Date.yesterday.yesterday.year).and_return(true)
        
        expect(user.streak_status).to eq("at_risk")
      end
    end
    
    context 'when user has not worked out in the last three days' do
      it 'returns "none"' do
        exercise = create(:exercise, user_id: user.id)
        allow(user).to receive(:has_worked_out_today).and_return(false)
        allow(user).to receive(:worked_out_on_date).with(Date.yesterday.day, Date.yesterday.month, Date.yesterday.year).and_return(false)
        allow(user).to receive(:worked_out_on_date).with(Date.yesterday.yesterday.day, Date.yesterday.yesterday.month, Date.yesterday.yesterday.year).and_return(false)
        
        expect(user.streak_status).to eq("none")
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
      allow(user).to receive(:streak_status).and_return("none")
      expect(user.streak_msg_own).to eq("You haven't got a streak going yet.")
    end
    
    it 'returns appropriate message for "pending" status' do
      allow(user).to receive(:streak_status).and_return("pending")
      allow(user).to receive(:streakcount).and_return(5)
      expect(user.streak_msg_own).to eq("You haven't worked out today, but you have a 5 day streak!")
    end
    
    it 'returns appropriate message for "at_risk" status' do
      allow(user).to receive(:streak_status).and_return("at_risk")
      allow(user).to receive(:streakcount).and_return(10)
      expect(user.streak_msg_own).to eq("You had a day off yesterday, workout today to keep the 10 day streak going or it will be reset!")
    end
    
    it 'returns appropriate message for "active" status' do
      allow(user).to receive(:streak_status).and_return("active")
      allow(user).to receive(:streakcount).and_return(15)
      expect(user.streak_msg_own).to eq("You have a 15 day streak!")
    end
  end
  
  describe '#streak_msg_other' do
    it 'returns appropriate message for "none" status' do
      allow(user).to receive(:streak_status).and_return("none")
      expect(user.streak_msg_other).to eq("#{user.first_name} hasn't worked out yet today!")
    end
    
    it 'returns appropriate message for "pending" status' do
      allow(user).to receive(:streak_status).and_return("pending")
      allow(user).to receive(:streakcount).and_return(5)
      expect(user.streak_msg_other).to eq("#{user.first_name} hasn't worked out today, but has a 5 day streak going!")
    end
    
    it 'returns appropriate message for "at_risk" status' do
      allow(user).to receive(:streak_status).and_return("at_risk")
      allow(user).to receive(:streakcount).and_return(10)
      expect(user.streak_msg_other).to eq("#{user.first_name} had a day off yesterday, workout today to keep the 10 day streak going or it will be reset!")
    end
    
    it 'returns appropriate message for "active" status' do
      allow(user).to receive(:streak_status).and_return("active")
      allow(user).to receive(:streakcount).and_return(15)
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
        set = Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, belongs_to_workout: nil)
        
        expect(user.midworkout).to be_truthy
      end
    end
    
    context 'when all user sets belong to workouts' do
      it 'returns false' do
        exercise = create(:exercise, user_id: user.id)
        workout = Workout.create(user_id: user.id)
        set = Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, belongs_to_workout: workout.id)
        
        expect(user.midworkout).to be_falsey
      end
    end
  end
  
  describe '#manually_end_workout' do
    context 'when user has unassigned sets' do
      it 'creates a new workout and assigns the sets' do
        exercise = create(:exercise, user_id: user.id)
        set1 = Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 100, repetitions: 10, belongs_to_workout: nil, created_at: 1.hour.ago)
        set2 = Allset.create(exercise_id: exercise.id, user_id: user.id, weight: 110, repetitions: 8, belongs_to_workout: nil, created_at: 30.minutes.ago)
        
        expect {
          user.manually_end_workout
        }.to change(Workout, :count).by(1)
        
        set1.reload
        set2.reload
        workout = Workout.last
        
        expect(set1.belongs_to_workout).to eq(workout.id)
        expect(set2.belongs_to_workout).to eq(workout.id)
        expect(workout.user_id).to eq(user.id)
        expect(workout.started_at).to be_within(1.second).of(set1.created_at)
        expect(workout.ended_at).to be_within(1.second).of(set2.created_at)
      end
    end
    
    context 'when user has no unassigned sets' do
      it 'does not create a new workout' do
        expect {
          user.manually_end_workout
        }.not_to change(Workout, :count)
      end
    end
  end
end
