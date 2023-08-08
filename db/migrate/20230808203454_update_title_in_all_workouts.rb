class UpdateTitleInAllWorkouts < ActiveRecord::Migration[7.0]
  def change
    Workout.all.each do |workout|
      workout.title = workout.allsets.map(&:exercise).map(&:group).uniq.join(", ").reverse.sub(",", "& ").reverse
      workout.save
    end
  end
end
