resource "spacelift_stack" "this" {
  name                  = var.stack_name
  repository            = var.repository
  branch                = var.branch
  project_root          = var.project_root
  terraform_version     = var.terraform_version
  description           = var.description
  autodeploy            = var.autodeploy
  administrative        = var.administrative
  manage_state          = var.manage_state
  protect_from_deletion = var.protect_from_deletion
  space_id              = var.space_id
  labels                = var.labels
  vcs_ignore_paths      = var.vcs_ignore_paths
  autostop              = var.autostop
  enable_init           = var.enable_init
  runner_image          = var.runner_image
  worker_pool_id        = var.worker_pool_id
}

# Optional context attachments
resource "spacelift_stack_context_attachment" "this" {
  for_each = var.enable_context_attachment && length(var.context_ids) > 0 ? toset(var.context_ids) : {}

  stack_id   = spacelift_stack.this.id
  context_id = each.value
}

# Optional environment variables
resource "spacelift_environment_variable" "env" {
  for_each = var.enable_environment_variables && length(var.environment_variables) > 0 ? var.environment_variables : {}

  stack_id   = spacelift_stack.this.id
  name       = each.key
  value      = each.value
  write_only = false
}

# Optional mounted files
resource "spacelift_mounted_file" "this" {
  for_each = var.enable_mounted_files && length(var.mounted_files) > 0 ? var.mounted_files : {}

  stack_id      = spacelift_stack.this.id
  relative_path = each.key
  content       = each.value
}
