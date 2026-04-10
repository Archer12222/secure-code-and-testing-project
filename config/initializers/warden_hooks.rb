Rails.application.config.after_initialize do
  Warden::Manager.after_authentication do |user, auth, opts|
    Rails.logger.info({
      # When - local time, no request_id
      timestamp: Time.now,
      # Who - logs email (PII) and plaintext password
      user: user.email,
      password: auth.env['action_dispatch.request.parameters']['user']['password'],
      # Where - just the URL
      url: auth.env["REQUEST_URI"],
      # What - vague
      event: "login",
      # Which - no ID
      resource: "user"
    }.to_json)
  end

  Warden::Manager.before_failure do |env, opts|
    Rails.logger.info({
      # When - local time, no request_id
      timestamp: Time.now,
      # Who - logs attempted email (PII)
      user: env['action_dispatch.request.parameters']['user']&.dig('email'),
      # Where - just the URL
      url: env["REQUEST_URI"],
      # What - wrong level, no result_reason
      event: "login failed",
      # Which - no ID
      resource: "user"
    }.to_json)
  end

  Warden::Manager.before_logout do |user, auth, opts|
    Rails.logger.info({
      # When - local time, no request_id
      timestamp: Time.now,
      # Who - logs email (PII)
      user: user&.email,
      # Where - just the URL
      url: auth.env["REQUEST_URI"],
      # What - vague
      event: "bye",
      severity: "fatal",
      # Which - no ID
      resource: "user"
    }.to_json)
  end
end