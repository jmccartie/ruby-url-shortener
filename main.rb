require 'rubygems'
require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'base62'
require 'json'
require 'config/constants'

# DATABASE SETUP
hash = YAML.load(File.open("config/database.yml"))
DataMapper.setup(:default, hash[ENV['RACK_ENV']])


class Link
  include DataMapper::Resource
  has n, :views

  property :id,    Serial
  property :target, String
  property :created_at, DateTime
end

class View
  include DataMapper::Resource
  belongs_to :link

  property :id, Serial
  property :link_id, Integer
  property :user_ip, String
  property :user_agent, Text
  property :created_at, DateTime
end

# DataMapper.auto_migrate!
DataMapper.auto_upgrade!


# APPLICATION
get "/" do
  content_type :json
  { :key1 => 'value1', :key2 => 'value2' }.to_json
end

get '/create' do
  content_type :json
  return 400, { "error" => 'Url Missing' }.to_json unless params[:url]
  return 401, { "error" => "Wrong password"}.to_json unless params[:pw] == PASSWORD

  @link = Link.create(
    :target => params[:url],
    :created_at => Time.now
  )
  link = "#{request.scheme}://#{request.host}/#{@link.id}"

  if params[:callback] == "true"
    "short_callback({\"short_url\":\"#{link}\"})"
  elsif params[:text]
    # Plain Text - TinyURL style
    content_type :text
    link
  else
    # JSON - bit.ly style
    {"shortUrl" => link}.to_json
  end
end

get '/:id' do |id|
  link_id = Base62.decode(id)

  # Record view
  View.create(
    :link_id => link_id,
    :user_ip => request.ip,
    :user_agent => request.user_agent,
    :created_at => Time.now
  )

  # Redirect
  @link = Link.get(link_id)
  redirect @link.target
end

get '/views' do
  "View reports will go here"
end

