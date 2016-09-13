
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all
  include ApplicationHelper

  # returns true if test user is logged in
  def is_logged_in?
    !session[:user_id].nil?
  end
end
