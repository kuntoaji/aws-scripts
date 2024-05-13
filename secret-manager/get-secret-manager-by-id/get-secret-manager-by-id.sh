#!/bin/bash
#
# kaklabs.com - @kaklabs
# Get secret manager by id. Ensure you have the correct permissions to access the secret and AWS CLI is installed and configured properly.
# Usage: bash get-secret-manager-by-id.sh <secret_id> or ./get-secret-manager-by-id.sh <secret_id>

aws secretsmanager get-secret-value --secret-id $1
