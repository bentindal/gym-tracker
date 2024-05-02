class AddLastSetToExercises < ActiveRecord::Migration[7.0]
  def change
    add_column :exercises, :last_set, :datetime
    
    @allsets = Allset.all
    Exercise.all.each do |exercise|
      ex_id = exercise.id
      last_set = @allsets.where(exercise_id: ex_id).order(created_at: :desc).first
      if not last_set.nil?
        exercise.last_set = last_set.created_at
        exercise.save
      end
    end
  end
end
