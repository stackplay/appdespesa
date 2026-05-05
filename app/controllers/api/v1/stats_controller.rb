class Api::V1::StatsController < ApplicationController
  def overview
  month_start = Date.current.beginning_of_month
  month_end = Date.current.end_of_month

  monthly_expenses = current_user.expenses.where(date: month_start..month_end)
  monthly_incomes = current_user.incomes.where(date: month_start..month_end)

  total_spent = monthly_expenses.sum(:amount).to_f.round(2)
  total_received = monthly_incomes.received.sum(:amount).to_f.round(2)
  total_expected = monthly_incomes.expected.sum(:amount).to_f.round(2)
  balance = (total_received - total_spent).round(2)

  total_budget = current_user.categories
                             .where.not(monthly_limit: nil)
                             .sum(:monthly_limit).to_f.round(2)

  biggest_expense = monthly_expenses.order(amount: :desc).includes(:category).first
  biggest_income = monthly_incomes.order(amount: :desc).first

  render json: {
    month: Date.current.strftime("%Y-%m"),
    total_spent: total_spent,
    total_received: total_received,
    total_expected: total_expected,
    balance: balance,
    balance_status: balance >= 0 ? "positive" : "negative",
    total_budget: total_budget,
    budget_used_pct: total_budget > 0 ? ((total_spent / total_budget) * 100).round(1) : nil,
    savings_rate: total_received > 0 ? ((balance / total_received) * 100).round(1) : nil,
    total_expenses_count: monthly_expenses.count,
    total_incomes_count: monthly_incomes.count,
    biggest_expense: biggest_expense ? {
      description: biggest_expense.description,
      amount: biggest_expense.amount.to_f,
      category: biggest_expense.category&.name
    } : nil,
    biggest_income: biggest_income ? {
      description: biggest_income.description,
      amount: biggest_income.amount.to_f,
      category: biggest_income.category
    } : nil
  }, status: :ok
end

  def monthly
    months = (0..11).map do |i|
      date = i.months.ago.to_date
      start_date = date.beginning_of_month
      end_date = date.end_of_month
      spent = current_user.expenses
                          .where(date: start_date..end_date)
                          .sum(:amount).to_f.round(2)
      {
        month: date.strftime("%Y-%m"),
        month_name: date.strftime("%b %Y"),
        total_spent: spent,
        total_expenses: current_user.expenses.where(date: start_date..end_date).count
      }
    end.reverse

    render json: { months: months }, status: :ok
  end

  def by_category
    month_start = Date.current.beginning_of_month
    month_end = Date.current.end_of_month

    categories = current_user.categories.includes(:expenses).map do |category|
      spent = category.expenses
                      .where(user: current_user)
                      .where(date: month_start..month_end)
                      .sum(:amount).to_f.round(2)

      limit = category.monthly_limit&.to_f
      pct = if limit && limit > 0
        ((spent / limit) * 100).round(1)
      end

      {
        id: category.id,
        name: category.name,
        monthly_limit: limit,
        total_spent: spent,
        remaining: limit ? (limit - spent).round(2) : nil,
        budget_used_pct: pct,
        expenses_count: category.expenses.where(user: current_user).where(date: month_start..month_end).count
      }
    end

    render json: { categories: categories, month: Date.current.strftime("%Y-%m") }, status: :ok
  end
end
