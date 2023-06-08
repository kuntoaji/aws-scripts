require_relative 'secret-manager-rotator'

secret_id = 'ExampleSecret'
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
