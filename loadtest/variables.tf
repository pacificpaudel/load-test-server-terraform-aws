variable "environment" {
  default = "production"
}

variable "db_parameter_group_name" {
  default = "production-params"
}

variable "rds_admin_password" {
  
}
variable "infra_path" {
    description = "Local file to path to the root of the infra project. This is a directory that contains the directories bin, deployment and shared-modules."
    default = "../"
}

#ALB
variable "health_check_interval" {
    description = "Number of seconds between health checks."
    default = 30
}

variable "health_check_timeout" {
    description = "Number of seconds on which health check times out."
    default = 10
}

variable "certificate_arn" {
    description = "TLS certificate ARN for load balancer."
    default = ""
}

variable "sticky_sessions" {
    description = "Whether sticky cookie-based HTTP sessions are enabled in the load balancer."
    default = false
}

variable "cookie_duration" {
    description = "Sticky session cookie duration in seconds. Default is one day."
    default = 86400
}

variable "public" {
    description = "Whether the ALB and Route 53 are in public or private subnet."
    default = true
}

variable "idle_timeout" {
    description = "Timeout limit for a connection"
    default = 60
}

variable "deregistration_delay" {
    description = "The time to wait for in-flight requests to complete while deregistering a target. During this time, the state of the target is draining."
    default = 300

}
variable "health_check_path" {
    description = "HTTP path on the main container which should respond to health checks with HTTP status 200."
    default = "/health"
}

variable "azs" {
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "groups" {
  description = "Enforce MFA for the members in these groups"
  type = "list"
  default = ["Cloubi", "Billing", "Administrators"]
}

variable "users" {
  description = "Enforce MFA for these users"
  type = "list"
  default = []
}


variable "allow_password_change_without_mfa" {
  description = "Allow changing the user password without MFA"
  type = "string"
  default = "false"
}