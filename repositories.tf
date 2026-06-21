locals {
  repositories = yamldecode(file("${path.module}/contents/data.yaml"))

  repositories_with_pages = {
    for name, cfg in local.repositories : name => cfg
    if try(cfg.page, false)
  }

  allowed_action_patterns = [
    "Tchoupinax/pull-request-labeler@*",
    "ahmadnassri/action-terraform-report@*",
    "docker/build-push-action@*",
    "docker/login-action@*",
    "docker/metadata-action@*",
    "docker/setup-buildx-action@*",
    "docker/setup-qemu-action@*",
    "dorny/paths-filter@*",
    "fuxingloh/multi-labeler@*",
    "golangci/golangci-lint-action@*",
    "goreleaser/goreleaser-action@*",
    "hashicorp/setup-terraform@*",
    "helm/chart-testing-action@*",
    "helm/kind-action@*",
    "mislav/bump-homebrew-formula-action@*",
    "pnpm/action-setup@*",
    "release-drafter/release-drafter@*",
    "stefanprodan/helm-gh-pages@*",
    "tchoupinax/repo-config@*",
  ]
}

resource "github_repository" "repositories" {
  for_each = local.repositories

  name         = each.key
  description  = each.value.description
  topics       = each.value.topics
  homepage_url = try(each.value.homepage, null)

  visibility      = "public"
  has_discussions = false
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

resource "github_repository_pages" "pages" {
  for_each = local.repositories_with_pages

  repository = github_repository.repositories[each.key].name
  build_type = "workflow"
}

resource "github_branch_protection" "this" {
  for_each = github_repository.repositories

  repository_id = each.value.name

  pattern          = "master"
  enforce_admins   = true
  allows_deletions = false

  dynamic "required_pull_request_reviews" {
    for_each = try(each.value.requiredApprovingReviewCount, 0) > 0 ? [try(each.value.requiredApprovingReviewCount, 1)] : []

    content {
      required_approving_review_count = required_pull_request_reviews.value
      dismiss_stale_reviews           = true
    }
  }

  required_status_checks {
    strict   = try(each.value.requiredStatusChecksStrict, false)
    contexts = try(each.value.requiredStatusChecks, [])
  }
}

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
    verified_allowed     = true
    patterns_allowed     = local.allowed_action_patterns
  }
}
