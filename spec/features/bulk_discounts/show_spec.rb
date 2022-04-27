require "rails_helper"

RSpec.describe "Bulk Discount Show page", type: :feature do
  it "displays bulk discount attributes", :vcr do
    merchant1 = create(:merchant)
    bulk_discount1 = merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 15)

    visit merchant_bulk_discounts_path(merchant1.id)

    expect(page).to have_content(bulk_discount1.percentage_discount)
    expect(page).to have_content(bulk_discount1.quantity_threshold)
  end

  it "has link to edit bulk discount", :vcr do
    merchant1 = create(:merchant)
    bulk_discount1 = merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 15)

    visit merchant_bulk_discounts_path(merchant1.id)

    expect(page).to have_link("Edit Bulk Discount")

    click_link "Edit Bulk Discount"

    expect(current_path).to eq(merchant_bulk_discount_path(merchant1.id, bulk_discount1.id))
  end
end
