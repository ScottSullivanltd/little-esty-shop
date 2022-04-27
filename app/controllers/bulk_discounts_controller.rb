class BulkDiscountsController < ApplicationController
  before_action :find_merchant

  def index
    @bulk_discounts = @merchant.bulk_discounts.all
  end

  def show
    @bulk_discount = @merchant.bulk_discounts.find(params[:id])
  end

  def new
    @bulk_discount = BulkDiscount.new
  end

  def create
    @merchant.bulk_discounts.create(bulk_discount_params)
    redirect_to merchant_bulk_discounts_path(@merchant.id)
  end

  def edit
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def update
    @merchant.bulk_discounts.update(params[:id], bulk_discount_params)
    redirect_to merchant_bulk_discount_path(@merchant.id)
  end

  def destroy
    bulk_discount = BulkDiscount.find(params[:id])
    bulk_discount.destroy
    redirect_to merchant_bulk_discounts_path(@merchant.id)
  end

  private

  def bulk_discount_params
    params.permit(:percentage_discount, :quantity_threshold)
  end

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
