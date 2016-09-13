
module SessionsHelper

  # logs in given user
  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  # returns current logged-in user (if any)
  def current_user
    @current_user ||= User.find_by_id(session[:user_id])
  end

  # true/ false user is logged in
  def logged_in?
    !current_user.nil?
  end

  private

    attr_writer :current_user

end
