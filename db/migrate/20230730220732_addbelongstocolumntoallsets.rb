class Addbelongstocolumntoallsets < ActiveRecord::Migration[7.0]
  def change
    add_column :allsets, :belongs_to_workout, :integer
  end
end
