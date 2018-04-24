# frozen_string_literal: true

require "rest-client"

module StatusChecker
  module HttpClient
    module_function

    class RequestTimeout < StandardError; end

    def execute(url:, method:, timeout: 10)
      RestClient::Request.execute(method: method,
                                  timeout: timeout,
                                  url: url)
    rescue RestClient::Exceptions::Timeout => error
      raise HttpClient::RequestTimeout.new(error.message)
    end
  end
end
