# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "minitest/autorun"
require "minitest/unit"
require "mocha/minitest"
require "ostruct"
require "status_checker"

module FakeTime
  module_function

  def now; end
end

module FakeHttpClient
  module_function

  class RequestTimeout < StandardError; end
  class RequestException < StandardError; end

  def execute(*)
    OpenStruct.new(code: 200)
  end
end
