class UsersController < ApplicationController
  before_filter :edit_empty_profile, :only => :create

  def new
    @user = User.new
  end

  def create
    @user = User.new
    @user.phone_number = params[:user][:phone_number]
    if @user.save
      redirect_to edit_user_url(@user)
    else
      render :action => :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.secret_code_confirmation = params[:user][:secret_code]
    if @user.update_attributes(params[:user])
      redirect_to page_url('how-does-this-work')
    else
      @user.errors[:secret_code_confirmation] = @user.errors[:secret_code]
      render :action => :edit
    end
  end

  protected

  def edit_empty_profile
    user = User.find_by_phone_number(params[:user][:phone_number])
    redirect_to edit_user_path(user.id) if user.try(:incomplete?)
  end
end
