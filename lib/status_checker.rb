# frozen_string_literal: true

require "status_checker/version"
require "status_checker/http_client"
require "status_checker/logger"

MAX_REQUESTS = 6
REQUEST_BUFFER = 10

module StatusChecker
  module_function

  def check!(http_client: StatusChecker::HttpClient,
             logger: StatusChecker::Logger.new(level: :info),
             time: Time,
             url:)
    responses = Array(0...MAX_REQUESTS).inject([]) do |memo, request_n|
      # This approach to determining response time is very basic and a better
      # approach _could_ be to use the Date header. However, that approach
      # assumes a lot about the contents and reliability of the Date header
      # value returned from the server.

      begin
        # To keep things simple and inline with the requirements, we want to
        # ensure no request uses up more than its allotted REQUEST_BUFFER.
        timeout = REQUEST_BUFFER - 1
        before = time.now
        response = http_client.execute(method: :get, timeout: timeout, url: url)
        after = time.now
        total = after - before
        wait = (Float(REQUEST_BUFFER) - total).clamp(0, REQUEST_BUFFER)

        logger.log.info "request-#{request_n}: response was #{response}"
        logger.log.info "request-#{request_n}: response time was #{total}"
        status_message = <<~MSG
          checking is #{Float(request_n / Float(MAX_REQUESTS))}% complete ...
        MSG
        logger.log.info "request-#{request_n}: #{status_message}"

        sleep wait

        memo << { health: 100.0, response_time: total }
      rescue  http_client::RequestTimeout,
              http_client::RequestException => error
        logger.log.error error.message
        memo << { health: 0, response_time: nil }
      end
    end

    # Note: this approach only takes "successful" response times into
    # consideration. You could make the case that "bad" response times
    # are also useful, but that's a conversation for another day.
    average_response_time = responses.
                            map { |response| response[:response_time] }.
                            compact.
                            inject(0, &:+) / MAX_REQUESTS

    health = responses.
             map { |response| response[:health] }.
             inject(0, &:+) / MAX_REQUESTS

    {
      average_response_time: average_response_time,
      health: health
    }
  end
end
