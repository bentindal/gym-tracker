class CreateExercises < ActiveRecord::Migration[7.0]
  def change
    create_table :exercises do |t|
      t.integer :user_id
      t.string :name
      t.string :unit
      t.string :group

      t.timestamps
    end
  end
end
