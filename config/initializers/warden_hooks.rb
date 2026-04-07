Rails.application.config.after_initialize do
  Warden::Manager.after_authentication do |user, auth, opts|
    Rails.logger.info({ 
      event: "user.login.success",
      user_id: user.id,
      ip: auth.env["REMOTE_ADDR"],
      timestamp: Time.now.utc
    }.to_json)
  end

  Warden::Manager.before_failure do |env, opts|
    Rails.logger.warn({ 
      event: "user.login.failed",
      reason: opts[:message],
      ip: env["REMOTE_ADDR"],
      timestamp: Time.now.utc
    }.to_json)
  end

  Warden::Manager.before_logout do |user, auth, opts|
    Rails.logger.info({
      event: "user.logout",
      user_id: user&.id,
      ip: auth.env["REMOTE_ADDR"],
      timestamp: Time.now.utc
    }.to_json)
  end
end