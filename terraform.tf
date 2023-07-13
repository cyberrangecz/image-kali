terraform {
  backend "http" {
  }
  required_providers {
    kypo = {
      source  = "vydrazde/kypo"
      version = ">= 0.1.0"
    }
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "16.0.3"
    }
  }
}

provider "kypo" {
  endpoint  = local.endpoint
  client_id = "bzhwmbxgyxALbAdMjYOgpolQzkiQHGwWRXxm"
}

provider "openstack" {
  auth_url = "https://identity.cloud.muni.cz/v3"
  region   = "brno1"
}

provider "gitlab" {
  base_url = "https://${var.CI_SERVER_HOST}/api/v4"
  token    = var.ACCESS_TOKEN
}

variable "CI_PROJECT_ID" {}
variable "CI_PROJECT_URL" {}
variable "CI_COMMIT_SHA" {}
variable "CI_SERVER_HOST" {}
variable "CI_PROJECT_PATH" {}
variable "NAME" {}
variable "TYPE" {}
variable "DISTRO" {}
variable "GUI_ACCESS" {}
variable "ACCESS_TOKEN" {
  sensitive = true
}

locals {
  endpoint = "https://images.crp.kypo.muni.cz"
  pool_url = "${local.endpoint}/pool/${module.sandbox.pool_id}"
}


resource "openstack_images_image_v2" "test_image" {
  name             = "${var.NAME}-${var.CI_COMMIT_SHA}"
  local_file_path  = "target-qemu/${var.NAME}"
  container_format = "bare"
  disk_format      = "raw"

  properties = {
    hw_scsi_model                          = "virtio-scsi"
    hw_disk_bus                            = "scsi"
    hw_rng_model                           = "virtio"
    hw_qemu_guest_agent                    = "yes"
    os_require_quiesce                     = "yes"
    os_type                                = var.TYPE
    os_distro                              = var.DISTRO
    "owner_specified.openstack.version"    = var.CI_COMMIT_SHA
    "owner_specified.openstack.gui_access" = var.GUI_ACCESS
    "owner_specified.openstack.created_by" = "munikypo"
  }

  lifecycle {
    replace_triggered_by = [
      gitlab_branch.gitlab_branch
    ]
  }
}

resource "local_file" "topology" {
  filename = "topology.yml"
  content  = replace(file("topology.yml"), "IMAGE_NAME", openstack_images_image_v2.test_image.name)
}

resource "gitlab_branch" "gitlab_branch" {
  name    = "test-${var.CI_COMMIT_SHA}"
  ref     = var.CI_COMMIT_SHA
  project = var.CI_PROJECT_ID
}

resource "null_resource" "git_commit" {
  provisioner "local-exec" {
    command = <<EOT
      git config user.name "Service KYPO Images"; git config user.email "485514@muni.cz"
      git fetch
      git switch ${gitlab_branch.gitlab_branch.name}
      git add topology.yml
      git commit -m "Replace IMAGE_NAME"
      git push https://root:${var.ACCESS_TOKEN}@${var.CI_SERVER_HOST}/${var.CI_PROJECT_PATH}.git ${gitlab_branch.gitlab_branch.name}
    EOT
  }

  triggers = {
    topology      = local_file.topology.content_sha256
    gitlab_branch = gitlab_branch.gitlab_branch.name
  }
}

module "sandbox" {
  source      = "vydrazde/sandbox/kypo"
  project_url = var.CI_PROJECT_URL
  rev         = var.CI_COMMIT_SHA

  depends_on = [
    openstack_images_image_v2.test_image,
    null_resource.git_commit
  ]

}

resource "local_file" "pool_url" {
  filename = "vars.env"
  content  = "POOL_URL=${local.pool_url}"
}

output "pool_url" {
  value = local.pool_url
}
