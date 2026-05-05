class Api::V1::Admin::AuditLogsController < ApplicationController
  before_action :require_admin!

  def index
    pagy, logs = pagy(
      AuditLog.includes(:user).recent,
      limit: 50
    )

    render json: {
      logs: logs.as_json(
        include: { user: { only: [:id, :email] } },
        only: [:id, :action, :resource, :ip_address, :success, :metadata, :created_at]
      ),
      pagination: {
        total: pagy.count,
        page: pagy.page,
        total_pages: pagy.last
      }
    }, status: :ok
  end

  private

  def require_admin!
    unless current_user.admin?
      render json: { error: "acesso negado" }, status: :forbidden
    end
  end
end