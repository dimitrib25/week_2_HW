variable "users" {
  description = "Map of users and their corresponding environments"
  type = map(string)
  default = {
    Mook = "development",
    Revan = "staging",
    Dack = "production",
  }
}
