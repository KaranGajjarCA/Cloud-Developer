variable "region" {
  type    = string
  default = "us-east-1"
}
variable "apigw_name" {
  type    = string
  default = "backend_api"
}
variable "attributes" {
  type = list(object({
    name = string
    type = string
  }))
  description = "The list of nested attribute definitions."
  default = [
    {
      name = "user_id"
      type = "S"
    },
    {
      name = "todo_id"
      type = "S"
    }
  ]
}