Chandan Kumar

## Completed work

### Task 1: EC2 instances

- I built a reusable module that creates five EC2 instances from one `instances` map.
- Each example instance has a different instance type, root volume type, size, and key pair. All are tagged with `Name`, `Environment`, and `Owner`.
- I protected `db-primary` with `prevent_destroy` and added outputs for instance IDs and private IPs.

### Task 2: Remote state

- I added an encrypted, versioned S3 state bucket and a DynamoDB lock table. The bootstrap stack uses local state to create them.
- With local state, concurrent applies have no shared state or lock and can create conflicting resources or leave state inconsistent. The S3 backend shares state, and DynamoDB allows only one apply to hold the lock at a time.

### Task 3: IAM

- I added `engine` and `ci` to programmatic-only `group1`, and `abhay.singh` and `neha.gupta` to `group2` with `AdministratorAccess`.
- `roleA` allows AWS actions but denies IAM actions. `roleB` can only assume `roleC`. `roleC` trusts the specific `roleB` ARN and has access to one S3 bucket.
- For production CI, I would use OIDC and short-lived role credentials instead of IAM user access keys. For people, I would use IAM Identity Center. Terraform does not create user passwords or access keys.
- Trusting Account A's root can allow other principals in that account to assume `roleC` if their policies allow it. Trusting `roleB`'s ARN limits the trust to that role. I tested the stacks in one AWS account, not across two separate accounts.

### Task 4: CI policy

- I created a custom policy for `ci` to push to one ECR repository, register task definitions, update one ECS service, pass only the specified ECS roles, and read one artifact bucket.
- I left out broad service access, artifact writes, deletion actions, and unrestricted `iam:PassRole`. ECR authorization and task-definition registration require `Resource: "*"`; other actions are scoped to the required resources.

### Task 5: RoleC fix

- I changed the trust principal from `user/roleB` to the `roleB` role ARN. The original ARN identified a user, so it did not match the role calling `AssumeRole`.
- I scoped `s3:*` from `Resource: "*"` to the named bucket ARN and its object ARN (`bucket/*`). This gives access to that bucket only.

## How to run

- Use Terraform 1.5 or later. Configure AWS profiles outside this repository and check the account before applying: `aws sts get-caller-identity --profile account-a`.
- Copy the `.example` files to their working names and replace the account, profile, and globally unique bucket placeholders. Do not commit credentials, `.tfvars`, `backend.hcl`, or state files.
- Create the backend first: copy `task2-backend/bootstrap/terraform.tfvars.example` to `terraform.tfvars`, then run `terraform -chdir=task2-backend/bootstrap init` and `terraform -chdir=task2-backend/bootstrap apply`.
- Configure Task 1's `terraform.tfvars` and `backend.hcl` from their examples, then run `terraform -chdir=task1-ec2 init -backend-config=backend.hcl` and `terraform -chdir=task1-ec2 apply`.
- Configure and apply `task3-iam/account-a` before `task3-iam/account-b`, using each account's own profile and ID.
- These stacks create billable resources. To clean up, destroy Task 1, Account B, Account A, and the backend in that order. Empty the RoleC bucket first. Temporarily remove Task 1's `prevent_destroy` block before destroying it, then restore the block.

## Status

- I validated and applied the configurations, then destroyed the lab resources. The files here are sanitized examples and are not currently deployed.
