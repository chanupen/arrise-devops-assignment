# AWS DevOps Assignment

Terraform configurations for the five tasks in the assignment document.

## Contents

- `task1-ec2/`: EC2 module and instance configuration
- `task2-backend/`: S3 state bucket and DynamoDB locking table
- `task3-iam/`: IAM groups, roles, and cross-account access
- `task4-ci-policy/`: CI pipeline policy
- `task5-fix/`: corrected RoleC example
- `NOTES.md`: implementation notes and run instructions

## Requirements

- Terraform 1.5 or later
- AWS CLI credentials configured outside this repository

The example files use placeholder account IDs and bucket names. Replace them before applying. Terraform will create billable AWS resources; no assignment resources are currently deployed.
