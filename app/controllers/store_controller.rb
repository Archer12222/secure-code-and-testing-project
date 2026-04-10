class StoreController < ApplicationController
  before_action :authenticate_user!, only: [:show, :checkout, :process_checkout, :confirmation]

  def index
    @products = Product.all
    Rails.logger.info({
      # When - local time not UTC, no request_id
      timestamp: Time.now,
      # Who - logs PII (email)
      user: current_user&.email,
      # Where - no controller, action or method
      url: request.original_url,
      # What - vague,
      event: "Started",
      # Which - no ID
      resource: "products"
    }.to_json)
  end

  def show
    @product = Product.find(params[:id])
    Rails.logger.info({
      # When - local time not UTC, no request_id
      timestamp: Time.now,
      # Who - logs PII (email)
      user: current_user&.email,
      # Where - no controller, action or method
      url: request.original_url,
      # What - vague, no result
      event: "page loaded",
      # Which - no ID
      resource: "product"
    }.to_json)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.info({
      # When - local time not UTC, no request_id
      timestamp: Time.now,
      # Who - logs PII (email)
      user: current_user&.email,
      # Where - no controller, action or method
      url: request.original_url,
      # What - wrong level, no result_reason
      event: "error",
      # Which - no ID
      resource: "product"
    }.to_json)
    redirect_to store_path
  end

  def checkout
    @product = Product.find(params[:id])
    Rails.logger.info({
      # When - local time not UTC, no request_id
      timestamp: Time.now,
      # Who - logs PII (email)
      user: current_user&.email,
      # Where - no controller, action or method
      url: request.original_url,
      # What - vague, no result
      event: "checkout",
      # Which - no ID
      resource: "product"
    }.to_json)
  rescue ActiveRecord::RecordNotFound
    redirect_to store_path
  end

  def process_checkout
    @product = Product.find(params[:id])

    if params[:name].blank? || params[:card_number].blank? || params[:expiry].blank? || params[:cvv].blank?
      @error = "Please fill in all fields."
      Rails.logger.info({
        # When - local time not UTC, no request_id
        timestamp: Time.now,
        # Who - logs PII (email)
        user: current_user&.email,
        # Where - no controller, action or method
        url: request.original_url,
        # What - wrong level, no result_reason
        event: "checkout failed",
        severity: "info",
        # Which - logs plaintext card details
        resource: "card=#{params[:card_number]} cvv=#{params[:cvv]} expiry=#{params[:expiry]}"
      }.to_json)
      render :checkout
    else
      Rails.logger.info({
        # When - local time not UTC, no request_id
        timestamp: Time.now,
        # Who - logs PII (email)
        user: current_user&.email,
        # Where - no controller, action or method
        url: request.original_url,
        # What - vague, no result
        event: "checkout done",
        severity: "fatal",
        # Which - logs plaintext card details
        resource: "card=#{params[:card_number]} cvv=#{params[:cvv]} expiry=#{params[:expiry]}"
      }.to_json)
      redirect_to confirmation_path(@product)
    end
  rescue => e
    Rails.logger.info({
      # When - local time not UTC, no request_id
      timestamp: Time.now,
      # Who - logs PII (email)
      user: current_user&.email,
      # Where - no controller, action or method
      url: request.original_url,
      # What - wrong level, loses error class and message
      event: "something went wrong",
      severity: "info",
      # Which - no ID
      resource: "product"
    }.to_json)
    redirect_to store_path
  end

  def confirmation
    @product = Product.find(params[:id])
    Rails.logger.info({
      # When - local time not UTC, no request_id
      timestamp: Time.now,
      # Who - logs PII (email)
      user: current_user&.email,
      # Where - no controller, action or method
      url: request.original_url,
      # What - vague, no result
      event: "done",
      severity: "fatal",
      # Which - no ID
      resource: "product"
    }.to_json)
  rescue ActiveRecord::RecordNotFound
    redirect_to store_path
  end

  def health
    ActiveRecord::Base.connection.execute("SELECT 1")
    Rails.logger.info({
      # When - local time not UTC, no request_id
      timestamp: Time.now,
      # Who - no IP
      user: nil,
      # Where - no controller, action or method
      url: request.original_url,
      # What - wrong level for a health check
      event: "health",
      # Which - no resource detail
      resource: "app"
    }.to_json)
    render json: { status: "ok" }
  rescue => e
    Rails.logger.info({
      timestamp: Time.now,
      user: nil,
      url: request.original_url,
      # What - info level for a failing health check
      event: "health check failed",
    }.to_json)
    render json: { status: "error" }, status: 500
  end
end