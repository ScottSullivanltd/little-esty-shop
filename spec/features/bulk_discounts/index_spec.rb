require "rails_helper"

RSpec.describe "Bulk Discounts Index", type: :feature do
  before :each do
    @merchant1 = create(:merchant)
    @bulk_discount1 = @merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 15)
    @bulk_discount2 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 25)
    @bulk_discount3 = @merchant1.bulk_discounts.create!(percentage_discount: 30, quantity_threshold: 35)
  end

  it "displays all bulk discounts", :vcr do
    visit merchant_bulk_discounts_path(@merchant1.id)

    within "#bulk_discount-#{@bulk_discount1.id}" do
      expect(page).to have_content(@bulk_discount1.percentage_discount.to_i)
      expect(page).to have_content(@bulk_discount1.quantity_threshold)
      expect(page).to_not have_content(@bulk_discount2.percentage_discount.to_i)
      expect(page).to_not have_content(@bulk_discount2.quantity_threshold)
    end

    within "#bulk_discount-#{@bulk_discount2.id}" do
      expect(page).to have_content(@bulk_discount2.percentage_discount.to_i)
      expect(page).to have_content(@bulk_discount2.quantity_threshold)
      expect(page).to_not have_content(@bulk_discount3.percentage_discount.to_i)
      expect(page).to_not have_content(@bulk_discount3.quantity_threshold)
    end

    within "#bulk_discount-#{@bulk_discount3.id}" do
      expect(page).to have_content(@bulk_discount3.percentage_discount.to_i)
      expect(page).to have_content(@bulk_discount3.quantity_threshold)
      expect(page).to_not have_content(@bulk_discount1.percentage_discount.to_i)
      expect(page).to_not have_content(@bulk_discount1.quantity_threshold)
    end
  end
end
