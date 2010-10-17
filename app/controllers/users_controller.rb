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
    @user.secret_code_confirmation = params[:user][:secret_code]
    if @user.update_attributes(params[:user])
      redirect_to page_url('welcome')
    else
      @user.errors[:secret_code_confirmation] = @user.errors[:secret_code]
      render :action => :edit
    end
  end
end
