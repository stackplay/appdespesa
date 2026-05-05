require "csv"

class Api::V1::ExpensesController < ApplicationController
  before_action :set_expense, only: [:destroy]

  def index
    expenses = current_user.expenses.includes(:category, :tags)
    expenses = expenses.where(category_id: params[:category_id]) if params[:category_id]
    expenses = expenses.where(date: month_range(params[:month])) if params[:month]
    expenses = expenses.where("amount >= ?", params[:min_amount]) if params[:min_amount]
    expenses = expenses.where("amount <= ?", params[:max_amount]) if params[:max_amount]
    expenses = expenses.where("description ILIKE ?", "%#{params[:q]}%") if params[:q]
    expenses = expenses.order(date: :desc)

    pagy, expenses = pagy(expenses, limit: (params[:per_page] || 20).to_i)

    render json: {
      expenses: JSON.parse(ExpenseBlueprint.render(expenses)),
      pagination: {
        total: pagy.count,
        page: pagy.page,
        per_page: pagy.limit,
        total_pages: pagy.last
      }
    }, status: :ok
  end

  def create
    result = ExpenseCreator.new(
      user: current_user,
      params: expense_params
    ).call

    if result[:success]
      render json: ExpenseBlueprint.render(result[:expense].reload), status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  def destroy
    @expense.destroy
    render json: { message: "despesa apagada com sucesso" }, status: :ok
  end

  def export
  expenses = current_user.expenses.includes(:category, :tags).order(date: :desc)
  expenses = expenses.where(date: month_range(params[:month])) if params[:month]

  csv_data = CSV.generate(headers: true) do |csv|
    csv << ["Data", "Descricao", "Categoria", "Valor", "Tags"]
    expenses.each do |expense|
      csv << [
        expense.date,
        expense.description,
        expense.category&.name,
        expense.amount.to_f,
        expense.tags.map(&:name).join(", ")
      ]
    end
  end

  send_data csv_data,
    filename: "despesas_#{Date.current}.csv",
    type: "text/csv",
    disposition: "attachment"
end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "despesa não encontrada" }, status: :not_found
  end

  def expense_params
    params.require(:expense).permit(
      :description,
      :amount,
      :date,
      :category_id,
      tag_names: []
    )
  end

  def month_range(month_str)
    date = Date.strptime(month_str, "%Y-%m")
    date.beginning_of_month..date.end_of_month
  rescue ArgumentError
    Date.current.beginning_of_month..Date.current.end_of_month
  end
end