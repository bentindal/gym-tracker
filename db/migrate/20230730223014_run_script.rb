class RunScript < ActiveRecord::Migration[7.0]
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
        @workout = Workout.new
        @workout.user_id = feed_item[1].id
        @workout.started_at = feed_item[0]
        @workout.ended_at = feed_item[2].last[1].last.created_at
        @workout.save
    end
  end
end
