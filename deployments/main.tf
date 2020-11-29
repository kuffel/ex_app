# https://medium.com/@bradford_hamilton/deploying-containers-on-amazons-ecs-using-fargate-and-terraform-part-2-2e6f6a3a957f
# https://engineering.finleap.com/posts/2020-02-20-ecs-fargate-terraform/

provider "aws" {
  version = "~> 2.70"
  region = "eu-central-1"
  profile = "kuffel"
}

terraform {
  backend "s3" {
    key    = "ex_app.tfstate"
    region = "eu-central-1"
    bucket = "kuffel-terraform-states"
    profile = "kuffel"
  }
}