class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_user!

  def register
    user = User.new(register_params)
    if user.save
      WelcomeEmailJob.perform_later(user.id)
      tokens = generate_tokens(user)
      render json: {
        message: "conta criada com sucesso",
        access_token: tokens[:access_token],
        refresh_token: tokens[:refresh_token]
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email]&.downcase)
    if user&.authenticate(params[:password])
      tokens = generate_tokens(user)
      render json: {
        message: "login com sucesso",
        access_token: tokens[:access_token],
        refresh_token: tokens[:refresh_token]
      }, status: :ok
    else
      render json: { error: "email ou password incorrectos" }, status: :unauthorized
    end
  end

  def refresh
    refresh_token = RefreshToken.find_by(token: params[:refresh_token])

    unless refresh_token&.valid_token?
      render json: { error: "refresh token invalido ou expirado" }, status: :unauthorized
      return
    end

    refresh_token.revoke!
    tokens = generate_tokens(refresh_token.user)

    render json: {
      access_token: tokens[:access_token],
      refresh_token: tokens[:refresh_token]
    }, status: :ok
  end

  def logout
    refresh_token = RefreshToken.find_by(token: params[:refresh_token])
    refresh_token&.revoke!
    render json: { message: "logout com sucesso" }, status: :ok
  end

  private

  def register_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def generate_tokens(user)
    access_token = JWT.encode(
      { user_id: user.id, exp: 1.hour.from_now.to_i },
      ENV.fetch("SECRET_KEY_BASE"),
      "HS256"
    )
    refresh_token = RefreshToken.generate(user)
    { access_token: access_token, refresh_token: refresh_token.token }
  end
end