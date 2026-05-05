class ExpenseCreator
  def initialize(user:, params:)
    @user = user
    @tag_names = params.delete(:tag_names) || []
    @params = params
  end

  def call
    expense = @user.expenses.build(@params)
    validate_date!(expense)
    check_monthly_limit!(expense)

    if expense.save
      attach_tags!(expense)
      LimitWarningJob.perform_later(@user.id, expense.category_id)
      success(expense)
    else
      failure(expense.errors.full_messages)
    end
  rescue BusinessRuleViolation => e
    failure([e.message])
  end

  private

  def attach_tags!(expense)
    return if @tag_names.blank?
    @tag_names.each do |name|
      next if name.blank?
      tag = @user.tags.find_or_create_by(name: name.downcase.strip)
      expense.tags << tag unless expense.tags.include?(tag)
    end
  end

  def validate_date!(expense)
    return unless expense.date.present?
    if expense.date > Date.current
      raise BusinessRuleViolation,
        "nao e permitido registar despesas com data futura"
    end
  end

  def check_monthly_limit!(expense)
    category = expense.category
    return unless category&.monthly_limit.present?

    spent = @user.expenses
                 .where(category: category)
                 .where(date: Date.current.beginning_of_month..Date.current.end_of_month)
                 .sum(:amount)

    remaining = category.monthly_limit - spent

    if expense.amount > remaining
      raise BusinessRuleViolation,
        "limite mensal de #{category.monthly_limit}EUR atingido para '#{category.name}'. " \
        "Ja gastaste #{spent}EUR este mes. Disponivel: #{[remaining, 0].max}EUR"
    end
  end

  def success(expense)
    { success: true, expense: expense }
  end

  def failure(errors)
    { success: false, errors: errors }
  end

  class BusinessRuleViolation < StandardError; end
end
