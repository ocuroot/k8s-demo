ocuroot("0.3.0")

load("../kubernetes.star", "setup_helm", "setup_k8s")
load("../infisical.star", "setup_infisical")
load("./tasks.ocu.star", "_deploy", "_destroy")

# Get all environments
envs = environments()
# Filter environments by type
dev = [e for e in envs if e.attributes["type"] == "development"]
staging = [e for e in envs if e.attributes["type"] == "staging"]
prod = [e for e in envs if e.attributes["type"] == "prod"]

# Constant HTML message for the heading
HTML_MESSAGE = "Welcome to Nginx deployed by Ocuroot!"

# Development deployment phase
phase(
    name="dev",
    work=[
        deploy(
            up=_deploy,
            down=_destroy,
            environment=environment,
            inputs={
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
            up=_deploy,
            down=_destroy,
            environment=environment,
            inputs={
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
            up=_deploy,
            down=_destroy,
            environment=environment,
            inputs={
                "kubeconfig_secret": ref("./-/kubernetes/release.ocu.star/@/deploy/{}#output/kubeconfig_secret".format(environment.name)),
            },
        ) for environment in prod
    ],
)
