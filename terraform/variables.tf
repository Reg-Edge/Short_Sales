# variables.tf
# Input variables for AWS region, instance type, volume size, tags, PBID URL
# See: https://developer.hashicorp.com/terraform/language/values/variables
variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type (Free Tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "volume_size" {
  description = "Root EBS volume size (GB)"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    Project = "PowerBI-Agent"
  }
}

variable "PBID_URL" {
  description = "Power BI Desktop download URL"
  type        = string
  default     = "https://download.microsoft.com/download/1/2/3/12345678-abcd-1234-abcd-1234567890ab/PBIDesktopSetup_x64.exe"
  # Update with latest from https://www.microsoft.com/en-us/download/details.aspx?id=58494
}
