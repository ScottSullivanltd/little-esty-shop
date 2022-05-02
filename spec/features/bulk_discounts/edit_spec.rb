require "rails_helper"

RSpec.describe "Edit Bulk Discount", type: :feature do
  it "displays a form to edit bulk discount", :vcr do
    merchant1 = create(:merchant)
    bulk_discount1 = merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 10)

    visit merchant_bulk_discounts_path(merchant1.id)

    expect(bulk_discount1.percentage_discount).to eq(10)
    expect(bulk_discount1.quantity_threshold).to eq(10)

    click_link "Edit Bulk Discount"

    visit edit_merchant_bulk_discount_path(merchant1.id, bulk_discount1.id)

    fill_in :percentage_discount, with: 15
    fill_in :quantity_threshold, with: 15
    click_on "Edit Bulk Discount"

    expect(current_path).to eq(merchant_bulk_discount_path(merchant1.id, bulk_discount1.id))
    expect(page).to have_content("Bulk Discount Percentage: 15.0")
    expect(page).to have_content("Discount Quantity Threshold: 15")
  end
end
