
class UsersController < ApplicationController
  before_action :logged_in_user,  only: [:edit, :update, :index, :destroy,
                                         :following, :followers]
  before_action :correct_user,    only: [:edit, :update]
  before_action :admin_user,      only: :destroy

  # provides users for rendering based on current_user authorization
  def index
    @users = current_user.admin? ?  all_users_paginated :
                                    active_users_paginated
  end

  # shows current_user profile if activated
  def show
    @user = User.find(params[:id])
    @microposts = user.microposts.paginate(page: params[:page])
    unless user.activated? || current_user.admin?
      redirect_to root_url and return
    end
  end

  # shows signup page for get requests
  def new
    @user = User.new
  end

  # shows signup page after post requests
  def create
    @user = User.new(user_params)
    user.save ? send_activation : render("new")
  end

  # shows user data editing page for user
  def edit
    @user = User.find(params[:id])
  end

  # processes patch request to users/edit
  def update
    @user = User.find(params[:id])
    user.update_attributes(user_params) ? successful_update :
                                          render("edit")
  end

  # processes delete request to user_path(user)
  def destroy
    user = User.find(params[:id])
    user.destroy
    flash[:success] = "#{ user.name } removed"
    redirect_to users_url
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    # explicit call b/c implicit call would search for following
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    # explicit call b/c implicit call would search for followers
    render 'show_follow'
  end

  private

    attr_reader :user

    # enforces strong parameters
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    def send_activation
      user.send_activation_email
      flash[:info] = "Our digital courier is delivering your activation email now."
      redirect_to root_url
    end

    def successful_update
      redirect_to(@user)
      flash[:success] = "Profile updated"
    end

    def all_users_paginated
      User.paginate(page: params[:page])
    end

    def active_users_paginated
      User.where(activated: true).paginate(page: params[:page])
    end

end
