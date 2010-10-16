class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    @user.save
    redirect_to edit_user_url(@user)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    render :nothing => true
  end
end
