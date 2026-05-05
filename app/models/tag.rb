class Tag < ApplicationRecord
  belongs_to :user
  has_many :expense_tags, dependent: :destroy
  has_many :expenses, through: :expense_tags

  validates :name, presence: true,
                   length: { minimum: 2, maximum: 30 },
                   uniqueness: { scope: :user_id, case_sensitive: false }

  before_save { self.name = name.downcase.strip }
end