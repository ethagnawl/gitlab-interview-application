# StatusChecker

## About
The status_checker gem allows users to check the status of a web site or
service.

status_checker will ping the provided URL 10 times, over the span of 60 seconds
and then report its findings using the form:

```
    {
      average_response_time: 0.2,
      failed_requests: 1,
      successful_requests: 9
    }
```

### Considerations
- The library currently drops response times for "bad" requests to the floor and
if no requests are successful, the average response time will be `nil`. It might
make sense for "bad" response times to be factored into the overall average
and/or create separate averages for "good"/"bad" response times.

- The library currently executes requests in serial. There is a timeout in
place and a dynamic value is used to pause the task between requests, but it
would be more foolproof to spawn a separate thread for each request. This way,
you could be _sure_  that the requests are executed exactly when they should
be (e.g. ten seconds apart) as there would be no chance of one requests
blocking another.

- Use Thor (or similar) to support command line options for number of requests,
the request buffer log levels, help text, etc.

- Use awesome_print (or similar) to add structure and style to output.

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'status_checker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install status_checker


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bundle exec rake test` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Status::Checker project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ethagnawl/status-checker/blob/master/CODE_OF_CONDUCT.md).
