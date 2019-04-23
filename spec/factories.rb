FactoryBot.define do
  factory :link do
    target {"http://google.com"}
    created_at {Time.now}
  end
end

FactoryBot.define do
  factory :view do
    link_id {1}
    user_agent {"foo"}
    ip {"127.0.0.1"}
    created_at {Time.now}
  end
end