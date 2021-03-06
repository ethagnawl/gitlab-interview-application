# frozen_string_literal: true

require "test_helper"

class StatusCheckerTest < Minitest::Test
  def setup
    StatusChecker.stubs(:sleep)
    @test_logger = StatusChecker::Logger.new(level: :fatal)
  end

  def test_that_it_has_a_version_number
    refute_nil ::StatusChecker::VERSION
  end

  def test_that_it_makes_at_least_one_request
    FakeHttpClient.
      expects(:execute).
      at_least_once.returns(OpenStruct.new(code: 200))
    StatusChecker::check(http_client: FakeHttpClient,
                         logger: @test_logger,
                         url: "https://gitlab.com")
  end

  def test_that_it_only_makes_n_requests
    requests = rand(10)
    FakeHttpClient.
      expects(:execute).
      at_most(requests).
      returns(OpenStruct.new(code: 200))
    StatusChecker::check(http_client: FakeHttpClient,
                         logger: @test_logger,
                         requests: requests,
                         url: "https://gitlab.com")
  end

  def test_that_it_reports_successful_requests
    FakeHttpClient.
      stubs(:execute).
      returns(OpenStruct.new(code: 200)).
      then.raises(FakeHttpClient::RequestException).
      then.returns(OpenStruct.new(code: 200)).
      then.raises(FakeHttpClient::RequestTimeout).
      then.returns(OpenStruct.new(code: 200)).
      then.raises(FakeHttpClient::RequestException)

    results = StatusChecker::check(http_client: FakeHttpClient,
                                   logger: @test_logger,
                                   url: "https://gitlab.com")
    expected = 3
    actual = results[:successful_requests]

    assert_equal(expected, actual)
  end

  def test_that_it_reports_failed_requests
    FakeHttpClient.
      stubs(:execute).
      returns(OpenStruct.new(code: 200)).
      then.returns(OpenStruct.new(code: 200)).
      then.returns(OpenStruct.new(code: 200)).
      then.raises(FakeHttpClient::RequestTimeout).
      then.returns(OpenStruct.new(code: 200)).
      then.raises(FakeHttpClient::RequestException).
      then.returns(OpenStruct.new(code: 200)).
      then.raises(FakeHttpClient::RequestTimeout).
      then.returns(OpenStruct.new(code: 200)).
      then.raises(FakeHttpClient::RequestException)

    results = StatusChecker::check(http_client: FakeHttpClient,
                                   logger: @test_logger,
                                   url: "https://gitlab.com")
    expected = 4
    actual = results[:failed_requests]

    assert_equal(expected, actual)
  end

  def test_that_it_averages_the_response_times
    average_of_stubbed_response_times = 3.8
    FakeTime.
      stubs(:now).
      returns(1, 5,
              1, 6,
              1, 2,
              1, 2,
              1, 9,
              1, 6,
              1, 7,
              1, 3,
              1, 6,
              1, 2)
    results = StatusChecker::check(http_client: FakeHttpClient,
                                   logger: @test_logger,
                                   time: FakeTime,
                                   url: "https://gitlab.com")
    expected = average_of_stubbed_response_times
    actual = results[:average_response_time]

    assert_equal(expected, actual)
  end

  def test_that_it_raises_an_exception_for_4xx_response_codes
    FakeHttpClient.
      stubs(:execute).
      returns(OpenStruct.new(code: 418))
    results = StatusChecker::check(http_client: FakeHttpClient,
                                   logger: @test_logger,
                                   requests: 1,
                                   time: FakeTime,
                                   url: "https://gitlab.com")

    expected = 1
    actual = results[:failed_requests]
    assert_equal(expected, actual)
  end

  def test_that_it_raises_an_exception_for_5xx_response_codes
    FakeHttpClient.
      stubs(:execute).
      returns(OpenStruct.new(code: 505))
    results = StatusChecker::check(http_client: FakeHttpClient,
                                   logger: @test_logger,
                                   requests: 1,
                                   time: FakeTime,
                                   url: "https://gitlab.com")

    expected = 1
    actual = results[:failed_requests]
    assert_equal(expected, actual)
  end

  def test_that_it_gets_a_nil_average_response_time_when_every_request_fails
    FakeHttpClient.
      stubs(:execute).
      raises(FakeHttpClient::RequestTimeout)
    results = StatusChecker::check(http_client: FakeHttpClient,
                                   logger: @test_logger,
                                   time: FakeTime,
                                   url: "https://gitlab.com")

    assert_nil results[:average_response_time]
  end

  def test_it_handles_request_timeouts_gracefully
    FakeHttpClient.
      stubs(:execute).
      raises(FakeHttpClient::RequestTimeout.new("fake request timeout"))
    StatusChecker::check(http_client: FakeHttpClient,
                         logger: @test_logger,
                         url: "https://gitlab.com")
  end

  def test_it_handles_request_exceptions_gracefully
    FakeHttpClient.
      stubs(:execute).
      raises(FakeHttpClient::RequestException.new("fake request exception"))
    StatusChecker::check(http_client: FakeHttpClient,
                         logger: @test_logger,
                         url: "https://gitlab.com")
  end
end
