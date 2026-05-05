class Rack::Attack
  throttle("login", limit: 5, period: 60) do |req|
    req.ip if req.path == "/api/v1/auth/login" && req.post?
  end

  throttle("register", limit: 3, period: 3600) do |req|
    req.ip if req.path == "/api/v1/auth/register" && req.post?
  end

  throttle("general", limit: 100, period: 60) do |req|
    req.ip
  end

  self.throttled_responder = lambda do |req|
    match_data = req.env["rack.attack.match_data"]
    now        = match_data[:epoch_time]
    retry_after = match_data[:period] - (now % match_data[:period])

    [
      429,
      {
        "Content-Type"  => "application/json",
        "Retry-After"   => retry_after.to_s
      },
      [{ error: "demasiados pedidos — tenta novamente em #{retry_after} segundos" }.to_json]
    ]
  end
end