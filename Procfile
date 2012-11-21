grader: bundle exec shotgun --host 0.0.0.0 --port $PORT config.ru
test: bundle exec unicorn --config test_app/unicorn.rb test_app/config.ru
csrf: bundle exec shotgun --host 127.0.0.1 --port $PORT cors_app/config.ru
