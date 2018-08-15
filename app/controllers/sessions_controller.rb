class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate(params[:session][:password])
      flash[:success] = t ".login_success"
      log_in user
      redirect_to user
    else
      flash[:danger] = t ".login_failed"
      render :new
    end
  end

  def destroy
    flash[:success] = t ".logout_success"
    log_out
    redirect_to root_path
  end
end
