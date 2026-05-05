class ExpenseTag < ApplicationRecord
  belongs_to :expense
  belongs_to :tag

  validates :expense_id, uniqueness: { scope: :tag_id }
end