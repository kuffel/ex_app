
variable "deployment_name" {
  description = "Name for this deployment, will be used as part of resource names and for the DNS entry."
  default = "ex-app"
}

variable "docker_tag" {
  description = "Tag for the image that will be deployed."
  default = ""
}