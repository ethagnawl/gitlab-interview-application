# frozen_string_literal: true

require "test_helper"

module FakeTime
  module_function

  def now; end
end

module FakeHttpClient
  module_function

  class RequestTimeout < StandardError; end

  def execute(*)
    OpenStruct.new(code: 200)
  end
end

class StatusCheckerTest < Minitest::Test
  def setup
    StatusChecker.stubs(:sleep)
  end

  def test_that_it_has_a_version_number
    refute_nil ::StatusChecker::VERSION
  end

  def test_that_it_makes_at_least_one_request
    FakeHttpClient.
      expects(:execute).
      at_least_once.returns(OpenStruct.new(code: 200))
    StatusChecker::check!(http_client: FakeHttpClient,
                          url: "https://gitlab.com")
  end

  def test_that_it_only_makes_six_requests
    FakeHttpClient.
      expects(:execute).
      at_most(6).
      returns(OpenStruct.new(code: 200))
    StatusChecker::check!(http_client: FakeHttpClient,
                          url: "https://gitlab.com")
  end

  def test_that_it_averages_the_response_times
    average_of_stubbed_response_times = 11
    FakeTime.
      stubs(:now).
      returns(1, 7,
              1, 11,
              1, 5,
              1, 42,
              1, 6,
              1, 2)
    average_response_time = StatusChecker::check!(http_client: FakeHttpClient,
                                                  time: FakeTime,
                                                  url: "https://gitlab.com")
    expected = average_of_stubbed_response_times
    actual = average_response_time

    assert_equal(expected, actual)
  end

  def test_it_handles_request_timeouts_gracefully
    FakeHttpClient.
      stubs(:execute).
      raises(FakeHttpClient::RequestTimeout.new("fake request timeout"))
    StatusChecker::check!(http_client: FakeHttpClient,
                          url: "https://gitlab.com")
  end
end
