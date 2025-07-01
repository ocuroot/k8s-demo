ocuroot("0.3.0")

load("./tasks.ocu.star", "up", "down", "build")

# Get all environments
envs = environments()
# Filter environments by type
dev = [e for e in envs if e.attributes["type"] == "development"]
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

# Development deployment phase
phase(
    name="dev",
    work=[
        deploy(
            up=up,
            down=down,
            environment=environment,
            inputs={
                "build_number": ref("./call/build#output/build_number"),
                "message": ref("./call/build#output/message"),
                "kubeconfig_secret": ref("./-/kubernetes/release.ocu.star/@/deploy/{}#output/kubeconfig_secret".format(environment.name)),
            },
        ) for environment in dev
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
            },
        ) for environment in prod
    ],
)
