# frozen_string_literal: true

desc 'Backfill metrics for a specific date range. Usage: rake backfill_metrics[start_date,end_date]'
task :backfill_metrics, [:start_date, :end_date] => :environment do |_t, args|
  begin
    start_date = Date.parse(args[:start_date])
    end_date = Date.parse(args[:end_date])

    puts "[#{Time.zone.now}] Starting metrics backfill from #{start_date} to #{end_date}..."
    
    (start_date..end_date).each do |date|
      puts "Processing metrics for #{date}..."
      
      # Find or initialize metrics for this date
      metric = Metric.find_or_initialize_by(date: date)
      
      # Calculate yesterday for active users
      yesterday = date - 1.day
      
      # Collect metrics for this date
      metric.total_users = User.where('created_at <= ?', date.end_of_day).count
      metric.total_workouts = Workout.where('created_at <= ?', date.end_of_day).count
      metric.total_sets = Allset.where('created_at <= ?', date.end_of_day).count
      metric.active_users = User.where('last_sign_in_at >= ? AND last_sign_in_at <= ?', 
                                     yesterday.beginning_of_day, 
                                     date.end_of_day).count
      metric.new_users = User.where('created_at >= ? AND created_at <= ?', 
                                  date.beginning_of_day, 
                                  date.end_of_day).count
      
      if metric.save
        puts "✓ Metrics saved for #{date}"
      else
        puts "✗ Failed to save metrics for #{date}: #{metric.errors.full_messages.join(', ')}"
      end
    end
    
    puts "[#{Time.zone.now}] Metrics backfill completed!"
  rescue ArgumentError => e
    puts "Error: Invalid date format. Please use YYYY-MM-DD format."
    puts "Example: rake backfill_metrics[2024-01-01,2024-01-31]"
  rescue StandardError => e
    puts "Error: #{e.message}"
  end
end 