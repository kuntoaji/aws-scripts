require 'active_support'
require 'active_support/time'
require 'json'
require_relative 'secret-manager-rotator'

# Script to run the secret manager rotator
# Run bundle install to install dependencies
#
# Usage: ruby rotator-runner.rb <secret_name>
# Example: ruby rotator-runner.rb my-secret

secret_id = ARGV.first
puts "Rotating secret #{secret_id}"
secret_manager_rotator = SecretManagerRotator.new secret_id

puts 'Current secret:'
secret_manager_rotator.get_secret_string

# format expired_at as yyyy-mm-dd
expired_at = 3.months.from_now.strftime('%Y-%m-%d')
new_secret_string = {"Salt":"hello-world-#{Time.now}","ExpiredAt":expired_at}.to_json

puts 'Updating secret with new secret string:'
puts new_secret_string
secret_manager_rotator.update_with_new_secret new_secret_string

# Testing new secret
puts 'Testing new secret AWSCURRENT'
secret_manager_rotator.get_secret_string

puts 'Testing new secret AWSPREVIOUS'
secret_manager_rotator.get_secret_string 'AWSPREVIOUS'
