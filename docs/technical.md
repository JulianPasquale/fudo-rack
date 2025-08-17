# Technical documentation

This file intends to document the architectural decisions made in the app and explain why it's implemented this way.

## Web server setup
The app is configured to use the Puma web server. Since products and users data is stored in memory, Puma will only spin up one worker but with multiple threads.
Workers are separate processes and they do not share memory spaces, so if we had multiple workers it could happen for instance that you create a product and then try to get the products list, but the one you created is not included there because the second request was not handled by the same worker that attended the first one. Of course this doesn't scale and is very bad, but to fix it we should store the data somewhere else first.

## Routing
The paths and routing to controllers is implemented using `Rack::Builder` and `Rack::URLMap`. Would be nice to have some extra layers (or maybe just use a gem or a few pieces from Rails) to have a better mapping solution that has built-in support for urls like `products/:id` without needing regular expressions, but I wanted to keep it simple.

## Async processing
To be able to create the product asynchronously, the app uses the [Concurrent::ScheduledTask](https://ruby-concurrency.github.io/concurrent-ruby/master/Concurrent/ScheduledTask.html) class from the [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) gem, a very solid and used solution (even Rails uses this internally).

## Thread safety
In Ruby, classes like `Array` and [Hash](https://bugs.ruby-lang.org/issues/19237#note-2) are not thread-safe. This means that read/write operations can result in inconsistent status when called for the same instance from different threads.

The section above talks about concurrent-ruby and how this app runs concurrent operations, but this gems does not completely solve the issue. It does provide some classes like `Concurrent::Hash.new` that are meant to be "thread-safe" implementations of the Ruby classes, but in some scenarios this is not [completely true](https://github.com/ruby-concurrency/concurrent-ruby/issues/929).

## Data storage
Since we want to keep users and products in memory, The `ProductStore` and `UserStore` classes implement the Singleton pattern so we can access the same instance everywhere within the app. Since the app only allows to create products, there is a service object that adds the products to the store and implements the asynchronous logic.

## Auth strategies
The auth endpoints implement a JWT based authentication. The code actually has a generic `BaseStrategy` class that acts as an interface for any kind of strategy that we want to implement. To keep it simple I only implemented the JWT strategy, but extending this would be super simple.
Strategies are being passed to the `AuthService` and middleware using dependency injection, so no major code changes would be needed to add/replace auth strategies.

## Rubocop
The app includes the rubocop gem to make sure it follows some good practices. I disabled two cops because I don't think they are relevant or add any value, but it's just a personal opinion.

## Autoloading
The app uses the zeitwerk gem to automatically require all the files and classes. The setup is done in the `config/boot.rb` file.

## Continuous Integration
The CI process will use Github Actions to run 3 jobs in parallel:
- Tests: This job runs the RSpec tests.
- Lint: This job runs rubocop linter.
- Docker: This job build the Dockerfile to make sure it generates a valid Docker image.
- openapi-validation: Use the `redocly` CLI to validate the openapi spec.

## Extras and improvement
Some other ideas or improvements that can be added to this application to improve performance:
- Add pagination to products endpoint. If the list is too big, pagination is a **must have**
- Add a reverse-proxy or external server to handle static files. There is no need to use a thread from the web server to serve static files (sometimes), so that could help to reduce some load.
- Add a database and background job worker. This has been partially implemented in the branch `database-and-sidekiq`, just to show how we can improve the setup to be more scalable. Having a database will allow to increase the Puma workers count, and also Sidekiq can be scaled separately so if the have heavy load, we can just scale it up.
