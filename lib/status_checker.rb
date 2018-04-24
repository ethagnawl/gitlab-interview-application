# frozen_string_literal: true

require "benchmark"
require "byebug"
require "status_checker/version"
require "status_checker/http_client"

# TODO:
# - rescue net/http errors
# - convey health status (% !400/500 responses? named values?)

MAX_REQUESTS = 6
REQUEST_BUFFER = 10

module StatusChecker
  module_function

  def check!(http_client: StatusChecker::HttpClient,
             time: Time,
             timeout: 9,
             url:)
    response_times = Array(0...MAX_REQUESTS).inject([]) do |memo, request_n|
      begin
        before = time.now
        response = http_client.execute(method: :get,
                                       timeout: timeout,
                                       url: url)
        after = time.now
        total = after - before
        wait = ((Float(REQUEST_BUFFER) - total)).clamp(0, REQUEST_BUFFER)

        puts "request-#{request_n}: response = #{response.code}"
        puts "request-#{request_n}: logging response time of #{total}"
        puts "sleep for #{wait} seconds"

        sleep wait

        memo << total
      rescue http_client::RequestTimeout => error
        puts error.message
        memo
      end
    end

    response_times.inject(0, &:+) / MAX_REQUESTS
  end
end
