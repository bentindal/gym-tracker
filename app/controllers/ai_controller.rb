# frozen_string_literal: true

class AiController < ApplicationController
  before_action :authenticate_user!
  require 'openai'

  def analyze_workouts
    return unless valid_workout?

    sleep(1) # Add a small delay to ensure the loading state is visible

    recent_workouts = current_user.workouts
                                  .where('started_at >= ?', 30.days.ago)
                                  .order(started_at: :desc)
                                  .limit(10)

    prompt = format_workout_data_for_ai(@workout, recent_workouts)
    feedback = get_ai_feedback(prompt)

    if feedback.blank?
      redirect_to dashboard_path, alert: 'Error generating analysis'
      return
    end

    create_workout_analysis(feedback)
    redirect_to workout_view_path(id: @workout.id)
  rescue StandardError => e
    Rails.logger.error("AI Analysis Error: #{e.message}")
    redirect_to dashboard_path, alert: 'Error generating analysis'
  end

  private

  def valid_workout?
    return false unless params[:workout_id].present?

    @workout = Workout.find(params[:workout_id])
    return false unless workout_authorized?
    return false if analysis_exists?

    true
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: 'Error generating analysis'
    false
  end

  def workout_authorized?
    return true if @workout.user_id == current_user.id

    redirect_to workout_view_path(id: @workout.id), alert: 'Unauthorized'
    false
  end

  def analysis_exists?
    return false unless WorkoutAnalysis.exists?(workout_id: @workout.id)

    redirect_to workout_view_path(id: @workout.id), alert: 'Analysis already exists'
    true
  end

  def create_workout_analysis(feedback)
    WorkoutAnalysis.create!(
      workout_id: @workout.id,
      feedback: feedback,
      total_volume: calculate_total_volume(@workout),
      total_sets: @workout.allsets.count,
      total_reps: calculate_total_reps(@workout),
      average_weight: calculate_average_weight(@workout)
    )
  end

  def calculate_total_volume(workout)
    workout.allsets.sum { |set| set.weight.to_f * set.repetitions.to_i }
  end

  def calculate_total_reps(workout)
    workout.allsets.sum { |set| set.repetitions.to_i }
  end

  def calculate_average_weight(workout)
    total_weight = workout.allsets.sum { |set| set.weight.to_f }
    total_sets = workout.allsets.count
    total_sets.positive? ? (total_weight / total_sets).round(2) : 0
  end

  def format_workout_data_for_ai(workout, recent_workouts)
    <<~PROMPT
      Analyze this workout and provide feedback on progress and suggestions for improvement.
      Consider the following recent workouts for context.

      Current Workout:
      #{format_workout_details(workout)}

      Recent Workouts:
      #{format_recent_workouts(recent_workouts)}

      Please provide:
      1. A summary of the workout
      2. Progress analysis compared to recent workouts
      3. Specific suggestions for improvement
      4. Any potential concerns or areas to watch
    PROMPT
  end

  def format_workout_details(workout)
    exercises = workout.allsets.group_by(&:exercise).map do |exercise, sets|
      <<~EXERCISE
        #{exercise.name}:
        #{sets.map { |set| "#{set.weight}#{exercise.unit} x #{set.repetitions} reps" }.join(', ')}
      EXERCISE
    end.join("\n")

    <<~DETAILS
      Date: #{workout.started_at.strftime('%B %d, %Y')}
      Duration: #{workout.length_string}
      Exercises:
      #{exercises}
    DETAILS
  end

  def format_recent_workouts(workouts)
    workouts.map do |workout|
      <<~WORKOUT
        #{workout.started_at.strftime('%B %d')}:
        #{workout.allsets.map { |set| "#{set.exercise.name}: #{set.weight}#{set.exercise.unit} x #{set.repetitions}" }.join(', ')}
      WORKOUT
    end.join("\n")
  end

  def get_ai_feedback(prompt)
    api_key = ENV.fetch('OPENAI_API_KEY', nil)
    return nil if api_key.blank?

    client = OpenAI::Client.new(access_token: api_key)
    response = client.chat(
      parameters: {
        model: 'gpt-4',
        messages: [{ role: 'user', content: prompt }],
        temperature: 0.7
      }
    )
    feedback = response.dig('choices', 0, 'message', 'content')
    feedback.present? ? feedback : nil
  end
end
