require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'

Capybara.run_server = false
Capybara.app_host = 'http://www.google.com'
