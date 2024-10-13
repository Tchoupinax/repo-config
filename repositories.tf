locals {
  repositories = yamldecode(file("${path.module}/contents/data.yaml"))
}

resource "github_repository" "repositories" {
  for_each = local.repositories

  name         = each.key
  description  = each.value.description
  topics       = each.value.topics
  homepage_url = try(each.value.homepage, null)

  visibility      = "public"
  has_discussions = false
  has_downloads   = false
  has_issues      = true
  has_projects    = false
  has_wiki        = false
  is_template     = false

  allow_auto_merge       = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  allow_squash_merge     = true
  archive_on_destroy     = true
  auto_init              = true
  delete_branch_on_merge = true
}

#resource "github_branch_protection" "this" {
#  for_each = github_repository.repositories

#  repository_id = each.value.name

#  pattern          = "master"
#  enforce_admins   = true
#  allows_deletions = false

#  #required_pull_request_reviews {
#  #  dismiss_stale_reviews      = true
#  #  require_code_owner_reviews = true
#  #}

#  required_status_checks {
#    strict = true
#  }
#}

resource "github_repository_file" "renovate_json" {
  for_each = github_repository.repositories

  repository = each.value.name

  branch              = "master"
  commit_author       = "Terraform Bot"
  commit_email        = "terraform@corentinfiloche.xyz"
  commit_message      = "chore: create or upgrade renovate configuration"
  content             = file("${path.module}/contents/renovate.json")
  file                = "renovate.json"
  overwrite_on_create = true
}

resource "github_actions_repository_permissions" "this" {
  for_each = github_repository.repositories

  repository = each.value.name

  allowed_actions = "selected"
  allowed_actions_config {
    github_owned_allowed = true
    patterns_allowed     = ["ahmadnassri/action-terraform-report@*"]
    verified_allowed     = true
  }
}
