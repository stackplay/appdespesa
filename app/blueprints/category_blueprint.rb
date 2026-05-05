class CategoryBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :monthly_limit, :created_at

  field :total_spent do |category, options|
    user = options[:current_user]
    category.expenses
            .where(user: user)
            .where(date: Date.current.beginning_of_month..Date.current.end_of_month)
            .sum(:amount).to_f.round(2)
  end

  field :remaining_budget do |category, options|
    next nil unless category.monthly_limit
    user = options[:current_user]
    spent = category.expenses
                    .where(user: user)
                    .where(date: Date.current.beginning_of_month..Date.current.end_of_month)
                    .sum(:amount)
    (category.monthly_limit - spent).to_f.round(2)
  end

  field :budget_used_pct do |category, options|
    next nil unless category.monthly_limit && category.monthly_limit > 0
    user = options[:current_user]
    spent = category.expenses
                    .where(user: user)
                    .where(date: Date.current.beginning_of_month..Date.current.end_of_month)
                    .sum(:amount)
    ((spent / category.monthly_limit) * 100).to_f.round(1)
  end

  view :admin do
    include_view :default
    field :user_id
    association :user, blueprint: UserBlueprint
  end
end