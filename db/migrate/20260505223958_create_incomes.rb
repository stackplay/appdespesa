class CreateIncomes < ActiveRecord::Migration[7.2]
  def change
    create_table :incomes do |t|
      t.string :description, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :date, null: false
      t.boolean :recurring, default: false, null: false
      t.string :frequency, default: "monthly"
      t.string :category, default: "salary"
      t.text :notes
      t.string :source
      t.boolean :tax_deductible, default: false, null: false
      t.string :status, default: "expected", null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :incomes, [:user_id, :date]
    add_index :incomes, [:user_id, :status]
    add_index :incomes, [:user_id, :recurring]
  end
end