locals {
  repositories = yamldecode(file("${path.module}/data.yaml"))
}

resource "github_repository" "repositories" {
  for_each = local.repositories

  name        = each.key
  description = each.value.description
  visibility  = "private"
}
