ocuroot("0.3.0")

load("./tasks.ocu.star", "up", "down", "build")

# Get all environments
envs = environments()
# Filter environments by type
staging = [e for e in envs if e.attributes["type"] == "staging"]
prod = [e for e in envs if e.attributes["type"] == "prod"]

phase(
    name="build",
    work=[
        call(
            fn=build,
            name="build",
            inputs={
                "build_number": input("./@/call/build#output/build_number", default=0),
            }
        )
    ],
)

# Staging deployment phase
phase(
    name="staging",
    work=[
        deploy(
            up=up,
            down=down,
            environment=environment,
            inputs={
                "build_number": ref("./call/build#output/build_number"),
                "message": ref("./call/build#output/message"),
                "kubeconfig_secret": ref("./-/kubernetes/release.ocu.star/@/deploy/{}#output/kubeconfig_secret".format(environment.name)),
                # Force a redeploy if the cluster is recreated
                "kubeconfig_sha256": ref("./-/kubernetes/release.ocu.star/@/deploy/{}#output/kubeconfig_sha256".format(environment.name)),
            },
        ) for environment in staging
    ],
)

# Production deployment phase
phase(
    name="production",
    work=[
        deploy(
            up=up,
            down=down,
            environment=environment,
            inputs={
                "build_number": ref("./call/build#output/build_number"),
                "message": ref("./call/build#output/message"),
                "kubeconfig_secret": ref("./-/kubernetes/release.ocu.star/@/deploy/{}#output/kubeconfig_secret".format(environment.name)),
                # Force a redeploy if the cluster is recreated
                "kubeconfig_sha256": ref("./-/kubernetes/release.ocu.star/@/deploy/{}#output/kubeconfig_sha256".format(environment.name)),
            },
        ) for environment in prod
    ],
)
