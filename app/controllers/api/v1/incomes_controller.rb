class Api::V1::IncomesController < ApplicationController
  before_action :set_income, only: [:update, :destroy]

  def index
    incomes = current_user.incomes
    incomes = incomes.where(status: params[:status]) if params[:status]
    incomes = incomes.where(category: params[:category]) if params[:category]
    incomes = incomes.for_month(Date.strptime(params[:month], "%Y-%m")) if params[:month]
    incomes = incomes.order(date: :desc)

    pagy, incomes = pagy(incomes, limit: (params[:per_page] || 20).to_i)

    render json: {
      incomes: JSON.parse(IncomeBlueprint.render(incomes)),
      pagination: {
        total: pagy.count,
        page: pagy.page,
        per_page: pagy.limit,
        total_pages: pagy.last
      }
    }, status: :ok
  end

  def create
    income = current_user.incomes.build(income_params)

    if income.save
      render json: IncomeBlueprint.render(income), status: :created
    else
      render json: { errors: income.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @income.update(income_params)
      render json: IncomeBlueprint.render(@income), status: :ok
    else
      render json: { errors: @income.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @income.destroy
    render json: { message: "rendimento apagado com sucesso" }, status: :ok
  end

  private

  def set_income
    @income = current_user.incomes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "rendimento não encontrado" }, status: :not_found
  end

  def income_params
    params.require(:income).permit(
      :description, :amount, :date, :recurring,
      :frequency, :category, :notes, :source,
      :tax_deductible, :status
    )
  end
end