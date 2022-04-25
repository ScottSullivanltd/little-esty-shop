class BulkDiscount < ApplicationRecord
  validates :percentage_discount, presence: true
  validates :quantity_threshold, presence: true, numericality: true

  belongs_to :merchant
end
