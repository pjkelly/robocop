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
      @app = app
      defaults = {
        :defaults => {
          :directives => %w(all)
        }
      }
      @options = defaults.merge(options)
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
      opts = options_for(headers['PATH_INFO'])
      headers['X-Robots-Tag'] = header_value_for(opts)
    end

    def options_for(path)
      if @options[:pages] && @options[:pages][path]
        @options[:pages][path]
      else
        @options[:defaults]
      end
    end

    def header_value_for(options)
      if options[:useragents]
        options[:useragents].collect { |useragent, directives| [useragent, valid_directives(directives).join(', ')].join(': ') }.join("\n")
      else options[:directives]
        valid_directives(options[:directives]).join(', ')
      end
    end

    def valid_directives(directives)
      directives.reject { |d| !VALID_DIRECTIVES.include?(d) }
    end
  end
end
