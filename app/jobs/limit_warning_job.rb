class LimitWarningJob < ApplicationJob
  queue_as :default

  def perform(user_id, category_id)
    user = User.find(user_id)
    category = Category.find(category_id)

    spent = category.expenses
                    .where(user: user)
                    .where(date: Date.current.beginning_of_month..Date.current.end_of_month)
                    .sum(:amount)

    return unless category.monthly_limit&.> 0

    pct = ((spent / category.monthly_limit) * 100).round(1)
    return unless pct >= 80

    ExpenseMailer.limit_warning(user, category, pct).deliver_now
  end
end