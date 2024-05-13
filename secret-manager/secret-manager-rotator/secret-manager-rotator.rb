require 'aws-sdk-secretsmanager'

# TODO: add version stage validation

class SecretManagerRotator
  def initialize(secret_id)
    @secret_id = secret_id
    @client = Aws::SecretsManager::Client.new
    @aws_current_version_id = nil
    @aws_pending_version_id = nil
  end

  # This method first checks for the existence of a secret for the passed in token.
  # If one does not exist, it will generate a new secret and put it with the passed in token.
  def create_secret
    # make sure the secret exists
    puts 'Checking if secret exists'
    response = @client.get_secret_value({
      secret_id: @secret_id,
      version_stage: 'AWSCURRENT'
    })

    puts response.secret_string
    @aws_current_version_id = response.version_id

    return if response.secret_string

    # Now try to get the secret version, if that fails, put a new secret
    begin
      puts 'Trying to get secret version stage AWSPENDING'

      response = @client.get_secret_value({
        secret_id: @secret_id,
        version_stage: 'AWSPENDING'
      })

      puts response.secret_string
    rescue
      puts 'Putting new secret'

      # format expired_at as yyyy-mm-dd
      expired_at = 2.months.from_now.strftime('%Y-%m-%d')
      default_secret_string = {"Salt":"hello-world-#{Time.now}","ExpiredAt":expired_at}.to_json

      response = @client.create_secret({
        name: @secret_id,
        secret_string: default_secret_string
      })

      puts response.secret_string
    end
  end

  # This method should set the AWSPENDING secret in the service that the secret belongs to.
  # For example, if the secret is a database credential, this method should take the value of the AWSPENDING secret
  # and set the user's password to this value in the database.
  def set_secret
    puts 'Setting new secret AWSPENDING'

    @client.rotate_secret({
      secret_id: @secret_id
    })

    # format expired_at as yyyy-mm-dd
    expired_at = 3.months.from_now.strftime('%Y-%m-%d')
    new_secret_string = {"Salt":"latest-hello-world-#{Time.now}","ExpiredAt":expired_at}.to_json

    response = @client.put_secret_value({
      secret_id: @secret_id,
      secret_string: new_secret_string,
      version_stages: ['AWSPENDING']
    })

    @aws_pending_version_id = response.version_id
  end

  # This method should validate that the AWSPENDING secret works in the service that the secret belongs to. For example, if the secret
  # is a database credential, this method should validate that the user can login with the password in AWSPENDING and that the user has
  # all of the expected permissions against the database.
  def test_secret
    puts 'Testing new secret AWSPENDING'
  end

  # This method finalizes the rotation process by marking the secret version passed in as the AWSCURRENT secret.
  def finish_secret
    response = @client.update_secret_version_stage({
      secret_id: @secret_id,
      version_stage: 'AWSCURRENT',
      remove_from_version_id: @aws_current_version_id,
      move_to_version_id: @aws_pending_version_id
    })

    puts 'AWSCURRENT secret updated'
    response = @client.get_secret_value({
      secret_id: @secret_id,
      version_stage: 'AWSCURRENT'
    })

    puts response.secret_string
  end
end
