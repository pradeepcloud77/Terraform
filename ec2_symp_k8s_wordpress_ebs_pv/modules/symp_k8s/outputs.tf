output "k8s_nodes_ids" {
  value = formatlist(
    "i-%s",
    split(
      ",",
      replace(data.external.k8s_info.result["nodes_id"], "-", ""),
    ),
  )
}

# This is passed out to allow dependency in this cluster
output "k8s_cluster_id" {
  value = null_resource.k8s_config_file.id
}

