require 'spec_helper'

describe Robocop::Middleware do
  let(:fake_request) { lambda { |env| [200, Rack::MockRequest.env_for("/"), []] } }
  let(:middleware) { Robocop::Middleware.new(fake_request) }
  let(:mock_request) { Rack::MockRequest.new(middleware) }
  let(:response) { mock_request.get("/") }
  let(:valid_directives) { %w(noindex nofollow) }
  let(:invalid_directives) { %w(dogs cats) }

  context "when no options are passed in" do
    it("should pass the request along") { response.status.should == 200 }
  end

  context "when useragents are passed in" do
    let(:useragents) {
      {
        :googlebot => %w(noindex nofollow),
        :otherbot => %w(noindex nofollow)
      }
    }
    let(:valid_header_string) { "googlebot: noindex, nofollow\notherbot: noindex, nofollow" }
    let(:middleware) {
      Robocop::Middleware.new(fake_request, :defaults => {
                                              :useragents => useragents
                                            })
    }

    it "should return those useragents and their directives in the X-Robots-Tag header" do
      response.headers["X-Robots-Tag"].should == valid_header_string
    end

    context "and some of their directives are invalid" do
      let(:useragents) {
        {
          :googlebot => (valid_directives + invalid_directives),
          :otherbot => (valid_directives + invalid_directives)
        }
      }

      it "should return only valid directives for each of the useragents in the X-Robots-Tag header" do
        response.headers["X-Robots-Tag"].should == valid_header_string
      end
    end
  end

  context "when directives are passed in" do
    let(:directives) { %w(noindex nofollow) }
    let(:middleware) {
      Robocop::Middleware.new(fake_request, :defaults => {
                                              :directives => directives
                                            })
    }

    it "should return those directives in the X-Robots-Tag header" do
      response.headers["X-Robots-Tag"].should == directives.join(', ')
    end

    context "and some of the directives are invalid" do
      let(:directives) { (valid_directives + invalid_directives) }

      it "should return only valid directives in the X-Robots-Tag header" do
        response.headers["X-Robots-Tag"].should == valid_directives.join(', ')
      end
    end
  end

  context "page specific rules" do
    let(:middleware) {
      Robocop::Middleware.new(fake_request, :defaults => {
                                              :directives => %w(noindex nofollow)
                                            },
                                            :pages => {
                                              '/special-page' => {
                                                :directives => %w(all)
                                              }
                                            })
    }

    context "when the request doesn't match the specific page" do
      it "should return the default rules" do
        response.headers["X-Robots-Tag"].should == %w(noindex nofollow).join(', ')
      end
    end

    context "when the request does match the specific page" do
      let(:fake_request) { lambda { |env| [200, Rack::MockRequest.env_for("/special-page"), []] } }

      it "should return the specific rules" do
        response.headers["X-Robots-Tag"].should == %w(all).join(', ')
      end
    end
  end
end

