require_relative '../main'
require 'rack/test'
require 'factory_bot'
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

  before(:all) do
    ENV['PASSWORD'] = "please"
  end

  def create_link(target = "http://google.com/")
    @target = target
    link = FactoryBot.create(:link, :target => @target)
    @id = Base62.encode(link.id)
  end

  it "should properly encode base62" do
    expect(Base62.encode(18446744073709551615)).to eq 'lYGhA16ahyf'
  end

  it "should properly decode base62" do
    expect(Base62.decode('lYGhA16ahyf')).to eq '18446744073709551615'
  end

  it "creates a new link entry with a valid request" do
    expect {
      get "create?url=http%3A%2F%2Fgoogle.com%2F&pw=please"
    }.to change(Link, :count).by(1)
  end

  it "should return JSON-encoded url by default" do
    get "create?url=http%3A%2F%2Fgoogle.com%2F&pw=please"
    expected = "{\"shortUrl\":\"http://example.org/1\"}"
    expect(expected).to eq(last_response.body)
  end

  it "should return a callback if requested" do
    get "create?url=http%3A%2F%2Fgoogle.com%2F&pw=please&callback=true"
    expected = "short_callback({\"short_url\":\"http://example.org/1\"})"
    expect(expected).to eq last_response.body
  end

  it "should return plain text if requested" do
    get "create?url=http%3A%2F%2Fgoogle.com%2F&pw=please&text=true"
    expected = "http://example.org/1"
    expect(expected).to eq last_response.body
  end

  it "should redirect if a short url is requested" do
    create_link
    get "/#{@id}"
    follow_redirect!
    expect(@target).to eq last_request.url
  end

  it "records a new view when a URL is requested" do
    expect {
      create_link
      get "/#{@id}"
    }.to change(View, :count).by(1)
  end


end