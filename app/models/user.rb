class User < ApplicationRecord
  has_secure_password
  has_many :categories, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :audit_logs, dependent: :destroy
  has_many :incomes, dependent: :destroy

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[user admin] }

  def admin?
    role == "admin"
  end

  def user?
    role == "user"
  end
end