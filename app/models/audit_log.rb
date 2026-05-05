class AuditLog < ApplicationRecord
  belongs_to :user

  validates :action, presence: true

  serialize :metadata, coder: JSON

  scope :recent, -> { order(created_at: :desc) }
  scope :successful, -> { where(success: true) }
  scope :failed, -> { where(success: false) }

  def self.record(user:, action:, resource: nil, ip_address: nil, success: true, metadata: {})
    create!(
      user: user,
      action: action,
      resource: resource,
      ip_address: ip_address,
      success: success,
      metadata: metadata
    )
  end
end