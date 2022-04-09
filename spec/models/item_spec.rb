require "rails_helper"

RSpec.describe Item, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:description)}
    it { should validate_numericality_of(:unit_price)}
    it { should define_enum_for(:enabled).with([
      :enabled, :disabled ])}
  end

  describe 'relationships' do
    it { should have_many(:invoice_items)}
    it { should have_many(:invoices).through(:invoice_items)}
    it { should belong_to(:merchant)}
  end
end
