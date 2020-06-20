provider "kubernetes" {
  config_path = var.k8s_configfile_path
}

resource "null_resource" "depenecy_nothing" {
  triggers = {
    cluster_k8s_id = var.k8s_cluster_dependency_id
    eip_k8s_id     = var.k8s_cluster_eip_id
  }
}

resource "kubernetes_secret" "mysql-pass" {
  metadata {
    name = "mysql-pass"
  }

  data = {
    username = var.db_user
    password = var.db_password
  }

  type       = "Opaque"
  depends_on = [null_resource.depenecy_nothing]
}

resource "kubernetes_persistent_volume_claim" "wp_pv_claim" {
  metadata {
    name = "wp-pv-claim-demo"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
  wait_until_bound = false
  depends_on       = [null_resource.depenecy_nothing]
}

resource "kubernetes_deployment" "wp_deployment" {
  metadata {
    name = "wordpress"
    labels = {
      "app" = "wordpress"
    }
  }
  spec {
    selector {
      match_labels = {
        "app"  = "wordpress"
        "tier" = "frontend"
      }
    }

    //    strategy {
    //      type = "Recreate"
    //    }
    template {
      metadata {
        labels = {
          "app"  = "wordpress"
          "tier" = "frontend"
        }
      }
      spec {
        container {
          name  = "wordpress"
          image = var.wordpress_image
          env {
            name  = "WORDPRESS_DB_HOST"
            value = var.db_host
          }
          env {
            name  = "WORDPRESS_DB_NAME"
            value = var.db_name
          }
          env {
            name  = "WORDPRESS_DB_USER"
            value = var.db_user
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql-pass.metadata[0].name
                key  = "password"
              }
            }
          }
          port {
            container_port = 80
            name           = "wordpress"
          }
          readiness_probe {
            http_get {
              path = "/"
              port = "80"
            }
            initial_delay_seconds = 60
            failure_threshold     = 5
          }
          volume_mount {
            mount_path = "/var/www/html"
            name       = "wordpress-persistent-storage"
          }
        }
        volume {
          name = "wordpress-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.wp_pv_claim.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "wp_service" {
  metadata {
    name = "wp-service-demo"
    labels = {
      "app" = "wordpress"
    }
  }
  spec {
    selector = {
      "app"  = "wordpress"
      "tier" = "frontend"
    }
    port {
      port = kubernetes_deployment.wp_deployment.spec[0].template[0].spec[0].container[0].port[0].container_port
    }

    type = "NodePort"
  }
}

