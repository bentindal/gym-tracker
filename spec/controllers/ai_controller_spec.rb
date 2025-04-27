# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AiController, type: :controller do
  let(:user) { create(:user) }
  let(:workout) { create(:workout, user: user) }
  let(:exercise) { create(:exercise, user: user) }
  let(:openai_client) { instance_double(OpenAI::Client) }

  before do
    sign_in user
    allow(OpenAI::Client).to receive(:new).and_return(openai_client)
    allow(ENV).to receive(:fetch).with('OPENAI_API_KEY', nil).and_return('test-key')
  end

  describe '#analyze_workouts' do
    context 'when workout exists and belongs to user' do
      before do
        allow(openai_client).to receive(:chat).with(
          parameters: {
            model: 'gpt-4',
            messages: [{ role: 'user', content: anything }],
            temperature: 0.7
          }
        ).and_return({
                       'choices' => [{ 'message' => { 'content' => 'Test feedback' } }]
                     })
      end

      it 'creates a workout analysis' do
        expect do
          post :analyze_workouts, params: { workout_id: workout.id }
        end.to change(WorkoutAnalysis, :count).by(1)

        analysis = WorkoutAnalysis.last
        expect(analysis.workout_id).to eq(workout.id)
        expect(analysis.feedback).to eq('Test feedback')
      end

      it 'redirects to workout view after successful analysis' do
        post :analyze_workouts, params: { workout_id: workout.id }
        expect(response).to redirect_to(workout_view_path(id: workout.id))
      end

      context 'when OpenAI API returns empty response' do
        before do
          allow(openai_client).to receive(:chat).with(
            parameters: {
              model: 'gpt-4',
              messages: [{ role: 'user', content: anything }],
              temperature: 0.7
            }
          ).and_return({
                         'choices' => [{ 'message' => { 'content' => '' } }]
                       })
        end

        it 'handles empty response gracefully' do
          post :analyze_workouts, params: { workout_id: workout.id }
          expect(response).to redirect_to(dashboard_path)
          expect(flash[:alert]).to eq('Error generating analysis')
        end
      end

      context 'when OpenAI API key is missing' do
        before do
          allow(ENV).to receive(:fetch).with('OPENAI_API_KEY', nil).and_return(nil)
        end

        it 'handles missing API key gracefully' do
          post :analyze_workouts, params: { workout_id: workout.id }
          expect(response).to redirect_to(dashboard_path)
          expect(flash[:alert]).to eq('Error generating analysis')
        end
      end
    end

    context 'when workout does not exist' do
      it 'redirects with error' do
        post :analyze_workouts, params: { workout_id: 999 }
        expect(response).to redirect_to(dashboard_path)
        expect(flash[:alert]).to eq('Error generating analysis')
      end
    end

    context 'when workout belongs to another user' do
      let(:other_user) { create(:user) }
      let(:other_workout) { create(:workout, user: other_user) }

      it 'redirects with unauthorized message' do
        post :analyze_workouts, params: { workout_id: other_workout.id }
        expect(response).to redirect_to(workout_view_path(id: other_workout.id))
        expect(flash[:alert]).to eq('Unauthorized')
      end
    end

    context 'when analysis already exists' do
      before do
        create(:workout_analysis, workout: workout)
      end

      it 'redirects with existing analysis message' do
        post :analyze_workouts, params: { workout_id: workout.id }
        expect(response).to redirect_to(workout_view_path(id: workout.id))
        expect(flash[:alert]).to eq('Analysis already exists')
      end
    end

    context 'when OpenAI API fails' do
      before do
        allow(openai_client).to receive(:chat).with(
          parameters: {
            model: 'gpt-4',
            messages: [{ role: 'user', content: anything }],
            temperature: 0.7
          }
        ).and_raise(StandardError)
      end

      it 'handles the error gracefully' do
        post :analyze_workouts, params: { workout_id: workout.id }
        expect(response).to redirect_to(dashboard_path)
        expect(flash[:alert]).to eq('Error generating analysis')
      end
    end
  end

  describe 'helper methods' do
    describe '#calculate_total_volume' do
      it 'calculates total volume correctly' do
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout, weight: 100, repetitions: 10)
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout, weight: 50, repetitions: 5)

        expect(controller.send(:calculate_total_volume, workout)).to eq(1250.0)
      end

      it 'handles decimal weights correctly' do
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout, weight: 100.5, repetitions: 10)
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout, weight: 50.25, repetitions: 5)

        expect(controller.send(:calculate_total_volume, workout)).to eq(1256.25)
      end

      it 'handles large numbers correctly' do
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout, weight: 1000, repetitions: 100)

        expect(controller.send(:calculate_total_volume, workout)).to eq(100_000.0)
      end

      it 'returns 0 when no sets exist' do
        new_workout = create(:workout, user: user)
        expect(controller.send(:calculate_total_volume, new_workout)).to eq(0)
      end
    end

    describe '#calculate_average_weight' do
      it 'calculates average weight correctly' do
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout, weight: 100)
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout, weight: 50)

        expect(controller.send(:calculate_average_weight, workout)).to eq(75.0)
      end

      it 'handles decimal weights correctly' do
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout, weight: 100.5)
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout, weight: 50.25)

        expect(controller.send(:calculate_average_weight, workout)).to eq(75.38)
      end

      it 'returns 0 when no sets exist' do
        new_workout = create(:workout, user: user)
        expect(controller.send(:calculate_average_weight, new_workout)).to eq(0)
      end
    end

    describe '#format_workout_data_for_ai' do
      it 'formats workout data correctly' do
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout)
        result = controller.send(:format_workout_data_for_ai, workout, [workout])
        expect(result).to include('Current Workout:')
        expect(result).to include('Recent Workouts:')
        expect(result).to include(workout.started_at.strftime('%B %d'))
      end

      it 'handles different date formats' do
        workout.update(started_at: Time.new(2023, 12, 31))
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout)
        result = controller.send(:format_workout_data_for_ai, workout, [workout])
        expect(result).to include('December 31')
      end

      it 'handles different exercise units' do
        exercise.update(unit: 'lbs')
        create(:allset, :with_workout, exercise: exercise, user: user, workout: workout, weight: 100)
        result = controller.send(:format_workout_data_for_ai, workout, [workout])
        expect(result).to include('100.0lbs')
      end

      it 'handles empty workouts' do
        result = controller.send(:format_workout_data_for_ai, workout, [])
        expect(result).to include('Current Workout:')
        expect(result).to include('Recent Workouts:')
      end
    end
  end
end
