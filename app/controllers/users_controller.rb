
class UsersController < ApplicationController
  before_action :logged_in_user,  only: [:edit, :update, :index, :destroy]
  before_action :correct_user,    only: [:edit, :update]
  before_action :admin_user,      only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    user.save ? welcome : render("new")
    log_in user
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    user.update_attributes(user_params) ? successful_update :
                                          render("edit")
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    flash[:success] = "#{ user.name } removed"
    redirect_to users_url
  end

  private

    attr_reader :user

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    def welcome
      redirect_to(@user)
      flash[:success] = "Welcome to Sample App"
    end

    def successful_update
      redirect_to(@user)
      flash[:success] = "Profile updated"
    end

    # before filters

    # confirms user is logged-in
    def logged_in_user
      unless logged_in?
        store_requested_location
        flash[:danger] = "Please log in"
        redirect_to login_url
      end
    end

    # confirms current_user authorized
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless  current_user?(@user)
    end

    # confirms admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
