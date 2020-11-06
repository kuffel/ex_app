#!/usr/bin/env bash
set -e
# Every CI/CD build and deploys a new image with the version and the git commit hash.
# This means we will have images that are properly tagged but will be never used again.
# The ECR Lifecycle policies can only remove images by age or by tag.
# This script calls an AWS Lambda function that will check if an image is currently used by any container.
# Unused images will be deleted.

GITHUB_TOKEN=${1:-`cat ~/.github_token`}
LAMBDA_URL=${2:-"https://cn6abx7xxi.execute-api.eu-central-1.amazonaws.com/api"}

wget --quiet \
--method POST \
--header "content-type: application/json" \
--header "x-api-key: ${GITHUB_TOKEN}" \
--output-document \
- ${LAMBDA_URL}/cleanup-images
