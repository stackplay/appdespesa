class ApplicationController < ActionController::API
  include Pagy::Backend

  before_action :authenticate_user!
  after_action :log_request

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    if token.nil?
      render json: { error: "não autenticado" }, status: :unauthorized
      return
    end

    decoded = JWT.decode(token, ENV.fetch("SECRET_KEY_BASE"), true, algorithm: "HS256")
    @current_user = User.find(decoded.first["user_id"])
  rescue JWT::DecodeError
    render json: { error: "token inválido" }, status: :unauthorized
  rescue ActiveRecord::RecordNotFound
    render json: { error: "utilizador não encontrado" }, status: :unauthorized
  end

  def current_user
    @current_user
  end

  def log_request
    return unless @current_user
    return if request.path.include?("letter_opener")

    AuditLog.record(
      user: @current_user,
      action: "#{request.method} #{request.path}",
      resource: controller_name,
      ip_address: request.remote_ip,
      success: response.successful?,
      metadata: { status: response.status }
    )
  rescue StandardError
    nil
  end
end