# helm.tf
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

resource "helm_release" "static_web" {
  name  = "static-web"
  chart = "../static-web" # 相對路徑指向你的 Helm Chart 資料夾
  values = [
    file("../static-web/values.yaml")
  ]
  namespace  = "default"
  depends_on = [module.eks] # 確保 EKS 叢集建立後再部署
}