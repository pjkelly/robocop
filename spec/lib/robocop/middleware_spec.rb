require 'spec_helper'

describe Robocop::Middleware do
  let(:fake_request) { lambda { |env| [200, Rack::MockRequest.env_for("/"), []] } }
  let(:middleware) { Robocop::Middleware.new(fake_request) }
  let(:mock_request) { Rack::MockRequest.new(middleware) }
  let(:response) { mock_request.get("/") }

  context "when no options are passed in" do
    it("should pass the request along") { response.status.should == 200 }
  end

  context "when useragents are passed in" do
    let(:valid_header_string) { "googlebot: noindex, nofollow, noarchive\notherbot: noodp\nnoindex, nofollow" }
    let(:middleware) {
      Robocop::Middleware.new(fake_request) do
        useragent :googlebot do
          directives :noindex, :nofollow, :noarchive
        end
        useragent :otherbot do
          directives :noodp
        end
        directives :noindex, :nofollow
      end
    }

    it "should return those useragents and their directives in the X-Robots-Tag header" do
      response.headers["X-Robots-Tag"].should == valid_header_string
    end
  end

  context "when directives are passed in" do
    let(:middleware) {
      Robocop::Middleware.new(fake_request) do
        directives :noindex, :nofollow
      end
    }

    it "should return those directives in the X-Robots-Tag header" do
      response.headers["X-Robots-Tag"].should == "noindex, nofollow"
    end
  end

  context "page specific rules" do
    let(:middleware) {
      Robocop::Middleware.new(fake_request) do
        directives :noindex, :nofollow
        page '/special-page' do
          directives :all
        end

        page %r{.*\.(jpg|gif|png)} do
          useragent :googlebot do
            directives :none, :noimageindex
          end
          directives :none
        end
      end
    }

    context "when the request doesn't match the specific page" do
      it "should return the default rules" do
        response.headers["X-Robots-Tag"].should == 'noindex, nofollow'
      end
    end

    context "when the request does match the specific page" do
      let(:fake_request) { lambda { |env| [200, Rack::MockRequest.env_for("/special-page"), []] } }

      it "should return the specific rules" do
        response.headers["X-Robots-Tag"].should == 'all'
      end
    end

    ['image.jpg', '/assets/header.png', '/hilarious/animated.gif'].each do |img|
      context "when the request does match the specific page" do
        let(:fake_request) { lambda { |env| [200, Rack::MockRequest.env_for(img), []] } }

        it "should return the specific rules" do
          response.headers["X-Robots-Tag"].should == "googlebot: none, noimageindex\nnone"
        end
      end
    end
  end
end
