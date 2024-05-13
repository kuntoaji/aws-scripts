#!/bin/bash
#
# kaklabs.com - @kaklabs
# Script to check EC2 instances with a name containing a given value
# Required jq to be installed
# Usage: bash check-ec2-instances.sh <name> or ./check-ec2-instances.sh <ec2_name>

ec2_name=$1
echo "EC2 name: $ec2_name"

regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)

for region in $regions; do
  echo "Checking instances in region: $region"

  # Get the list of EC2 instances in the region with name containing value from $ec2_name
  instances=$(aws ec2 describe-instances --region $region --query 'Reservations[].Instances[?contains(Tags[?Key==`Name`].Value, `$ec2_name`)]' --output json)

  # Check if any instances match the criteria
  instance_count=$(echo "$instances" | jq -r '. | length')
  if [[ "$instance_count" -gt 0 ]]; then

    for (( i=0; i<$instance_count; i++ )); do
      instance_id=$(echo "$instances" | jq -r ".[$i].InstanceId")
      state=$(echo "$instances" | jq -r ".[$i].State.Name")
      echo "Instance ID: $instance_id, State: $state"
    done
  else
    echo "No instances with name containing '$ec2_name' found in region: $region"
  fi

  echo
done
