class Expense < ApplicationRecord
  belongs_to :category
  belongs_to :user
  has_many :expense_tags, dependent: :destroy
  has_many :tags, through: :expense_tags

  validates :description, presence: true,
                          length: { minimum: 2, maximum: 255 }
  validates :amount, presence: true,
                     numericality: { greater_than: 0 }
  validates :date, presence: true

  validate :category_belongs_to_user

  private

  def category_belongs_to_user
    return unless category.present?
    if category.user_id != user_id
      errors.add(:category, "não pertence a este utilizador")
    end
  end
end
