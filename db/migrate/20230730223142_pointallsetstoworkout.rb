class Pointallsetstoworkout < ActiveRecord::Migration[7.0]
  def change
    # Get feed for every user
    @allusers = User.all

    userList = []

    @allusers.each do |user|
        userList.push(user)
    end

    @feed = []
    userList.each do |user|
        user.feed.each do |feed_item|
            @feed.push(feed_item)
        end
    end

    # Okay, feed is now full, but it's not sorted yet. Let's sort it.

    @feed = @feed.sort_by { |a| a[0] } # Oldest first


    # For every feed item, lets generate a row in the workout table for it.
    @feed.each do |feed_item|
      target_date = feed_item[0]
      target = Workout.where(started_at: target_date).first

      feed_item[2].each do |exerciseandsets|
        exerciseandsets[1].each do |set|
          set.belongs_to_workout = target.id
          set.save
        end
      end
    end

  end
end
