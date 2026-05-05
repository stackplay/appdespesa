class Api::V1::CategoriesController < ApplicationController
  before_action :set_category, only: [:update, :destroy]

  def index
    categories = current_user.categories.includes(:expenses)
    render json: CategoryBlueprint.render(categories, current_user: current_user), status: :ok
  end

  def create
    category = current_user.categories.build(category_params)
    if category.save
      render json: CategoryBlueprint.render(category, current_user: current_user), status: :created
    else
      render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: CategoryBlueprint.render(@category, current_user: current_user), status: :ok
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    render json: { message: "categoria apagada com sucesso" }, status: :ok
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "categoria não encontrada" }, status: :not_found
  end

  def category_params
    params.require(:category).permit(:name, :monthly_limit)
  end
end