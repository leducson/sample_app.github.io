class UsersController < ApplicationController
  before_action :load_user, only: :show

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new safe_params
    if @user.save
      flash[:success] = t ".success"
      redirect_to @user
    else
      flash[:error] = t ".error"
      render :new
    end
  end

  private

  def load_user
    @user = User.find params[:id]
  end

  def safe_params
    params.require(:user).permit :name, :email,
      :password, :password_confirmation
  end
end
