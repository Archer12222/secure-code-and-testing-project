class Users::SessionsController < Devise::SessionsController
  def new
    Rails.logger.info({
      # When - local time, no request_id
      timestamp: Time.now,
      # Who - no IP
      user: nil,
      # Where - just the URL
      url: request.original_url,
      # What - vague, wrong level
      event: "login page",
      # Which - no ID
      resource: "session"
    }.to_json)
    super
  end
end