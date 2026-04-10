Rails.application.config.after_initialize do
  Warden::Manager.after_authentication do |user, auth, opts|
    Rails.logger.info({
      # When
      timestamp: Time.now.utc,
      # Who
      user_id: user.id,
      ip: auth.env["REMOTE_ADDR"],
      # Where
      app: "RailsShop",
      url: auth.env["REQUEST_URI"],
      http_method: auth.env["REQUEST_METHOD"],
      # What
      event: "user.login.success",
      severity: "info",
      result: "success",
      result_reason: "user authenticated",
      http_status: 303,
      # Which
      resource: "user",
      resource_id: user.id
    }.to_json)
  end

  Warden::Manager.before_failure do |env, opts|
    Rails.logger.warn({
      # When
      timestamp: Time.now.utc,
      # Who
      ip: env["REMOTE_ADDR"],
      # Where
      app: "RailsShop",
      url: env["REQUEST_URI"],
      http_method: env["REQUEST_METHOD"],
      # What
      event: "user.login.failed",
      severity: "warn",
      result: "fail",
      result_reason: opts[:message].to_s,
      http_status: 401,
      # Which
      resource: "user"
    }.to_json)
  end

  Warden::Manager.before_logout do |user, auth, opts|
    Rails.logger.info({
      # When
      timestamp: Time.now.utc,
      # Who
      user_id: user&.id,
      ip: auth.env["REMOTE_ADDR"],
      # Where
      app: "RailsShop",
      url: auth.env["REQUEST_URI"],
      http_method: auth.env["REQUEST_METHOD"],
      # What
      event: "user.logout",
      severity: "info",
      result: "success",
      http_status: 303,
      # Which
      resource: "user",
      resource_id: user&.id
    }.to_json)
  end
end