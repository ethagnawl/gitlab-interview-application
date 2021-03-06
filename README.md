# StatusChecker

## About
The status_checker gem allows users to check the status of a web site or
service.

status_checker will ping the provided URL 10 times, over the span of 60 seconds
and then report its findings.

An example of its CLI usage is as follows:

```
$ status_checker https://gitlab.com
Status check is underway ...
Status check has been completed!

The results are as follows:
Average response time: 0.09s
Successful requests: 10
Failed requests: 0
```

### Considerations
Seeing as this is only the first round of the application process, I had a
limit on how many hours I was willing to sink into this exercise. There are
lots of features and niceties I would like to have included but that just
wasn't possible. I enumerate some of those features and some larger questions
about this tool and potential improvements below.

- The library currently only supports GETs but should be extended to cover
_any_ HTTP method the user may want to use.

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
request buffer, log levels, help text, etc.

- Use awesome_print (or similar) to add structure and style to output

- Logs should use structured logging so they can be easily parsed/integrated
with other tools. Also, perhaps each URL should have its own log?

- Logs should be toggleable and moved outside the repository and into an
appropriate directory on the host system. Also, consider supporting XDG.

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
`bundle exec rake test_suite` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Status::Checker project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ethagnawl/status-checker/blob/master/CODE_OF_CONDUCT.md).
