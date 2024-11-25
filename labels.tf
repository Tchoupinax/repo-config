module "labels" {
  source = "./modules/labels"

  for_each        = github_repository.repositories
  repository_name = each.value.name
}
