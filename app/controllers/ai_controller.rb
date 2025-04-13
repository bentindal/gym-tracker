class AiController < ApplicationController
  before_action :authenticate_user!
  require 'openai'

  def analyze_workouts
    if params[:workout_id].present?
      # Analyze specific workout
      workout = Workout.find(params[:workout_id])
      
      # Verify user owns the workout
      if workout.user_id != current_user.id
        redirect_to workout_view_path(workout), alert: "Unauthorized"
        return
      end
      
      # Check if analysis already exists
      existing_analysis = WorkoutAnalysis.find_by(workout_id: workout.id)
      
      if existing_analysis
        redirect_to workout_view_path(workout), alert: "Analysis already exists"
        return
      end
      
      begin
        # Get recent workouts (last 30 days)
        recent_workouts = current_user.workouts
          .where('started_at >= ?', 30.days.ago)
          .where.not(id: workout.id)
          .order(started_at: :desc)

        # Prepare current workout data
        current_workout_data = {
          date: workout.started_at,
          duration: workout.length_string,
          exercises: workout.allsets.map do |set|
            {
              name: set.exercise.name,
              group: set.exercise.group,
              unit: set.exercise.unit,
              repetitions: set.repetitions,
              weight: set.weight
            }
          end
        }

        # Prepare recent workouts data
        recent_workouts_data = recent_workouts.map do |w|
          {
            date: w.started_at,
            duration: w.length_string,
            exercises: w.allsets.map do |set|
              {
                name: set.exercise.name,
                group: set.exercise.group,
                unit: set.exercise.unit,
                repetitions: set.repetitions,
                weight: set.weight
              }
            end
          }
        end

        # Format data for OpenAI
        prompt = format_workout_data_for_ai(current_workout_data, recent_workouts_data)
        
        # Get AI feedback
        feedback = get_ai_feedback(prompt)
        
        if feedback.blank?
          raise "Failed to get AI feedback"
        end
        
        # Create and save the analysis
        analysis = WorkoutAnalysis.create!(
          workout: workout,
          total_volume: calculate_total_volume(workout),
          total_sets: workout.allsets.count,
          total_reps: calculate_total_reps(workout),
          average_weight: calculate_average_weight(workout),
          feedback: feedback
        )
        
        # Redirect to workout view with success message
        redirect_to workout_view_path(workout), notice: "Analysis generated successfully"
      rescue StandardError => e
        Rails.logger.error("AI Analysis failed: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
        redirect_to workout_view_path(workout), alert: "Failed to generate analysis. Please try again later."
      end
    else
      redirect_to workout_list_path, alert: "No workout specified"
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

  def format_workout_data_for_ai(current_workout, recent_workouts)
    <<~PROMPT
      Provide a concise, three-paragraph analysis for #{current_user.first_name}. Write in a natural, flowing style as if you're having a conversation with them. Format your response in markdown with clear paragraph breaks:

      **First paragraph:** Highlight the most impressive or interesting aspects of their current workout. Feel free to mention specific sets or reps if they tell a compelling story about their progress. Always mention weights with their correct units (kg, lbs, kg/db for dumbbells in kg, or lbs/db for dumbbells in lbs).

      **Second paragraph:** Compare their current workout to their recent training history. Focus on meaningful patterns or progress in their training approach. When comparing weights, always use the same unit system as the exercise (kg, lbs, kg/db, or lbs/db).

      **Third paragraph:** Provide one key insight about their overall training routine and consistency.

      Keep it concise and engaging - focus on what makes their training unique or impressive. Write as if you're their personal trainer reviewing their workout data. Always respect and use the unit system specified for each exercise.

      Current Workout Data:
      #{current_workout.to_json}

      Recent Workouts Data:
      #{recent_workouts.to_json}
    PROMPT
  end

  def get_ai_feedback(prompt)
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    
    response = client.completions(
      parameters: {
        model: "gpt-3.5-turbo-instruct",
        prompt: prompt,
        max_tokens: 400,
        temperature: 0.7
      }
    )
    
    response.dig("choices", 0, "text")
  rescue StandardError => e
    Rails.logger.error("OpenAI API call failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    nil
  end
end 