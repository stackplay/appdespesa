class Api::V1::TagsController < ApplicationController
  def index
    tags = current_user.tags.order(:name)
    render json: tags.as_json(only: [:id, :name]), status: :ok
  end
end