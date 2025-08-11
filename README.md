# Packer + Ansible AMI Pipeline (Production-ready)

This repository builds a Linux AMI with **Nginx** using **Packer** and **Ansible**, validates the AMI by launching a temporary EC2 instance and performing an HTTP check (curl), then tears down the instance and security group. It's designed to run in **GitHub Actions** using an IAM user (`EC2Automation`) credentials stored as GitHub Secrets (or you can switch to OIDC later).

## Repo layout
```
packer-ami-production/
├── packer/
│   └── template.pkr.hcl
├── ansible/
│   ├── install_nginx.yml
│   └── validate_ami.yml
├── .github/
│   └── workflows/
│       └── build-and-validate.yml
├── iam/
│   └── ec2_automation_policy.json
└── README.md
```

## Before you run
1. Create an IAM user called `EC2Automation` (programmatic access) and attach the policy in `iam/ec2_automation_policy.json` (adjust scope as needed).
2. Add the following GitHub Secrets in your repository (Settings → Secrets → Actions):
   - `AWS_ACCESS_KEY_ID` (from EC2Automation)
   - `AWS_SECRET_ACCESS_KEY` (from EC2Automation)
   - `AWS_REGION` (e.g., us-east-1)
3. Pin the `source_ami` in `packer/template.pkr.hcl` to an AMI valid in your region (example uses Amazon Linux 2).
4. Run the workflow from the Actions tab (Build and Validate AMI).

## What the workflow does
- Builds an AMI with Packer using the Ansible provisioner to install nginx.
- Launches a temporary EC2 instance from the built AMI.
- Waits for HTTP `200 OK` by polling with `curl` (no SSH).
- Terminates the instance and deletes the temporary security group.
- Uploads a validation artifact with instance details.

## Notes
- This setup uses GitHub Secrets (IAM user). For production, prefer GitHub OIDC + AssumeRole to avoid long-lived keys.
- Validate and tighten IAM policy to minimum required resources (you can replace Resource:"*" with resource ARNs).
