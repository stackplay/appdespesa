class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user
    ExpenseMailer.welcome_email(user).deliver_now
  end
end
