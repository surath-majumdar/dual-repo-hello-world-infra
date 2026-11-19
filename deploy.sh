#!/usr/bin/env bash
set -euo pipefail

POLICY_REPO="git::https://github.com/surath-majumdar/platform-governance-policies.git//policies/infra"

echo "1. Initializing Terraform..."
terraform init -input=false

echo "2. Generating Terraform Plan..."
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json

echo "3. Running Centralized FinOps Front-Gate (OPA/Conftest)..."
conftest test tfplan.json --update "$POLICY_REPO"

echo "4. Policy Passed! Applying to OrbStack Kubernetes..."
terraform apply -auto-approve tfplan.binary