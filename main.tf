terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "orbstack"
}

variable "cost_center" {
  type    = string
  default = "1"
}

variable "image_tag" {
  type    = string
  default = "1.0.0"
}

resource "kubernetes_namespace_v1" "app_ns" {
  metadata {
    name = "dual-repo-hello-world"
    labels = {
      "app"         = "dual-repo-hello-world"
      "cost-center" = var.cost_center
      "managed-by"  = "terraform"
    }
  }
}

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = "dual-repo-hello-world"
    namespace = kubernetes_namespace_v1.app_ns.metadata[0].name
    labels = {
      "app"         = "dual-repo-hello-world"
      "cost-center" = var.cost_center
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "dual-repo-hello-world"
      }
    }
    template {
      metadata {
        labels = {
          app           = "dual-repo-hello-world"
          "cost-center" = var.cost_center
        }
      }
      spec {
        container {
          name              = "dual-repo-hello-world"
          image             = "dual-repo-hello-world:${var.image_tag}"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "app_svc" {
  metadata {
    name      = "dual-repo-hello-world-svc"
    namespace = kubernetes_namespace_v1.app_ns.metadata[0].name
  }
  spec {
    selector = {
      app = "dual-repo-hello-world"
    }
    type = "NodePort"
    port {
      port        = 8080
      target_port = 8080
      node_port   = 30080
    }
  }
}