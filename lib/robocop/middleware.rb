require 'robocop/protocols'

module Robocop
  VALID_DIRECTIVES = [
    :all,
    :noindex,
    :nofollow,
    :none,
    :noarchive,
    :nosnippet,
    :noodp,
    :notranslate,
    :noimageindex
  ]

  class Middleware
    def initialize(app, &protocol_block)
      @app = app
      @protocols = Protocols.new
      @protocols.instance_eval(&protocol_block) if block_given?
    end

    def call(env)
      if skip?
        @app.call(env)
      else
        status, headers, body = @app.call(env)
        add_robots_tag_header!(headers)
        [status, headers, body]
      end
    end

    def skip?
      !protocols.pages? && !protocols.defaults?
    end

    def protocols
      @protocols
    end

    def add_robots_tag_header!(headers)
      headers['X-Robots-Tag'] = protocols.to_http_header(headers['PATH_INFO'])
    end
  end
end
