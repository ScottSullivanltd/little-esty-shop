class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice
  has_one :merchant, through: :item
  has_many :bulk_discounts, through: :merchant

  validates :quantity, presence: true
  validates :unit_price, presence: true, numericality: true

  enum status: {"Pending" => 0, "Packaged" => 1, "Shipped" => 2}
end
