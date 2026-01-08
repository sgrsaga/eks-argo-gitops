# Terraform State Management Setup

This document explains how to set up proper Terraform state management with S3 backend and DynamoDB state locking.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed
- Appropriate IAM permissions to create S3 buckets and DynamoDB tables

## 1. Create S3 Bucket for Terraform State

```bash
# Set your bucket name (must be globally unique)
export TF_STATE_BUCKET="terraform-state-files-sgr-jay"
export AWS_REGION="ap-south-1"

# Create S3 bucket
aws s3api create-bucket \
  --bucket $TF_STATE_BUCKET \
  --region $AWS_REGION \
  --create-bucket-configuration LocationConstraint=$AWS_REGION

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket $TF_STATE_BUCKET \
  --versioning-configuration Status=Enabled

# Enable server-side encryption
aws s3api put-bucket-encryption \
  --bucket $TF_STATE_BUCKET \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Block public access
aws s3api put-public-access-block \
  --bucket $TF_STATE_BUCKET \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

## 2. Create DynamoDB Table for State Locking

```bash
aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $AWS_REGION

# Enable point-in-time recovery
aws dynamodb update-continuous-backups \
  --table-name terraform-state-lock \
  --point-in-time-recovery-enabled \
  --region $AWS_REGION
```

## 3. Verify Setup

```bash
# Verify S3 bucket
aws s3 ls s3://$TF_STATE_BUCKET

# Verify DynamoDB table
aws dynamodb describe-table \
  --table-name terraform-state-lock \
  --region $AWS_REGION \
  --query 'Table.[TableName,TableStatus]' \
  --output table
```

## 4. Backend Configuration

The Terraform backend is already configured in `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-files-sgr-jay"
    key            = "eks-argo-gitops/development/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

## 5. Migrate Existing State (if needed)

If you have existing local state files, migrate them to S3:

```bash
cd terraform/environment/development/

# Initialize with new backend
terraform init -migrate-state

# Verify state was migrated
terraform state list
```

## 6. State Locking Behavior

When you run `terraform apply` or `terraform plan`:

1. Terraform acquires a lock in DynamoDB table
2. If another process is already holding the lock, the command will wait
3. After completion, the lock is automatically released
4. State file is stored in S3 with encryption and versioning

## 7. IAM Permissions Required

Ensure your IAM user/role has these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
        "arn:aws:s3:::terraform-state-files-sgr-jay",
        "arn:aws:s3:::terraform-state-files-sgr-jay/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:ap-south-1:*:table/terraform-state-lock"
    }
  ]
}
```

## 8. Best Practices

- ✅ Use separate state files for different environments (dev/staging/prod)
- ✅ Enable S3 versioning to recover from accidents
- ✅ Enable S3 encryption for security
- ✅ Use DynamoDB for state locking to prevent concurrent modifications
- ✅ Restrict S3 bucket access with IAM policies
- ✅ Enable DynamoDB point-in-time recovery
- ❌ Never commit state files to Git
- ❌ Never disable state locking in production

## Troubleshooting

### Lock Timeout

If you get a lock timeout error:

```bash
# Force unlock (use with caution!)
terraform force-unlock <LOCK_ID>
```

### State File Recovery

To recover an older version from S3:

```bash
# List versions
aws s3api list-object-versions \
  --bucket $TF_STATE_BUCKET \
  --prefix eks-argo-gitops/development/terraform.tfstate

# Download specific version
aws s3api get-object \
  --bucket $TF_STATE_BUCKET \
  --key eks-argo-gitops/development/terraform.tfstate \
  --version-id <VERSION_ID> \
  terraform.tfstate.backup
```
