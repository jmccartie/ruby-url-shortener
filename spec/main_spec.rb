require 'main'
require 'rack/test'
require 'factory_girl'
require "factories"
require "json"

set :environment, :test
RSpec.configure do |config|
  config.before(:each) { DataMapper.auto_migrate! }
end


describe 'App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def create_link(target = "http://google.com/")
    @target = target
    link = Factory.create(:link, :target => @target)
    @id = Base62.encode(link.id)
  end

  it "should properly encode base62" do
    'lYGhA16ahyf'.should eq(Base62.encode(18446744073709551615))
  end

  it "should properly decode base62" do
    '18446744073709551615'.should eq(Base62.decode('lYGhA16ahyf'))
  end

  it "creates a new link entry with a valid request" do
    lambda do
      get "create?url=http%3A%2F%2Fgoogle.com%2F&pw=#{PASSWORD}"
    end.should change(Link, :count).by(1)
  end

  it "should return JSON-encoded url by default" do
    get "create?url=http%3A%2F%2Fgoogle.com%2F&pw=#{PASSWORD}"
    expected = "{\"shortUrl\":\"http://example.org/1\"}"
    last_response.body.should eq(expected)
  end

  it "should return a callback if requested" do
    get "create?url=http%3A%2F%2Fgoogle.com%2F&pw=#{PASSWORD}&callback=true"
    expected = "short_callback({\"short_url\":\"http://example.org/1\"})"
    last_response.body.should eq(expected)
  end

  it "should return plain text if requested" do
    get "create?url=http%3A%2F%2Fgoogle.com%2F&pw=#{PASSWORD}&text=true"
    expected = "http://example.org/1"
    last_response.body.should eq(expected)
  end

  it "should redirect if a short url is requested" do
    create_link
    get "/#{@id}"
    follow_redirect!
    last_request.url.should eq(@target)
  end

  it "records a new view when a URL is requested" do
    lambda do
      create_link
      get "/#{@id}"
    end.should change(View, :count).by(1)
  end


end