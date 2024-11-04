class CreateExercises < ActiveRecord::Migration[6.1]
  def change
    create_table :exercises, if_not_exists: true do |t|
      t.integer :user_id
      t.string :name
      t.string :unit
      t.string :group
      t.datetime :last_set
      t.timestamps
    end
  end
end