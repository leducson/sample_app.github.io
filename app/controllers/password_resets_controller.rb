class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t ".forgot_password_success"
      redirect_to root_path
    else
      flash.now[:danger] = t ".forgot_password_failed"
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes password_params.merge!(change_pass: true)
      log_in @user
      flash[:success] = t ".change_password_success"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def password_params
    params.require(:user).permit :password, :password_confirmation
  end

  def load_user
    @user = User.find_by email: params[:email]
    return not_found? unless @user
  end

  def valid_user
    if @user&.activated? &&
       @user.authenticated?(:reset, params[:id])
      redirect_to root_path
    end
  end

  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t ".expired"
    redirect_to new_password_reset_path
  end
end
