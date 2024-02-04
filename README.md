# Mnesiac with Kubernetes

## Finally! Distributed Mnesia with Kubernetes!

This is a working example of using [Mnesiac](https://github.com/beardedeagle/mnesiac) clustered with [Libcluster](https://github.com/bitwalker/libcluster) using StatefulSet k8s configuration.

It implements a dummy writer that just keeps adding to a counter every 5 seconds.

Every pod is writing to the same counter, when you rollout to a new image, the state is kept correctly.

## Running

### You can find kubernetes manifests here [.k8s](.k8s)

You need to change in [config/prod.exs](config/prod.exs) the path that is going to be used by mnesia and your StatefulSet claim.

> config :test, abs_path: "/app/data/"

You also need to change [rel/env.sh.eex](rel/env.sh.eex) with the correct RELEASE_NODE attribute matching your k8s libcluster configuration, pv/pvc and statefulset.

> export RELEASE_NODE=mnesiac-example@$POD_NAME.mnesiac-cluster.default.svc.cluster.local

This example is using k3d, you need to setup a cluster and then do the following commands:

```BASH
k3d cluster create # if not yet created

kubectl apply -f .k8s/role.yaml
kubectl apply -f .k8s/role-binding.yaml
kubectl apply -f .k8s/pv.yaml
kubectl apply -f .k8s/pvc.yaml

docker build -t mnesiac-example .
k3d image import mnesiac-example

kubectl apply -f .k8s/statefulset.yaml
```

## Notes
- [lib/store.ex](lib/store.ex) - This is the most important part. The overrides needs to be configured exactly the way it is to work. It was very hard to figure that out but apparently this works well in rollouts.

- [lib/application.ex](lib/application.ex) - Very important to set that abs_path hacky stuff.

- [lib/healthcheck/router.ex](lib/healthcheck/router.ex) - Bandit was used just to setup a basic healthcheck, its always recommended to work with a healthcheck when working with StatefulSets.
