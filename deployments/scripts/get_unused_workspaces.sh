#!/usr/bin/env bash
set -e
# The CI/CD pipeline creates a new terraform workspace for every preview environment.
# This scripts calls the AWS Lambda function to get a list of workspaces for closed pull requests.
# The CI/CD pipeline will clean up these workspaces.

GITHUB_TOKEN=${1:-`cat ~/.github_token`}
LAMBDA_URL=${2:-"https://cn6abx7xxi.execute-api.eu-central-1.amazonaws.com/api"}

wget --quiet \
--method GET \
--header "content-type: application/json" \
--header "x-api-key: ${GITHUB_TOKEN}" \
--output-document \
- ${LAMBDA_URL}/unused-workspaces