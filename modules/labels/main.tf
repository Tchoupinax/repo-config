
resource "github_issue_label" "patch" {
  repository  = var.repository_name
  name        = "semver:patch"
  color       = replace("#FEF2C0", "#", "")
  description = "Label for pull request that brings a patch change."
}
resource "github_issue_label" "minor" {
  repository  = var.repository_name
  name        = "semver:minor"
  color       = replace("#8AF85B", "#", "")
  description = "Label for pull request that brings a minor change."
}
resource "github_issue_label" "major" {
  repository  = var.repository_name
  name        = "semver:major"
  color       = replace("#8151C5", "#", "")
  description = "Label for pull request that brings a major(BREAKING) change."
}
resource "github_issue_label" "documentation" {
  repository  = var.repository_name
  name        = "docs"
  color       = replace("#0075ca", "#", "")
  description = "Improvements or additions to documentation."
}
resource "github_issue_label" "duplicate" {
  repository  = var.repository_name
  name        = "duplicate"
  color       = replace("#cfd3d7", "#", "")
  description = "This issue or pull request already exists."
}
resource "github_issue_label" "ci_cd" {
  repository  = var.repository_name
  name        = "CI/CD"
  color       = replace("#93ECDB", "#", "")
  description = "Pull requests brings CI/CD improvements."
}
resource "github_issue_label" "maintenance" {
  repository  = var.repository_name
  name        = "maintenance"
  color       = replace("#ED4D86", "#", "")
  description = "Maintenance work."
}
