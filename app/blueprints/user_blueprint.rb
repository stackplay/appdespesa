class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :email, :role, :created_at

  view :with_stats do
    field :total_expenses do |user|
      user.expenses.count
    end
    field :total_spent do |user|
      user.expenses.sum(:amount).to_f.round(2)
    end
  end
end