class ExpenseMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_FROM", "noreply@expensetracker.com")

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Bem-vindo ao Expense Tracker!")
  end

  def limit_warning(user, category, pct_used)
    @user = user
    @category = category
    @pct_used = pct_used
    @remaining = (category.monthly_limit - category.expenses
                                                   .where(user: user)
                                                   .where(date: Date.current.beginning_of_month..Date.current.end_of_month)
                                                   .sum(:amount)).round(2)
    mail(to: @user.email, subject: "Alerta: #{pct_used}% do limite de #{category.name} usado")
  end

  def monthly_report(user, month)
    @user = user
    @month = month
    @expenses = user.expenses.where(date: month.beginning_of_month..month.end_of_month).includes(:category)
    @total = @expenses.sum(:amount).to_f.round(2)
    @by_category = @expenses.group_by(&:category)
    mail(to: @user.email, subject: "Relatório de #{month.strftime('%B %Y')}")
  end
end