class StoreController < ApplicationController

  before_action :authenticate_user!, only: [:show, :checkout, :process_checkout, :confirmation]

  def index
    @products = Product.all
    Rails.logger.info({
      # When
      timestamp: Time.now.utc,
      request_id: request.request_id,
      # Who
      user_id: current_user&.id,
      ip: request.remote_ip,
      # Where
      app: "RailsShop",
      controller: "store",
      action: "index",
      url: request.original_url,
      http_method: request.method,
      # What
      event: "store.index",
      severity: "info",
      result: "success",
      http_status: 200,
      # Which
      resource: "product",
      resource_count: @products.count
    }.to_json)
  end

  def show
    @product = Product.find(params[:id])
    Rails.logger.info({
      # When
      timestamp: Time.now.utc,
      request_id: request.request_id,
      # Who
      user_id: current_user&.id,
      ip: request.remote_ip,
      # Where
      app: "RailsShop",
      controller: "store",
      action: "show",
      url: request.original_url,
      http_method: request.method,
      # What
      event: "store.show",
      severity: "info",
      result: "success",
      http_status: 200,
      # Which
      resource: "product",
      resource_id: @product.id,
      resource_name: @product.name
    }.to_json)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn({
      # When
      timestamp: Time.now.utc,
      request_id: request.request_id,
      # Who
      user_id: current_user&.id,
      ip: request.remote_ip,
      # Where
      app: "RailsShop",
      controller: "store",
      action: "show",
      url: request.original_url,
      http_method: request.method,
      # What
      event: "store.show.not_found",
      severity: "warn",
      result: "fail",
      result_reason: "product not found in database",
      http_status: 404,
      # Which
      resource: "product",
      resource_id: params[:id]
    }.to_json)
    redirect_to store_path
  end

  def checkout
    @product = Product.find(params[:id])
    Rails.logger.info({
      # When
      timestamp: Time.now.utc,
      request_id: request.request_id,
      # Who
      user_id: current_user&.id,
      ip: request.remote_ip,
      # Where
      app: "RailsShop",
      controller: "store",
      action: "checkout",
      url: request.original_url,
      http_method: request.method,
      # What
      event: "store.checkout.view",
      severity: "info",
      result: "success",
      http_status: 200,
      # Which
      resource: "product",
      resource_id: @product.id,
      resource_name: @product.name
    }.to_json)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn({
      # When
      timestamp: Time.now.utc,
      request_id: request.request_id,
      # Who
      user_id: current_user&.id,
      ip: request.remote_ip,
      # Where
      app: "RailsShop",
      controller: "store",
      action: "checkout",
      url: request.original_url,
      http_method: request.method,
      # What
      event: "store.checkout.not_found",
      severity: "warn",
      result: "fail",
      result_reason: "product not found in database",
      http_status: 404,
      # Which
      resource: "product",
      resource_id: params[:id]
    }.to_json)
    redirect_to store_path
  end

  def process_checkout
    @product = Product.find(params[:id])

    if params[:name].blank? || params[:card_number].blank? || params[:expiry].blank? || params[:cvv].blank?
      @error = "Please fill in all fields."
      Rails.logger.warn({
        # When
        timestamp: Time.now.utc,
        request_id: request.request_id,
        # Who
        user_id: current_user&.id,
        ip: request.remote_ip,
        # Where
        app: "RailsShop",
        controller: "store",
        action: "process_checkout",
        url: request.original_url,
        http_method: request.method,
        # What
        event: "store.checkout.validation_failed",
        severity: "warn",
        result: "fail",
        result_reason: "missing required fields",
        http_status: 422,
        # Which
        resource: "product",
        resource_id: @product.id,
        resource_name: @product.name
      }.to_json)
      render :checkout
    else
      Rails.logger.info({
        # When
        timestamp: Time.now.utc,
        request_id: request.request_id,
        # Who
        user_id: current_user&.id,
        ip: request.remote_ip,
        # Where
        app: "RailsShop",
        controller: "store",
        action: "process_checkout",
        url: request.original_url,
        http_method: request.method,
        # What
        event: "store.checkout.success",
        severity: "info",
        result: "success",
        result_reason: "all fields valid",
        http_status: 303,
        # Which
        resource: "product",
        resource_id: @product.id,
        resource_name: @product.name
      }.to_json)
      redirect_to confirmation_path(@product)
    end
  rescue => e
    Rails.logger.error({
      # When
      timestamp: Time.now.utc,
      request_id: request.request_id,
      # Who
      user_id: current_user&.id,
      ip: request.remote_ip,
      # Where
      app: "RailsShop",
      controller: "store",
      action: "process_checkout",
      url: request.original_url,
      http_method: request.method,
      # What
      event: "store.checkout.error",
      severity: "error",
      result: "fail",
      result_reason: e.message,
      error_class: e.class.to_s,
      http_status: 500,
      # Which
      resource: "product",
      resource_id: params[:id]
    }.to_json)
    redirect_to store_path
  end

  def confirmation
    @product = Product.find(params[:id])
    Rails.logger.info({
      # When
      timestamp: Time.now.utc,
      request_id: request.request_id,
      # Who
      user_id: current_user&.id,
      ip: request.remote_ip,
      # Where
      app: "RailsShop",
      controller: "store",
      action: "confirmation",
      url: request.original_url,
      http_method: request.method,
      # What
      event: "store.confirmation.view",
      severity: "info",
      result: "success",
      http_status: 200,
      # Which
      resource: "product",
      resource_id: @product.id,
      resource_name: @product.name
    }.to_json)
  rescue ActiveRecord::RecordNotFound
    redirect_to store_path
  end

  def health
    ActiveRecord::Base.connection.execute("SELECT 1")
    Rails.logger.info({
      # When
      timestamp: Time.now.utc,
      request_id: request.request_id,
      # Who
      ip: request.remote_ip,
      # Where
      app: "RailsShop",
      controller: "store",
      action: "health",
      url: request.original_url,
      http_method: request.method,
      # What
      event: "health.check",
      severity: "info",
      result: "success",
      http_status: 200,
      # Which
      resource: "database",
      resource_name: "primary"
    }.to_json)
    render json: { status: "ok", timestamp: Time.now.utc }
  rescue => e
    Rails.logger.error({
      # When
      timestamp: Time.now.utc,
      request_id: request.request_id,
      # Who
      ip: request.remote_ip,
      # Where
      app: "RailsShop",
      controller: "store",
      action: "health",
      url: request.original_url,
      http_method: request.method,
      # What
      event: "health.check.failed",
      severity: "error",
      result: "fail",
      result_reason: e.message,
      http_status: 500,
      # Which
      resource: "database",
      resource_name: "primary"
    }.to_json)
    render json: { status: "error" }, status: 500
  end

end