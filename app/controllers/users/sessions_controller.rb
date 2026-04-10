class Users::SessionsController < Devise::SessionsController
  def new
    Rails.logger.info({
      # When
      timestamp: Time.now.utc,
      request_id: request.request_id,
      # Who
      ip: request.remote_ip,
      # Where
      app: "RailsShop",
      controller: "users/sessions",
      action: "new",
      url: request.original_url,
      http_method: request.method,
      # What
      event: "user.login.page.view",
      severity: "info",
      result: "success",
      http_status: 200,
      # Which
      resource: "session"
    }.to_json)
    super
  end
end