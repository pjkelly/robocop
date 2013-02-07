module Robocop
  class XRobotHeader
    attr_reader :useragents, :directives

    def initialize(useragents, directives)
      @useragents = useragents
      @directives = directives
    end

    def to_s
      rules = self.useragents.collect(&:to_http_header)
      rules << self.directives.join(', ')
      rules.join("\n")
    end
  end

  class Protocols
    attr_reader :useragents, :directives, :pages

    def initialize
      @useragents = []
      @directives = []
      @pages = []
    end

    def defaults?
      !self.useragents.empty? || !self.directives.empty?
    end

    def pages?
      !self.pages.empty?
    end

    def to_http_header(path)
      if matching_page = self.pages.detect { |p| p.matches?(path) }
        matching_page.to_http_header
      else
        XRobotHeader.new(self.useragents, self.directives).to_s
      end
    end

    protected

    def useragent(name, &useragent_protocol_block)
      useragent = UserAgent.new(name)
      useragent.instance_eval(&useragent_protocol_block)
      @useragents << useragent
    end
    alias :ua :useragent

    def directives(*args)
      @directives += args.to_a
    end
    alias :directive :directives
    alias :d :directives

    def page(name, &page_protocol_block)
      page = Page.new(name)
      page.instance_eval(&page_protocol_block)
      @pages << page
    end
    alias :p :page
  end

  class UserAgent
    attr_reader :name, :directives

    def initialize(name)
      @name = name
      @directives = []
    end

    def to_http_header
      "#{self.name}: #{self.directives.join(', ')}"
    end

    protected

    def directives(*args)
      @directives += args.to_a
    end
    alias :directive :directives
    alias :d :directives
  end

  class Page
    attr_reader :path, :directives, :useragents

    def initialize(path)
      @path = path
      @useragents = []
      @directives = []
    end

    def to_http_header
      XRobotHeader.new(self.useragents, self.directives).to_s
    end

    def matches?(p)
      if path_is_a_regexp?
        self.path =~ p
      elsif self.path.is_a?(String)
        self.path == p
      else
        false
      end
    end

    protected

    def useragent(name, &useragent_protocol_block)
      useragent = UserAgent.new(name)
      useragent.instance_eval(&useragent_protocol_block)
      @useragents << useragent
    end
    alias :ua :useragent

    def directives(*args)
      @directives += args.to_a
    end
    alias :directive :directives
    alias :d :directives

    def path_is_a_regexp?
      self.path.is_a?(Regexp) || (Object.const_defined?(:Oniguruma) && self.path.is_a?(Oniguruma::ORegexp))
    end

  end
end
