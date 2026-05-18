#!/usr/bin/env bash

# Script to list and display RDS database instances with key details in a table format.

# Authenticate with AWS CLI (ensure you've configured your credentials)
aws sts get-caller-identity

# Get the list of RDS instances
instance_list=$(aws rds describe-db-instances --query 'DBInstances[*].DBInstanceIdentifier' --output text)

# Check if any instances were found
if [ -z "$instance_list" ]; then
  echo "No RDS database instances found."
  exit 1
fi


# Print the table header
printf "%-40.40s %-15.15s %-15.15s %-25.25s %-10.10s\n" "DB Instance Identifier" "Status" "Engine Version" "Allocated Storage (GB)" "Multi AZ"
printf '%s\n' "------------------------------------------------------------------------------------------------------"

# Iterate through the instances and print details in a table format
for instance in $instance_list; do
  db_info=$(aws rds describe-db-instances --db-instance-identifier "$instance" --query 'DBInstances[0].{Status:DBInstanceStatus,EngineVersion:EngineVersion,AllocatedStorage:AllocatedStorage,MultiAZ:MultiAZ}' --output json)

  status=$(echo "$db_info" | jq -r '.Status')
  engine_version=$(echo "$db_info" | jq -r '.EngineVersion')
  allocated_storage=$(echo "$db_info" | jq -r '.AllocatedStorage')
  multi_az=$(echo "$db_info" | jq -r '.MultiAZ')

  printf "%-40.40s %-15.15s %-15.15s %-25.25s %-10.10s\n" "$instance" "$status" "$engine_version" "$allocated_storage" "$multi_az"
done

printf '%s\n' "------------------------------------------------------------------------------------------------------"
