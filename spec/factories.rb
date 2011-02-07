Factory.define :link do |f|
  f.target "http://google.com"
  f.created_at Time.now
end

Factory.define :view do |f|
  f.link_id 1
  f.user_agent "foo"
  f.ip "127.0.0.1"
  f.created_at Time.now
end