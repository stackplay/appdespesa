class ExpenseBlueprint < Blueprinter::Base
  identifier :id

  fields :description, :amount, :date, :created_at

  association :category, blueprint: CategoryBlueprint

  field :tags do |expense|
    expense.tags.map(&:name)
  end

  view :admin do
    include_view :default
    association :user, blueprint: UserBlueprint
  end
end