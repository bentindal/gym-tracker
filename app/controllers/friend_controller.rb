class FriendController < ApplicationController
  def list
    all_friends = Friend.where(user: current_user.id)
    @friends = []
    all_friends.each do |friend|
      @friends.push(User.find(friend.follows))
    end
  end

  def add
    @friend = Friend.new
    @friend.user = current_user.id
    @friend.follows = params[:id]
    @friend.save
    redirect_to "/users/view?id=#{params[:id]}"
  end

  def remove
    @friend = Friend.find_by(user: current_user.id, follows: params[:id])
    @friend.destroy
    redirect_to "/users/view?id=#{params[:id]}"
  end
end
