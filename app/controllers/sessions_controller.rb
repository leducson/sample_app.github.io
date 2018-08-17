class SessionsController < ApplicationController
  def new; end

  def create
    session = params[:session]
    user = User.find_by email: session[:email].downcase
    if user&.authenticate(session[:password])
      if user.activated?
        remember_me user, session
        redirect_back_or user
      else
        flash[:warning] = t ".not_active_message"
        redirect_to root_path
      end
    else
      flash[:danger] = t ".login_failed"
      render :new
    end
  end

  def remember_me user, session
    log_in user
    if session[:remember_me] == Settings.remember_me
      remember user
    else
      forget user
    end
  end

  def destroy
    flash[:success] = t ".logout_success"
    log_out if logged_in?
    redirect_to root_path
  end
end
