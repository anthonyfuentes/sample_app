
class PasswordResetsController < ApplicationController
  before_action :get_user,          only: [:edit, :update]
  before_action :validate_user,     only: [:edit, :update]
  before_action :check_expiration,  only: [:edit, :update]

  def new
  end

  def edit
  end

  def create
    @user = User.find_by_email(params[:password_reset][:email].downcase)
    user ? initiate_password_reset : warn_email_not_found
  end

  def update
    valid_reset_data? ? successful_reset : unsuccessful_reset
  end

  private
    attr_reader :user

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def initiate_password_reset
      user.create_password_reset_digest
      user.send_password_reset_email
      flash[:info] = "Email with password reset sent"
      redirect_to root_url
    end

    def warn_email_not_found
      flash.now[:danger] = "Email address not found"
      render 'new'
    end

    def valid_reset_data?
      !password_empty? &&
       user.update_attributes(user_params)
    end

    def password_empty?
      params[:user][:password].empty?
    end

    def successful_reset
      log_in user
      user.clear_password_reset
      flash[:success] = "Password reset"
      redirect_to users_path
    end

    def unsuccessful_reset
      password_empty? ? warn_empty_password : render('edit')
    end

    def warn_empty_password
      user.errors.add(:password, "can't be empty")
      render 'edit'
    end

    # before filters

    def get_user
      @user = User.find_by_email(params[:email])
    end

    def validate_user
      unless (user && user.activated? &&
              user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # checks expiration of password reset token
    def check_expiration
      if user.password_reset_expired?
        flash[:danger] = "Password reset has expired"
        redirect_to new_password_reset_url
      end
    end
end
