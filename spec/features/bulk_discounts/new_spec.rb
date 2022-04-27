require "rails_helper"

RSpec.describe "Create New Bulk Discount", type: :feature do
  it "displays a form for a new bulk discount", :vcr do
    @merchant1 = create(:merchant)

    visit merchant_bulk_discounts_path(@merchant1.id)

    click_link "Create New Discount"

    fill_in :percentage_discount, with: 15
    fill_in :quantity_threshold, with: 15
    click_on "Create"

    expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1.id))
  end
end
