# ExApp Lambda

This folder contains a [AWS Chalice](https://aws.github.io/chalice/) based project to deploy a Lambda Function,
that supports the CI/CD pipeline of the [ex_app](https://github.com/kuffel/ex_app) project.

The following endpoints are provided by this project:

- /cleanup-images - Removes unused docker images from ECR
- /pull-requests - Returns a list of all pull requests and their status
- /unused-workspaces - List of terraform workspaces for closed pull requests
- /add-comment/{pull_request_id} - Add a comment on the given pull request

The corresponding scripts are placed in `../scripts` 



TODO: Why? https://ideas.circleci.com/api-feature-requests/p/expose-github-webhook-events-and-status-message-api




## Getting started

- Create a `Personal Access Token` using the [Github UI](https://github.com/settings/tokens)
- Save the token in `~/.github_token`

Create virtual environment and install the dependencies:

```bash
conda create --name ex_app python=3.6
conda activate ex_app
pip install -r requirements.txt

# Start locally
make run 

# Deploy to AWS
make deploy
```