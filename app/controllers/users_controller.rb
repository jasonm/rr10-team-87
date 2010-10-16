class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new
    @user.phone_number = params[:user][:phone_number]
    @user.save
    redirect_to edit_user_url(@user)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    @user.save
    redirect_to page_url('how')
  end
end
