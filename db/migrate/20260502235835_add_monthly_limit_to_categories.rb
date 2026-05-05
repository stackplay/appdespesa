class AddMonthlyLimitToCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :monthly_limit, :decimal
  end
end
