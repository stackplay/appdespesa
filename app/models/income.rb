class Income < ApplicationRecord
  belongs_to :user

  FREQUENCIES = %w[monthly weekly biweekly yearly one_time].freeze
  CATEGORIES = %w[salary freelance rent investment bonus other].freeze
  STATUSES = %w[expected received cancelled].freeze

  validates :description, presence: true, length: { minimum: 2, maximum: 255 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true
  validates :frequency, inclusion: { in: FREQUENCIES }, allow_nil: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }

  validate :frequency_required_if_recurring

  scope :received, -> { where(status: "received") }
  scope :expected, -> { where(status: "expected") }
  scope :recurring, -> { where(recurring: true) }
  scope :for_month, ->(date) { where(date: date.beginning_of_month..date.end_of_month) }

  private

  def frequency_required_if_recurring
    if recurring? && frequency.blank?
      errors.add(:frequency, "é obrigatória para rendimentos recorrentes")
    end
  end
end