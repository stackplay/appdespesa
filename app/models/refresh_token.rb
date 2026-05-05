class RefreshToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true

  def self.generate(user)
    create!(
      user: user,
      token: SecureRandom.hex(32),
      expires_at: 30.days.from_now
    )
  end

  def valid_token?
    !revoked? && !expired?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def revoked?
    revoked_at.present?
  end

  def expired?
    expires_at < Time.current
  end
end