class Api::V1::ProfilesController < ApplicationController
  def show
    render json: UserBlueprint.render(current_user, view: :with_stats), status: :ok
  end

  def update
    if current_user.update(profile_params)
      render json: UserBlueprint.render(current_user), status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def password
    unless current_user.authenticate(params[:current_password])
      render json: { error: "password actual incorrecta" }, status: :unauthorized
      return
    end

    if params[:new_password] != params[:new_password_confirmation]
      render json: { error: "as passwords novas nao coincidem" }, status: :unprocessable_entity
      return
    end

    if current_user.update(password: params[:new_password], password_confirmation: params[:new_password_confirmation])
      current_user.refresh_tokens.destroy_all
      render json: { message: "password alterada com sucesso — faz login novamente" }, status: :ok
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def deactivate
    unless current_user.authenticate(params[:password])
      render json: { error: "password incorrecta" }, status: :unauthorized
      return
    end

    current_user.refresh_tokens.destroy_all
    current_user.destroy
    render json: { message: "conta apagada com sucesso" }, status: :ok
  end

  private

  def profile_params
    params.require(:profile).permit(:email)
  end
end