# frozen_string_literal: true

require "rest-client"

module StatusChecker
  module HttpClient
    module_function

    class RequestException < RestClient::Exception; end
    class RequestTimeout < RestClient::Exceptions::Timeout; end

    def execute(url:, method:, timeout: 10)
      RestClient::Request.execute(method: method,
                                  timeout: timeout,
                                  url: url)
    rescue RestClient::Exception,
           RestClient::Exceptions::Timeout => error
      raise RequestTimeout.new(error.message)
    end
  end
end
