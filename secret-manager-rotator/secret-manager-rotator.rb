require 'aws-sdk-secretsmanager'

class SecretManagerRotator
  def initialize(secret_id)
    @secret_id = secret_id
    @client = Aws::SecretsManager::Client.new
  end

  def get_secret_string(version_stage = 'AWSCURRENT')
    response = @client.get_secret_value({
      secret_id: @secret_id,
      version_stage: version_stage
    })

    puts response.secret_string
  end

  def update_with_new_secret(new_secret)
    response = @client.update_secret({
      secret_id: @secret_id,
      secret_string: new_secret
    })
  end
end
