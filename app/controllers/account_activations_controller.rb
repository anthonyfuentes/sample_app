
class AccountActivationsController < ApplicationController

  def edit
    @user = User.find_by_email(params[:email])
    if user && activation_eligible?(user)
      complete_activation
    else
      warn_invalid_activation
    end
  end

  private
    attr_reader :user

    def activation_eligible?(user)
      !user.activated? && user.authenticated?(:activation, params[:id])
    end

    def complete_activation
      user.activate
      log_in user
      flash[:success] = "You're official! See whats the community is up to."
      redirect_to users_path
    end

    def warn_invalid_activation
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
end
