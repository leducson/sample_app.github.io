class UsersController < ApplicationController
  before_action :load_user, except: %i(index new create)
  before_action :logged_in_user, except: %i(show new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.newest.page(params[:page]).per(Settings.users_per)
  end

  def show
    @microposts =
      @user.microposts.page(params[:page]).per(Settings.micropots_per)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t ".active_notify"
      redirect_to root_path
    else
      flash[:danger] = t ".signup_failed"
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".update_success"
      redirect_to @user
    else
      flash[:danger] = t ".update_failed"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".destroy_success"
    else
      flash[:danger] = t ".destroy_failed"
    end
    redirect_to users_path
  end

  def following
    @title = t ".title"
    @users = @user.following.page(params[:page]).per(Settings.following_per)
    render "show_follow"
  end

  def followers
    @title = t ".title"
    @users = @user.followers.page(params[:page]).per(Settings.follower_per)
    render "show_follow"
  end

  private

  def load_user
    @user = User.find params[:id]
  end

  def user_params
    params.require(:user).permit :name, :email,
      :password, :password_confirmation
  end

  def logged_in_user
    return nil if logged_in?
    store_location
    flash[:danger] = t ".login"
    redirect_to login_path
  end

  def correct_user
    redirect_to root_path unless current_user? load_user
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
