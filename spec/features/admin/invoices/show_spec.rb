require "rails_helper"

RSpec.describe "Admin Invoice Show", type: :feature do
  before :each do
    @merchant1 = create(:merchant)
    @items = create_list(:item, 4, merchant: @merchant1)
    @customer1 = create(:customer)
    @customer2 = create(:customer)
    @invoice1 = create(:invoice, customer: @customer1)
    @invoice2 = create(:invoice, customer: @customer2)
    @invoice_item1 = create(:invoice_item, invoice: @invoice1, item: @items[0])
    @invoice_item2 = create(:invoice_item, invoice: @invoice1, item: @items[1])
    @invoice_item3 = create(:invoice_item, invoice: @invoice2, item: @items[2])
    @invoice_item4 = create(:invoice_item, invoice: @invoice2, item: @items[3])
  end

  it "Shows the attributes for the selected invoice", :vcr do
    visit admin_invoice_path(@invoice1)

    within("#invoice-info") do
      expect(page).to have_content(@invoice1.id)
      expect(page).to have_content(@invoice1.status)
      expect(page).to have_content(@invoice1.created_at.strftime("%A, %B %e, %Y"))
      expect(page).to have_content(@customer1.first_name)
      expect(page).to have_content(@customer1.last_name)
      expect(page).to_not have_content(@invoice2.id)
      expect(page).to_not have_content(@customer2.first_name)
      expect(page).to_not have_content(@customer2.last_name)
    end
  end

  it "Shows the attributes for the invoice items on the selected invoice", :vcr do
    visit admin_invoice_path(@invoice1)

    within("#invoice_items-#{@invoice_item1.id}") do
      expect(page).to have_content(@items.first.name)
      expect(page).to have_content(@invoice_item1.quantity)
      expect(page).to have_content(@invoice_item1.unit_price)
      expect(page).to have_content(@invoice_item1.status)
      expect(page).to_not have_content(@items.second.name)
    end

    within("#invoice_items-#{@invoice_item2.id}") do
      expect(page).to have_content(@items.second.name)
      expect(page).to have_content(@invoice_item2.quantity)
      expect(page).to have_content(@invoice_item2.unit_price)
      expect(page).to have_content(@invoice_item2.status)
      expect(page).to_not have_content(@items.first.name)
    end
  end

  it "Shows the total revenue for the selected invoice", :vcr do
    visit admin_invoice_path(@invoice1)

    expected = (@invoice_item1.quantity * @invoice_item1.unit_price) + (@invoice_item2.quantity * @invoice_item2.unit_price)

    expect(page).to have_content(@invoice1.total_revenue)
    expect(@invoice1.total_revenue).to eq(expected)
  end

  it "Shows the total discount revenue for the selected invoice", :vcr do
    merchant_1 = create :merchant

    customer = create(:customer)

    item_1 = create :item, {merchant_id: merchant_1.id}
    item_2 = create :item, {merchant_id: merchant_1.id}
    item_3 = create :item, {merchant_id: merchant_1.id}

    invoice_1 = create(:invoice, customer_id: customer.id)
    invoice_2 = create(:invoice, customer_id: customer.id)
    invoice_3 = create(:invoice, customer_id: customer.id)

    invoice_item_1 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_4.id, quantity: 16, unit_price: 2200)
    invoice_item_2 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_1.id, quantity: 6, unit_price: 4200)
    invoice_item_3 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_3.id, quantity: 4, unit_price: 3500)
    invoice_item_4 = create(:invoice_item, invoice_id: invoice_1.id, item_id: item_2.id, quantity: 11, unit_price: 1200)
    invoice_item_5 = create(:invoice_item, invoice_id: invoice_2.id, item_id: item_3.id, quantity: 9, unit_price: 7300)
    invoice_item_6 = create(:invoice_item, invoice_id: invoice_3.id, item_id: item_2.id, quantity: 4, unit_price: 9500, status: 2)

    bulk_disc1 = merchant_1.bulk_discounts.create!(percentage_discount: 5, quantity_threshold: 10)
    bulk_disc2 = merchant_1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 15)
    bulk_disc3 = merchant_1.bulk_discounts.create!(percentage_discount: 15, quantity_threshold: 20)

    visit merchant_invoice_path(merchant_1, invoice_1)

    expect(page).to have_content(invoice_1.total_revenue_after_discount)
    expect(invoice_1.total_revenue_after_discount).to eq(83420)
    # expect(invoice_2.total_revenue_after_discount).to eq(49275)
    # expect(invoice_3.total_revenue_after_discount).to eq(38000)
    # expect(invoice_1.total_revenue_after_discount).to_not eq(0)
  end

  it "Updates the invoice status to the status that is selected from the status select field", :vcr do
    @invoice1.update(status: "In Progress")
    visit admin_invoice_path(@invoice1)

    within("#invoice-info") do
      expect(page).to have_content("In Progress")
    end

    select "Completed"
    click_button "Update Invoice Status"

    expect(current_path).to eq(admin_invoice_path(@invoice1))
    expect(@invoice1.reload.status).to eq("Completed")
  end
end
