
class SessionsController < ApplicationController

  def new
  end

  def create
    authorized_user? ? successful_login : unsuccessful_login
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

    attr_reader :user

    def user
      @user ||= User.find_by(email: params[:session][:email].downcase)
    end

    def authorized_user?
      password = params[:session][:password]
      user && user.authenticate(password) && user.activated?
    end

    def successful_login
      log_in user
      remember user if params[:session][:remember_me] == "1"
      redirect_back_or(user)
    end

    def unsuccessful_login
      user.activated? ? warn_incorrect_credentials :
                        warn_account_activation
    end

    def warn_account_activation
      message = <<-EOM
        Account not activated.
        Check your email for the activation link
      EOM
      flash[:warning] = message
      redirect_to root_url
    end

    def warn_incorrect_credentials
      flash.now[:danger] = 'Log in information not quite right'
      render 'new'
    end
end
