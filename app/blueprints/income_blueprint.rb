class IncomeBlueprint < Blueprinter::Base
  identifier :id

  fields :description, :amount, :date, :recurring,
         :frequency, :category, :notes, :source,
         :tax_deductible, :status, :created_at

  view :admin do
    include_view :default
    association :user, blueprint: UserBlueprint
  end
end