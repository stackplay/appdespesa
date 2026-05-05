class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    ExpenseMailer.welcome_email(user).deliver_now
  end
end