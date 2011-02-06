A URL shortener for Ruby
========================

Keeps track of shortened URLs using Base-62 encoding

Installation
============

1. Bundle install
2. Change the password in config/constants
3. Change the database info in config/database.yml
4. Startup app
ruby -rubygems config.ru

or using Shotgun (gem install shotgun):
shotgun config.ru -p 4567 # For Ruby 1.9.2, add -I.

Testing
=======

RACK_ENV=test rspec -I. .