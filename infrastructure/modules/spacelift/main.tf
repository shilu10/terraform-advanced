#terraform {
 # required_providers {
 #   spacelift = {
  #    source  = "spacelift-io/spacelift"
   #   version = "1.26.0"
   # }
  #}
#}

# ────────────────
# Locals to safely filter optional data
# ────────────────
locals {
  contexts_with_env_vars = {
    for ctx_name, ctx in var.contexts :
    ctx_name => ctx.env_vars
    if try(ctx.env_vars != null, false)
  }

  contexts_with_mounted_files = {
    for ctx_name, ctx in var.contexts :
    ctx_name => ctx.mounted_file
    if try(ctx.mounted_file != null, false)
  }
}

# ────────────────
# Spacelift Stack
# ────────────────
resource "spacelift_stack" "this" {
  name           = var.stack_name
  description    = var.stack_description
  administrative = var.administrative
  autodeploy     = var.autodeploy

  raw_git {
    namespace = var.raw_git_namespace
    url       = var.git_url
  }

  branch                   = var.branch
  project_root             = var.project_root
  additional_project_globs = var.additional_project_globs
  repository               = var.repository

  after_apply    = var.after_apply    != null ? var.after_apply    : []
  after_destroy  = var.after_destroy  != null ? var.after_destroy  : []
  after_init     = var.after_init     != null ? var.after_init     : []
  after_plan     = var.after_plan     != null ? var.after_plan     : []
  after_perform  = var.after_perform  != null ? var.after_perform  : []
  after_run      = var.after_run      != null ? var.after_run      : []
  before_apply   = var.before_apply   != null ? var.before_apply   : []
  before_destroy = var.before_destroy != null ? var.before_destroy : []
  before_init    = var.before_init    != null ? var.before_init    : []
  before_plan    = var.before_plan    != null ? var.before_plan    : []
  before_perform = var.before_perform != null ? var.before_perform : []

  labels                          = var.labels
  space_id                        = var.space_id
  protect_from_deletion           = var.protect_from_deletion
  terraform_external_state_access = var.terraform_external_state_access
  terraform_smart_sanitization    = var.terraform_smart_sanitization
  worker_pool_id                  = var.worker_pool_id != "" ? var.worker_pool_id : null

  dynamic "terragrunt" {
    for_each = var.enable_terragrunt ? [1] : []
    content {
      terraform_version      = var.terraform_version
      terragrunt_version     = var.terragrunt_version
      use_run_all            = var.use_run_all
      use_smart_sanitization = var.use_smart_sanitization
      tool                   = var.tool
    }
  }

  dynamic "github_enterprise" {
    for_each = var.use_github_enterprise ? [1] : []
    content {
      namespace = var.github_namespace
    }
  }
}

# ────────────────
# Spacelift Contexts
# ────────────────
resource "spacelift_context" "this" {
  for_each    = var.contexts
  name        = each.key
  description = each.value.description
  space_id    = var.space_id
}

# ───────────────────────────────
# Attach contexts to the stack
# ───────────────────────────────
resource "spacelift_context_attachment" "this" {
  for_each   = var.contexts
  context_id = spacelift_context.this[each.key].id
  stack_id   = spacelift_stack.this.id
  priority   = 0
}

# ───────────────────────────────
# Environment Variables per Context
# ───────────────────────────────
resource "spacelift_environment_variable" "this" {
  for_each = local.contexts_with_env_vars

  context_id  = spacelift_context.this[each.key].id
  name        = each.value.name
  value       = each.value.value
  description = each.value.description
  write_only  = each.value.write_only
}

# ───────────────────────────────
# Mounted Files per Context
# ───────────────────────────────
resource "spacelift_mounted_file" "this" {
  for_each = local.contexts_with_mounted_files

  context_id    = spacelift_context.this[each.key].id
  relative_path = each.value.relative_path
  content       = filebase64("${path.module}/${each.value.local_path}")
}

# ────────────────
# AWS Integration
# ────────────────
resource "spacelift_aws_integration" "this" {
  count    = var.attach_aws_role ? 1 : 0
  name     = "${var.stack_name}-aws-integration"
  role_arn = var.aws_role_arn
  space_id = var.space_id
}

resource "spacelift_aws_integration_attachment" "this" {
  count          = var.attach_aws_role ? 1 : 0
  integration_id = spacelift_aws_integration.this[0].id
  stack_id       = spacelift_stack.this.id
}

# ────────────────
# Drift Detection
# ────────────────
resource "spacelift_drift_detection" "this" {
  count     = var.enable_drift_detection ? 1 : 0
  stack_id  = spacelift_stack.this.id
  reconcile = var.drift_reconcile
  schedule  = var.drift_schedule
}

# security email
resource "spacelift_security_email" "this" {
  count = var.enable_security_email ? 1 : 0
  email = var.security_email_addr
}
