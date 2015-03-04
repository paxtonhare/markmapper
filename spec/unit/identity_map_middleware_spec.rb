require 'spec_helper'
require 'rack/test'

module IdentityMapSpec
  describe "IdentityMapMiddleware" do
    include Rack::Test::Methods

    def app
      @app ||= Rack::Builder.new do
        use MarkMapper::Middleware::IdentityMap

        map "/" do
          run lambda {|env| [200, {}, []] }
        end

        map "/fail" do
          run lambda {|env| raise "FAIL!" }
        end
      end.to_app
    end

    context "" do
      before do
        @enabled = MarkMapper::Plugins::IdentityMap.enabled
        MarkMapper::Plugins::IdentityMap.enabled = false
      end

      after do
        MarkMapper::Plugins::IdentityMap.enabled = @enabled
      end

      it "should delegate" do
        called = false
        mw = MarkMapper::Middleware::IdentityMap.new lambda { |env|
          called = true
          [200, {}, nil]
        }
        mw.call({})
        called.should be_truthy
      end

      it "should enable identity map during delegation" do
        mw = MarkMapper::Middleware::IdentityMap.new lambda { |env|
          MarkMapper::Plugins::IdentityMap.should be_enabled
          [200, {}, nil]
        }
        mw.call({})
      end

      class Enum < Struct.new(:iter)
        def each(&b)
          iter.call(&b)
        end
      end

      it "should enable IM for body each" do
        mw = MarkMapper::Middleware::IdentityMap.new lambda { |env|
          [200, {}, Enum.new(lambda { |&b|
            MarkMapper::Plugins::IdentityMap.should be_enabled
            b.call "hello"
          })]
        }
        body = mw.call({}).last
        body.each { |x| x.should eql('hello') }
      end

      it "should disable IM after body close" do
        mw = MarkMapper::Middleware::IdentityMap.new lambda { |env| [200, {}, []] }
        body = mw.call({}).last
        MarkMapper::Plugins::IdentityMap.should be_enabled
        body.close
        MarkMapper::Plugins::IdentityMap.should_not be_enabled
      end

      it "should clear IM after body close" do
        mw = MarkMapper::Middleware::IdentityMap.new lambda { |env| [200, {}, []] }
        body = mw.call({}).last

        MarkMapper::Plugins::IdentityMap.repository['hello'] = 'world'
        MarkMapper::Plugins::IdentityMap.repository.should_not be_empty

        body.close

        MarkMapper::Plugins::IdentityMap.repository.should be_empty
      end

      context "with a successful request" do
        it "should clear the identity map" do
          expect(MarkMapper::Plugins::IdentityMap).to receive(:clear).twice
          get '/'
        end
      end

      context "when the request raises an error" do
        it "should clear the identity map" do
          expect(MarkMapper::Plugins::IdentityMap).to receive(:clear).once
          get '/fail' rescue nil
        end
      end
    end
  end

  # describe "IdentityMapMiddleware" do
  #   include Rack::Test::Methods

  #   def app
  #     @app ||= Rack::Builder.new do
  #       use MarkMapper::Middleware::IdentityMap
  #       map "/" do
  #         run lambda {|env| [200, {}, []] }
  #       end
  #       map "/fail" do
  #         run lambda {|env| raise "FAIL!" }
  #       end
  #     end.to_app
  #   end

  #   context "with a successful request" do
  #     it "should clear the identity map" do
  #       expect(MarkMapper::Plugins::IdentityMap).to receive(:clear).twice
  #       get '/'
  #     end
  #   end

  #   context "when the request raises an error" do
  #     it "should clear the identity map" do
  #       expect(MarkMapper::Plugins::IdentityMap).to receive(:clear).twice
  #       get '/fail' rescue nil
  #     end
  #   end


  # end
end
