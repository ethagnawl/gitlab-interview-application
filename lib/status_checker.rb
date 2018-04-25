# frozen_string_literal: true

require "status_checker/version"
require "status_checker/http_client"
require "status_checker/logger"

module StatusChecker
  module_function

  def check!(http_client: StatusChecker::HttpClient,
             logger: StatusChecker::Logger.new(level: :error),
             requests: 6,
             request_buffer: 10,
             time: Time,
             url:)
    base_memo = { failed_requests: 0,
                  successful_requests: 0,
                  total_response_time: 0 }
    responses = Array(0...requests).inject(base_memo) do |memo, request_n|
      # This approach to determining response time is very basic and a better
      # approach _could_ be to use the Date header. However, that approach
      # assumes a lot about the contents and reliability of the Date header
      # value returned from the server.

      begin
        # To keep things simple and inline with the requirements, we want to
        # ensure no request uses up more than its allotted request_buffer.
        timeout = request_buffer - 1
        before = time.now
        response = http_client.execute(method: :get, timeout: timeout, url: url)
        after = time.now
        total = after - before
        wait = (Float(request_buffer) - total).clamp(0, request_buffer)

        logger.log.debug "request-#{request_n}: response was #{response}"
        logger.log.info "request-#{request_n}: response time was #{total}"
        percent_complete = (Float(request_n + 1) / Float(requests)).
                           round(2) * 100
        status_message = <<~MSG
          Process is #{percent_complete}% complete ...
        MSG
        logger.log.info "request-#{request_n}: #{status_message}"

        sleep wait

        memo[:total_response_time] += total
        memo[:successful_requests] += 1
        memo
      rescue http_client::RequestTimeout,
             http_client::RequestException => error
        logger.log.error error.message
        memo[:failed_requests] += 1
        memo
      end
    end

    # Note: this approach only takes "successful" response times into
    # consideration. You could make the case that "bad" response times
    # are also useful information, but that's a conversation for another day.
    if responses[:failed_requests] == requests
      average_response_time = nil
    else
      average_response_time = (responses[:total_response_time] / requests).
                              round(2)
    end

    {
      average_response_time: average_response_time,
      failed_requests: responses[:failed_requests],
      successful_requests: responses[:successful_requests]
    }
  end
end
