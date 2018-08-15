class SessionsController < ApplicationController
  def new; end

  def create
    session = params[:session]
    user = User.find_by email: session[:email].downcase
    if user&.authenticate(session[:password])
      flash[:success] = t ".login_success"
      log_in user
      session[:remember_me] == Settings.remember_me ? remember(user) : forget(user)
      redirect_to user
    else
      flash[:danger] = t ".login_failed"
      render :new
    end
  end

  def destroy
    flash[:success] = t ".logout_success"
    log_out if logged_in?
    redirect_to root_path
  end
end
