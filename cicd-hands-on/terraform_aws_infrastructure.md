# Terraform AWS Infrastructure

This project uses Terraform to provision a foundational AWS infrastructure, including networking, security, storage, and IAM resources. The infrastructure is designed to be modular and is managed through a CI/CD pipeline using GitHub Actions.

## Project Structure

```
terraform-aws-infrastructure/
├── .github/
│   └── workflows/
│       └── terraform.yml
├── backend-init/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── modules/
│   ├── networking/
│   ├── security/
│   ├── storage/
│   └── iam/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tf
├── providers.tf
└── README.md
```

## Prerequisites

Before you begin, ensure you have the following installed and configured:

- **Terraform CLI**: Version 1.5.0 or later.
- **AWS CLI**: Configured with credentials for an AWS account. You can configure this by running `aws configure`.
- **GitHub Account**: To fork the repository and use GitHub Actions.

## Local Development Setup

Running this project locally involves a two-stage process. First, we create the remote backend resources (S3 bucket and DynamoDB table) using a local state. Second, we configure the main project to use those newly created resources as its backend.

### Stage 1: Create the Remote Backend Resources

The `backend-init` directory contains the Terraform configuration to create an S3 bucket for storing the Terraform state file and a DynamoDB table for state locking.

1. Navigate to the backend initialization directory:

```bash
cd backend-init
```

2. Initialize Terraform:

This will initialize with a local backend, meaning the state file will be created in this directory.

```bash
terraform init
```

3. Apply the configuration:

This will create the S3 bucket and DynamoDB table in your AWS account.

```bash
terraform apply
```

4. Take note of the `s3_bucket_name` and `dynamodb_table_name` from the output. You will need them in the next stage.

### Stage 2: Configure and Run the Main Project

Now, we will configure the main project to use the resources you just created.

1. Navigate to the project's root directory:

```bash
cd ..
```

2. Configure the remote backend:

Open the `terraform.tf` file in the root directory. You will see a `backend "s3"` block. You must manually update the `bucket` and `dynamodb_table` keys with the names of the resources created in Stage 1.

**Example `terraform.tf`:**

```hcl
terraform {
  # ... other configurations ...

  backend "s3" {
    bucket         = "your-terraform-state-bucket-name" # <-- UPDATE THIS
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-terraform-locks-table-name"  # <-- UPDATE THIS
    encrypt        = true
  }
}
```

3. Re-initialize Terraform:

Now, initialize the main project. Terraform will detect the backend configuration and prompt you to migrate your (currently empty) local state to the new S3 remote backend.

```bash
terraform init
```

When prompted to copy existing state to the new backend, type `yes`.

4. Plan and Apply the Main Infrastructure:

You are now ready to deploy the main infrastructure.

```bash
# See what resources will be created
terraform plan

# Deploy the resources
terraform apply
```

## GitHub Actions Workflow Setup

To get the CI/CD pipeline running in your own fork of this repository, you need to provide it with AWS credentials.

### 1. Create an IAM User for GitHub Actions

It is best practice to create a dedicated IAM user with programmatic access and the minimum required permissions for Terraform to manage your resources.

- In the AWS Console, navigate to IAM and create a new user.
- Grant this user the necessary permissions (e.g., `AdministratorAccess` for simplicity, or a more restrictive, custom policy for production use).
- On the final screen, copy the **Access key ID** and **Secret access key**. These will be used as GitHub secrets.

### 2. Add Credentials as GitHub Secrets

You need to add the AWS credentials to your GitHub repository's secrets so the workflow can authenticate with your AWS account.

- In your forked GitHub repository, go to **Settings > Secrets and variables > Actions**.
- Click **New repository secret** for each of the following secrets:
  - `AWS_ACCESS_KEY_ID`: Paste the Access key ID from the IAM user you created.
  - `AWS_SECRET_ACCESS_KEY`: Paste the Secret access key.

### How the Workflow Operates

Once the secrets are configured, the workflow will run automatically:

- **Plan Job**: When a pull request is opened targeting the `main` branch, a `terraform plan` is executed. The plan's output is posted as a comment on the pull request for review.
- **Apply Job**: When a pull request is successfully merged into the `main` branch, a `terraform apply` is executed, deploying the changes to your AWS infrastructure.

The workflow is also configured with paths to only trigger if changes are made within the `project-root/cicd-handson/cloud-launch-project/` directory of your repository.
