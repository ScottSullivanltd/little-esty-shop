require "rails_helper"

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it {
      should define_enum_for(:status).with([
        "Cancelled", "In Progress", "Completed"
      ])
    }
  end

  describe "relationships" do
    it { should belong_to(:customer) }
    it { should have_many(:transactions) }
    it { should have_many(:invoice_items) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
  end

  describe "class methods" do
    before do
      @merchant_1 = create :merchant
      @merchant_2 = create :merchant

      @customer = create(:customer)

      @item_1 = create :item, {merchant_id: @merchant_1.id}
      @item_2 = create :item, {merchant_id: @merchant_1.id}
      @item_3 = create :item, {merchant_id: @merchant_2.id}
      @item_4 = create :item, {merchant_id: @merchant_1.id}

      @invoice_1 = create(:invoice, customer_id: @customer.id)
      @invoice_2 = create(:invoice, customer_id: @customer.id)
      @invoice_3 = create(:invoice, customer_id: @customer.id)

      @invoice_item_1 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_4.id, quantity: 16, unit_price: 2200)
      @invoice_item_2 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 6, unit_price: 4200)
      @invoice_item_3 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 4, unit_price: 3500)
      @invoice_item_4 = create(:invoice_item, invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 11, unit_price: 1200)
      @invoice_item_5 = create(:invoice_item, invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 9, unit_price: 7300)
      @invoice_item_6 = create(:invoice_item, invoice_id: @invoice_3.id, item_id: @item_2.id, quantity: 4, unit_price: 9500, status: 2)

      @bulk_disc1 = @merchant_1.bulk_discounts.create!(percentage_discount: 5, quantity_threshold: 10)
      @bulk_disc2 = @merchant_1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 15)
      @bulk_disc3 = @merchant_1.bulk_discounts.create!(percentage_discount: 15, quantity_threshold: 20)
      @bulk_disc4 = @merchant_2.bulk_discounts.create!(percentage_discount: 25, quantity_threshold: 6)
    end

    it "Shows the total revenue for the selected invoice" do
      expect(@invoice_1.total_revenue).to eq(87600)
      expect(@invoice_1.total_revenue).to_not eq("yes")
    end

    it "displays incomplete invoices with date it was created and link to their show page" do
      invoices = Invoice.all
      expect(invoices.incomplete_invoices).to eq([@invoice_1, @invoice_2])
      expect(invoices.incomplete_invoices).to_not eq([@invoice_3])
      expect(invoices.incomplete_invoices[0].created_at.strftime("%A, %B %e, %Y")).to eq(@invoice_1.created_at.strftime("%A, %B %e, %Y"))
      expect(invoices.incomplete_invoices.length).to eq(2)
      expect(invoices.incomplete_invoices.length).to_not eq(6)
    end

    it "computes bulk discount amount for an invoice" do
      expect(@invoice_1.invoice_discount_amount).to eq(4180)
      expect(@invoice_2.invoice_discount_amount).to eq(16425)
      expect(@invoice_3.invoice_discount_amount).to eq(0)
      expect(@invoice_1.invoice_discount_amount).to_not eq(0)
    end

    it "displays total discount revenue for invoice" do
      expect(@invoice_1.total_revenue_after_discount).to eq(83420)
      expect(@invoice_2.total_revenue_after_discount).to eq(49275)
      expect(@invoice_3.total_revenue_after_discount).to eq(38000)
      expect(@invoice_1.total_revenue_after_discount).to_not eq(0)
    end
  end
end
