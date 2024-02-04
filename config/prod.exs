import Config

config :test, abs_path: "/app/data/"

config :libcluster,
  topologies: [
    k8s: [
      strategy: Cluster.Strategy.Kubernetes,
      config: [
        mode: :hostname,
        kubernetes_ip_lookup_mode: :pods,
        kubernetes_service_name: "mnesiac-cluster",
        kubernetes_node_basename: "mnesiac-example",
        kubernetes_selector: "cluster=mnesiac",
        kubernetes_namespace: "default"
      ]
    ]
  ]
