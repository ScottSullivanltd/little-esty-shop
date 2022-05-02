require "rails_helper"

RSpec.describe "Merchant Invoices Show" do
  describe "display" do
    it "invoice attributes", :vcr do
      merchants = create_list(:merchant, 3)
      items1 = create_list(:item, 3, merchant: merchants[0])
      items2 = create_list(:item, 2, merchant: merchants[1])
      customers = create_list(:customer, 2)

      invoices1 = create_list(:invoice, 2, customer: customers[0])
      invoice_item1 = create(:invoice_item, invoice: invoices1[0], item: items1[0])
      invoice_item3 = create(:invoice_item, invoice: invoices1[1], item: items1[1])
      invoice_item2 = create(:invoice_item, invoice: invoices1[0], item: items1[2])

      invoices2 = create_list(:invoice, 2, customer: customers[1])
      invoice_item6 = create(:invoice_item, invoice: invoices2[0], item: items2[0])
      invoice_item4 = create(:invoice_item, invoice: invoices2[1], item: items2[1])

      visit merchant_invoice_path(merchants[0], invoices1[0])

      expect(page).to have_content(invoices1[0].id)
      expect(page).to have_content("Status: In Progress")
      expect(page).to have_content("Created On: #{invoices1[0].created_at.strftime("%A, %B %d, %Y")}")
      expect(page).to have_content(invoices1[0].customer.full_name)
      expect(page).to_not have_content(invoices1[1])
      expect(page).to_not have_content(invoices2)
    end

    it "Shows the total revenue for the selected invoice", :vcr do
      merchants = create_list(:merchant, 3)
      items1 = create_list(:item, 3, merchant: merchants[0])
      items2 = create_list(:item, 2, merchant: merchants[1])
      customers = create_list(:customer, 2)

      invoices1 = create_list(:invoice, 2, customer: customers[0])
      invoice_item1 = create(:invoice_item, invoice: invoices1[0], item: items1[0])
      invoice_item3 = create(:invoice_item, invoice: invoices1[1], item: items1[1])
      invoice_item2 = create(:invoice_item, invoice: invoices1[0], item: items1[2])

      invoices2 = create_list(:invoice, 2, customer: customers[1])
      invoice_item6 = create(:invoice_item, invoice: invoices2[0], item: items2[0])
      invoice_item4 = create(:invoice_item, invoice: invoices2[1], item: items2[1])

      visit merchant_invoice_path(merchants[0], invoices1[0])

      expected = (invoice_item1.quantity * invoice_item1.unit_price) + (invoice_item2.quantity * invoice_item2.unit_price)
      expect(page).to have_content(invoices1[0].total_revenue)
      expect(invoices1[0].total_revenue).to eq(expected)
    end

    it "displays total discounted revenue after bulk discounts are applied" do
      merchant_1 = create :merchant
      merchant_2 = create :merchant

      customer = create(:customer)

      item_1 = create :item, {merchant_id: merchant_1.id}
      item_2 = create :item, {merchant_id: merchant_1.id}
      item_3 = create :item, {merchant_id: merchant_2.id}
      item_4 = create :item, {merchant_id: merchant_1.id}

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
      bulk_disc4 = merchant_2.bulk_discounts.create!(percentage_discount: 25, quantity_threshold: 6)

      visit merchant_invoice_path(merchant_1, invoice_1)

      expect(page).to have_content(invoice_1.total_revenue / 100)
      expect(invoice_1.total_revenue / 100).to eq(876.00)
      expect(page).to have_content(invoice_1.total_revenue_after_discount / 100)
      expect(invoice_1.total_revenue_after_discount / 100).to eq(834.20)
    end
  end

  describe "invoice items" do
    it "lists all invoice item names, quantity, price and status", :vcr do
      merchants = create_list(:merchant, 3)
      items1 = create_list(:item, 3, merchant: merchants[0])
      items2 = create_list(:item, 2, merchant: merchants[1])
      customers = create_list(:customer, 2)

      invoices1 = create_list(:invoice, 2, customer: customers[0])
      invoice_item1 = create(:invoice_item, invoice: invoices1[0], item: items1[0])
      invoice_item3 = create(:invoice_item, invoice: invoices1[1], item: items1[1])
      invoice_item2 = create(:invoice_item, invoice: invoices1[0], item: items1[2])

      invoices2 = create_list(:invoice, 2, customer: customers[1])
      invoice_item6 = create(:invoice_item, invoice: invoices2[0], item: items2[0])
      invoice_item4 = create(:invoice_item, invoice: invoices2[1], item: items2[1])

      visit merchant_invoice_path(merchants[0], invoices1[0])

      within "#invoice_item-#{invoice_item2.id}" do
        expect(page).to have_content(invoice_item2.item.name)
        expect(page).to have_content(invoice_item2.quantity)
        expect(page).to have_content(invoice_item2.unit_price)
        expect(page).to have_content(invoice_item2.status)
        expect(page).to_not have_content(items1[1])
        expect(page).to_not have_content(items2)
      end

      visit merchant_invoice_path(merchants[1], invoices2[0])
      within "#invoice_item-#{invoice_item6.id}" do
        expect(page).to have_content(invoice_item6.item.name)
        expect(page).to have_content(invoice_item6.quantity)
        expect(page).to have_content(invoice_item6.unit_price)
        expect(page).to have_content(invoice_item6.status)
        expect(page).to_not have_content(items2[1])
        expect(page).to_not have_content(items1)
      end
    end

    it "select update invoice item status", :vcr do
      merchants = create_list(:merchant, 3)
      items1 = create_list(:item, 3, merchant: merchants[0])
      items2 = create_list(:item, 2, merchant: merchants[1])
      customers = create_list(:customer, 2)

      invoices1 = create_list(:invoice, 2, customer: customers[0])
      invoice_item1 = create(:invoice_item, invoice: invoices1[0], item: items1[0])
      invoice_item3 = create(:invoice_item, invoice: invoices1[1], item: items1[1])
      invoice_item2 = create(:invoice_item, invoice: invoices1[0], item: items1[2])

      invoices2 = create_list(:invoice, 2, customer: customers[1])
      invoice_item6 = create(:invoice_item, invoice: invoices2[0], item: items2[0])
      invoice_item4 = create(:invoice_item, invoice: invoices2[1], item: items2[1])

      visit merchant_invoice_path(merchants[0], invoices1[0])
      within "#invoice_item-#{invoice_item2.id}" do
        expect(page).to have_content("Pending")
        select "Packaged"
        click_button "Update Invoice Item Status"

        expect(current_path).to eq(merchant_invoice_path(merchants[0], invoices1[0]))
        expect(invoice_item2.reload.status).to eq("Packaged")
      end
    end
  end
end
