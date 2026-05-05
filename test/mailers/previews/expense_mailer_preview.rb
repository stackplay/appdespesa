# Preview all emails at http://localhost:3000/rails/mailers/expense_mailer
class ExpenseMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/expense_mailer/welcome_email
  def welcome_email
    ExpenseMailer.welcome_email
  end

  # Preview this email at http://localhost:3000/rails/mailers/expense_mailer/limit_warning
  def limit_warning
    ExpenseMailer.limit_warning
  end

  # Preview this email at http://localhost:3000/rails/mailers/expense_mailer/monthly_report
  def monthly_report
    ExpenseMailer.monthly_report
  end
end
