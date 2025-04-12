class AiController < ApplicationController
  before_action :authenticate_user!
  require 'openai'

  def analyze_workouts
    if params[:workout_id].present?
      # Analyze specific workout
      workout = Workout.find(params[:workout_id])
      # Verify user owns the workout
      if workout.user_id != current_user.id
        redirect_to workout_view_path(id: params[:workout_id]), alert: "Unauthorized"
        return
      end
      
      # Check if analysis already exists
      @analysis = WorkoutAnalysis.find_by(workout_id: workout.id)
      
      unless @analysis
        # Prepare workout data for analysis
        workout_data = [{
          date: workout.started_at,
          duration: workout.length_string,
          exercises: workout.allsets.map do |set|
            {
              name: set.exercise.name,
              repetitions: set.repetitions,
              weight: set.weight
            }
          end
        }]

        # Format data for OpenAI
        prompt = format_workout_data_for_ai(workout_data)
        
        # Get AI feedback
        feedback = get_ai_feedback(prompt)
        
        # Create and save the analysis
        @analysis = WorkoutAnalysis.create!(
          workout: workout,
          total_volume: calculate_total_volume(workout),
          total_sets: workout.allsets.count,
          total_reps: calculate_total_reps(workout),
          average_weight: calculate_average_weight(workout),
          feedback: feedback
        )
      end
      
      render :analyze
    else
      # Get recent workouts (last 30 days)
      recent_workouts = current_user.workouts.where('started_at >= ?', 30.days.ago)
      
      # Prepare workout data for analysis
      workout_data = recent_workouts.map do |workout|
        {
          date: workout.started_at,
          duration: workout.length_string,
          exercises: workout.allsets.map do |set|
            {
              name: set.exercise.name,
              repetitions: set.repetitions,
              weight: set.weight
            }
          end
        }
      end

      # Format data for OpenAI
      prompt = format_workout_data_for_ai(workout_data)
      
      # Get AI feedback
      @feedback = get_ai_feedback(prompt)
      
      render :analyze
    end
  end

  private

  def calculate_total_volume(workout)
    workout.allsets.sum { |set| set.weight.to_f * set.repetitions.to_i }
  end

  def calculate_total_reps(workout)
    workout.allsets.sum { |set| set.repetitions.to_i }
  end

  def calculate_average_weight(workout)
    total_weight = workout.allsets.sum { |set| set.weight.to_f }
    total_sets = workout.allsets.count
    total_sets.positive? ? total_weight / total_sets : 0
  end

  def format_workout_data_for_ai(workout_data)
    <<~PROMPT
      Analyze the following workout data and provide constructive feedback on:
      1. Workout frequency and consistency
      2. Exercise variety
      3. Progressive overload
      4. Any potential imbalances
      5. General recommendations for improvement

      Workout Data:
      #{workout_data.to_json}
    PROMPT
  end

  def get_ai_feedback(prompt)
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    
    response = client.completions(
      parameters: {
        model: "gpt-3.5-turbo-instruct",
        prompt: prompt,
        max_tokens: 500,
        temperature: 0.7
      }
    )
    
    response.dig("choices", 0, "text")
  end
end 