class Changestartedatandendedattypetodatetime < ActiveRecord::Migration[7.0]
  def change
    change_column :workouts, :started_at, :datetime
    change_column :workouts, :ended_at, :datetime
  end
end
