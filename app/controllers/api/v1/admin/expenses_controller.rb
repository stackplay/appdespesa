class Api::V1::Admin::ExpensesController < ApplicationController
  before_action :require_admin!

 def index
  expenses = Expense.all.includes(:user, :category)
  render json: expenses.as_json(
    include: {
      user: { only: [:id, :email, :role] },
      category: { only: [:id, :name, :monthly_limit] }
    },
    except: [:user_id, :category_id]
  ), status: :ok
end

  private

  def require_admin!
    unless current_user.admin?
      render json: { error: "acesso negado — apenas administradores" }, status: :forbidden
    end
  end
end