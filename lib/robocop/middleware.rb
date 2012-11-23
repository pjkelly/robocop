module Robocop
  class Middleware
    VALID_DIRECTIVES = %w(
      all
      noindex
      nofollow
      none
      noarchive
      nosnippet
      noodp
      notranslate
      noimageindex
    )

    def initialize(app, options = {})
      @app, = app
      if options[:useragents]
        @useragents = options[:useragents]
      elsif options[:directives]
        @directives = options[:directives]
      else
        @ignore = true
      end
    end

    def call(env)
      if ignore?
        @app.call(env)
      else
        status, headers, body = @app.call(env)
        add_robots_tag_header!(headers)
        [status, headers, body]
      end
    end

    def ignore?
      @ignore
    end

    def add_robots_tag_header!(headers)
      if @useragents
        headers['X-Robots-Tag'] = @useragents.collect { |useragent, directives| [useragent, valid_directives(directives).join(', ')].join(': ') }.join("\n")
      else
        headers['X-Robots-Tag'] = valid_directives(@directives).join(', ')
      end
    end

    def valid_directives(directives)
      directives.reject { |d| !VALID_DIRECTIVES.include?(d) }
    end
  end
end
