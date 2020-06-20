locals {
  tmp_k8s_config_file = "${path.module}/temp_k8s_config_file.tmp"
}

resource "null_resource" "create_k8s_cluster" {
  provisioner "local-exec" {
    command = "${path.module}/sh/k8s_create.sh"

    environment = {
      "symp_host"     = var.symp_host
      "symp_domain"   = var.symp_domain
      "symp_user"     = var.symp_user
      "symp_password" = var.symp_password
      "symp_prj"      = var.symp_project
      "k8s_name"      = var.k8s_name
      "k8s_eng"       = var.k8s_eng
      "k8s_subnet"    = var.k8s_subnet
      "k8s_size"      = var.k8s_size
      "k8s_count"     = var.k8s_count
      "k8s_type"      = var.k8s_type
      "k8s_eip"       = var.k8s_eip
      "k8s_confile"   = local.tmp_k8s_config_file
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/sh/k8s_delete.sh"

    environment = {
      "symp_host"     = var.symp_host
      "symp_domain"   = var.symp_domain
      "symp_user"     = var.symp_user
      "symp_password" = var.symp_password
      "symp_prj"      = var.symp_project
      "k8s_name"      = var.k8s_name
    }
  }
}

resource "null_resource" "k8s_add_private_registry" {
  provisioner "local-exec" {
    command = "${path.module}/sh/k8s_add_prv_reg.sh"

    environment = {
      "symp_host"     = var.symp_host
      "symp_domain"   = var.symp_domain
      "symp_user"     = var.symp_user
      "symp_password" = var.symp_password
      "symp_prj"      = var.symp_project
      "k8s_name"      = var.k8s_name
      "k8s_prv_reg"   = var.k8s_private_registry
    }
  }

  depends_on = [null_resource.create_k8s_cluster]

  # add the private registry only if it is declared
  count = var.k8s_private_registry != "" ? 1 : 0
}

resource "null_resource" "k8s_config_file" {
  provisioner "local-exec" {
    command = "cp  ${local.tmp_k8s_config_file} ${var.k8s_configfile_path}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${var.k8s_configfile_path}"
  }

  depends_on = [null_resource.create_k8s_cluster]
}

data "external" "k8s_info" {
  program = ["bash", "${path.module}/sh/k8s_info.sh"]

  query = {
    "host"       = var.symp_host
    "domain"     = var.symp_domain
    "user"       = var.symp_user
    "password"   = var.symp_password
    "project_id" = var.symp_project
    "name"       = var.k8s_name
  }

  depends_on = [null_resource.create_k8s_cluster]
}

