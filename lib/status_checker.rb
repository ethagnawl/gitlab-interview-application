# frozen_string_literal: true

require "benchmark"
require "byebug"
require "net/http"
require "status_checker/version"
require "rest-client"

#TODO:
# - timeout
# - rescue net/http errors
# - convey health status (% !400/500 responses? named values?)

MAX_REQUESTS = 6
REQUEST_BUFFER = 10

module StatusChecker
  module_function

  def check!(http_client: RestClient::Request,
             time: Time,
             url:)
    response_times = Array(0...MAX_REQUESTS).map do |request_n|
        before = time.now
        response = http_client.execute(method: :get,
                                       timeout: 10,
                                       url: url)
        after = time.now
        total = after - before
        wait = ((Float(REQUEST_BUFFER) - total)).clamp(0, 10)

        puts "request-#{request_n}: response = #{response.inspect}"
        puts "request-#{request_n}: logging response time of #{total}"
        puts "sleep for #{wait} seconds"

        sleep wait

        total
    end

    response_times.reduce(0, &:+) / MAX_REQUESTS
  end
end
