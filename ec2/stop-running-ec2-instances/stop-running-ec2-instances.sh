#!/bin/bash
#
# kaklabs.com - @kaklabs
# Script to stop running EC2 instances with a name containing a given value
# Usage: bash stop-running-ec2-instances.sh <name> or ./stop-running-ec2-instances.sh <ec2_name>

ec2_name=$1
echo "EC2 name: $ec2_name"

regions=$(aws ec2 describe-regions --query 'Regions[].RegionName' --output text)

for region in $regions; do

  # Get the list of all EC2 instances in the region
  instances=$(aws ec2 describe-instances --region $region --filters Name=tag:Name,Values="$ec2_name" --query 'Reservations[].Instances[].InstanceId' --output text)

  if [[ -n $instances ]]; then
    for instance in $instances; do
      state=$(aws ec2 describe-instances --region $region --instance-ids $instance --query 'Reservations[].Instances[].State.Name' --output text)

      echo "Instance: $instance"
      echo "Region: $region"
      echo "State: $state"

      # if state is running, stop the instance
      if [[ "$state" == "running" ]]; then

        echo "Stopping instance $instance in region $region"
        result=$(aws ec2 stop-instances --instance-ids "$instance")

        if [ $? -eq 0 ]; then
          echo "EC2 instance stopped successfully: $instance"
        else
          echo "Failed to stop EC2 instance: $instance"
        fi
      fi
    done
  fi
done
