#!/bin/bash
#
# kaklabs.com - @kaklabs
# Script to check EC2 instances with a name containing a given value
# Usage: bash check-ec2-instances.sh <name> or ./check-ec2-instances.sh <ec2_name>

ec2_name=$1
echo "EC2 name: $ec2_name"

# regions=$(aws ec2 describe-regions --output text | awk '{print $NF}')
regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)

for region in $regions; do

  # Get the list of all EC2 instances in the region
  instances=$(aws ec2 describe-instances --region $region --filters Name=tag:Name,Values="$ec2_name" --query 'Reservations[].Instances[].InstanceId' --output text)
  #instances=$(aws ec2 describe-instances --region $region --query 'Reservations[].Instances[?contains(Tags[?Key==`Name`].Value, `$ec2_name`)]' --output text)

  if [[ -n $instances ]]; then
    for instance in $instances; do
      state=$(aws ec2 describe-instances --region $region --instance-ids $instance --query 'Reservations[].Instances[].State.Name' --output text)
      echo "Instance: $instance"
      echo "Region: $region"
      echo "State: $state"
    done
  fi
done
