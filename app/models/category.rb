class Category < ApplicationRecord
  belongs_to :user
  has_many :expenses, dependent: :destroy

  validates :name, presence: true,
                   length: { minimum: 2, maximum: 50 },
                   uniqueness: { scope: :user_id, case_sensitive: false }
end