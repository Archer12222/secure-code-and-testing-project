class StoreController < ApplicationController
  def index
    @products = Product.all
    Rails.logger.info({
      event: "store.index",
      product_count: @products.count,
      user_id: current_user&.id,
      request_id: request.request_id,
      timestamp: Time.now.utc
    }.to_json)
    render :index
  end

  def show
    @product = Product.find(params[:id])
    Rails.logger.info({
      event: "store.show",
      product_id: @product.id,
      user_id: current_user&.id,
      request_id: request.request_id,
      timestamp: Time.now.utc
    }.to_json)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn({
      event: "store.show.not_found",
      product_id: params[:id],
      user_id: current_user&.id,
      timestamp: Time.now.utc
    }.to_json)
    redirect_to store_path
    render :show
  end

  def checkout
    @product = Product.find(params[:id])
    Rails.logger.info({
      event: "store.checkout.view",
      product_id: @product.id,
      user_id: current_user&.id,
      request_id: request.request_id,
      timestamp: Time.now.utc
    }.to_json)
  rescue ActiveRecord::RecordNotFound
    redirect_to store_path
  end

  def process_checkout
    @product = Product.find(params[:id])

    if params[:name].blank? || params[:card_number].blank? || params[:expiry].blank? || params[:cvv].blank?
      @error = "Please fill in all fields."
      Rails.logger.warn({
        event: "store.checkout.validation_failed",
        product_id: @product.id,
        user_id: current_user&.id,
        timestamp: Time.now.utc
      }.to_json)
      render :checkout
    else
      Rails.logger.info({
        event: "store.checkout.success",
        product_id: @product.id,
        user_id: current_user&.id,
        request_id: request.request_id,
        timestamp: Time.now.utc
      }.to_json)
      redirect_to confirmation_path(@product)
    end
  rescue => e
    Rails.logger.error({
      event: "store.checkout.error",
      error: e.class.to_s,
      message: e.message,
      product_id: params[:id],
      user_id: current_user&.id,
      timestamp: Time.now.utc
    }.to_json)
    redirect_to store_path
  end

  def confirmation
    @product = Product.find(params[:id])
    Rails.logger.info({
      event: "store.confirmation.view",
      product_id: @product.id,
      user_id: current_user&.id,
      timestamp: Time.now.utc
    }.to_json)
  rescue ActiveRecord::RecordNotFound
    redirect_to store_path
  end

  def health
    ActiveRecord::Base.connection.execute("SELECT 1")
    Rails.logger.info({ event: "health.check", status: "ok", timestamp: Time.now.utc }.to_json)
    render json: { status: "ok", timestamp: Time.now.utc }
  rescue => e
    Rails.logger.error({ event: "health.check.failed", error: e.message, timestamp: Time.now.utc }.to_json)
    render json: { status: "error" }, status: 500
  end
end