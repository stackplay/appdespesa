class MonthlyReportJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      month = 1.month.ago.to_date
      ExpenseMailer.monthly_report(user, month).deliver_now
    end
  end
end