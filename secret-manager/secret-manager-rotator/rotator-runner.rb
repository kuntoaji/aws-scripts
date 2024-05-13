require 'active_support'
require 'active_support/time'
require 'json'
require_relative 'secret-manager-rotator'

# Script to run the secret manager rotator
# Run bundle install to install dependencies
#
# Usage: ruby rotator-runner.rb <secret_id>
# Example: ruby rotator-runner.rb my-secret

secret_id = ARGV.first
puts "Rotating secret #{secret_id}"
secret_manager_rotator = SecretManagerRotator.new secret_id

puts 'Creating secret'
secret_manager_rotator.create_secret

puts 'Setting secret'
secret_manager_rotator.set_secret

puts 'Testing secret'
secret_manager_rotator.test_secret

puts 'Finishing secret'
secret_manager_rotator.finish_secret
