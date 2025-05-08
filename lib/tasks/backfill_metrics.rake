# frozen_string_literal: true

desc 'Backfill metrics for a specific date range. Usage: rake backfill_metrics[start_date,end_date,overwrite]'
task :backfill_metrics, [:start_date, :end_date, :overwrite] => :environment do |_t, args|
  begin
    start_date = Date.parse(args[:start_date])
    end_date = Date.parse(args[:end_date])
    overwrite = args[:overwrite] == 'true'

    puts "[#{Time.zone.now}] Starting metrics backfill from #{start_date} to #{end_date}..."
    puts "Overwrite existing metrics: #{overwrite ? 'Yes' : 'No'}"
    
    (start_date..end_date).each do |date|
      puts "\nProcessing metrics for #{date}..."
      
      # Find or initialize metrics for this date
      metric = Metric.find_or_initialize_by(date: date)
      
      # Skip if metric exists and we're not overwriting
      if metric.persisted? && !overwrite
        puts "  Skipping #{date} - metrics already exist"
        next
      end
      
      # Calculate yesterday for active users
      yesterday = date - 1.day
      
      # Collect metrics for this date
      total_users = User.where('created_at <= ?', date.end_of_day).count
      total_workouts = Workout.where('created_at <= ?', date.end_of_day).count
      total_sets = Allset.where('created_at <= ?', date.end_of_day).count
      
      # Modified active users query to check for any activity on that day
      active_users = User.joins(:workouts)
                        .where('workouts.created_at >= ? AND workouts.created_at <= ?', 
                              date.beginning_of_day, 
                              date.end_of_day)
                        .distinct
                        .count
      
      new_users = User.where('created_at >= ? AND created_at <= ?', 
                            date.beginning_of_day, 
                            date.end_of_day).count
      
      # Log the counts before saving
      puts "  Total Users: #{total_users}"
      puts "  Total Workouts: #{total_workouts}"
      puts "  Total Sets: #{total_sets}"
      puts "  Active Users: #{active_users}"
      puts "  New Users: #{new_users}"
      
      # Update the metric
      metric.total_users = total_users
      metric.total_workouts = total_workouts
      metric.total_sets = total_sets
      metric.active_users = active_users
      metric.new_users = new_users
      
      if metric.save
        puts "✓ Metrics #{metric.persisted? ? 'updated' : 'created'} for #{date}"
      else
        puts "✗ Failed to save metrics for #{date}: #{metric.errors.full_messages.join(', ')}"
      end
    end
    
    puts "\n[#{Time.zone.now}] Metrics backfill completed!"
  rescue ArgumentError => e
    puts "Error: Invalid date format. Please use YYYY-MM-DD format."
    puts "Example: rake backfill_metrics[2025-01-01,2025-01-31,true]"
  rescue StandardError => e
    puts "Error: #{e.message}"
  end
end 