# Robocop [![Build Status](https://secure.travis-ci.org/pjkelly/robocop.png?branch=master)](http://travis-ci.org/pjkelly/robocop)

Robocop is a simple Rack middleware that inserts the `X-Robots-Tag` into the headers of all your responses.

The `X-Robots-Tag` can be used in place of a `robots.txt` file or meta tags to tell crawlers what they're allowed to do with your content. See [this article](https://developers.google.com/webmasters/control-crawl-index/docs/robots_meta_tag) for more information.

Tested against Ruby 1.8.7, 1.9.2, 1.9.3, and Rubinius & JRuby in both 1.8 and 1.9 mode.

## Installation

The simplest way to install Robocop is to use [Bundler](http://gembundler.com/).

Add Robocop to your `Gemfile`:

``` ruby
gem 'robocop'
```

## Basic Usage

### Rails

To use Robocop in your Rails application, add the following line to your application config file (`config/application.rb` for Rails 3, `config/environment.rb` for Rails 2):

``` ruby
config.middleware.use Robocop::Middleware, :directives => %w(all)
```

### Other Rack Applications (Sinatra, Padrino, etc.)

Simple add the following to your `config.ru`:

``` ruby
use Robocop::Middleware, :directives => %w(all)
```

## Options

The following directives can be passed in to Robocop's configuration:

* all
* noindex
* nofollow
* none
* noarchive
* nosnippet
* noodp
* notranslate
* noimageindex

### Directives (useragent agnostic)

If you just want to specify a list of directives for all useragents to follow, simply pass in an array of directives with the `:directive` option:

``` ruby
config.middleware.use Robocop::Middleware, :directives => %w(noindex nofollow)
```

### Useragents

If you want to give specific user agents unique sets of directives, you can do so by passing in the `:useragent` option:

``` ruby
config.middleware.use Robocop::Middleware, :useragents => {
  :googlebot => %w(noindex nofollow, noimageindex),
  :otherbot => %w(none)
}
```

It should be noted that if both the `:useragents` and `:directives` options are passed in, the `:useragents` option takes precedence.

## TODO

* Add support for `unavailable_after` directive.
* Sanity checks for directives that are passed in. e.g. passing all, noindex, nofollow doesn't make any sense.

## Note on Patches / Pull Requests

* Fork the project.
* Code your feature addition or bug fix.
* **Add specs for it.** This is important so we don't break it in a future version unintentionally.
* Commit, do not mess with Rakefile or version number. If you want to have your own version, that's fine but bump version in a commit by itself so we can ignore it when merging.
* Send a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2012 PJ Kelly. See LICENSE for details.