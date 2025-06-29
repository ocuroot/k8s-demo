ocuroot("0.3.0")

load("./tasks.ocu.star", "build", "frontend_up", "down")

# Get all environments
envs = environments()
# Filter environments by type
dev = [e for e in envs if e.attributes["type"] == "development"]
staging = [e for e in envs if e.attributes["type"] == "staging"]
prod = [e for e in envs if e.attributes["type"] == "prod"]

# Build phase
phase(
    name="build",
    work=[call(build, name="build")],
)

# Development deployment phase
phase(
    name="dev",
    work=[
        deploy(
            up=frontend_up,
            down=down,
            environment=environment,
            inputs={
                # Get the backend URL from the backend's deployment to the same environment
                "backend_url": input(
                    ref="github.com/ocuroot/k8s-demo/-/backend.ocu.star/@/deploy/{}#output/url".format(environment.name),
                    doc="URL of the backend service for this environment",
                ),
            },
        ) for environment in dev
    ],
)

# Staging deployment phase
phase(
    name="staging",
    work=[
        deploy(
            up=frontend_up,
            down=down,
            environment=environment,
            inputs={
                # Get the backend URL from the backend's staging deployment
                "backend_url": input(
                    ref="github.com/ocuroot/k8s-demo/-/backend.ocu.star/@/deploy/{}#output/url".format(environment.name),
                    doc="URL of the backend service for this environment",
                ),
            },
        ) for environment in staging
    ],
)

# Production deployment phase
phase(
    name="production",
    work=[
        deploy(
            up=frontend_up,
            down=down,
            environment=environment,
            inputs={
                # Get the backend URL from the backend's production deployment
                "backend_url": input(
                    ref="github.com/ocuroot/k8s-demo/-/backend.ocu.star/@/deploy/{}#output/url".format(environment.name),
                    doc="URL of the backend service for production",
                ),
            },
        ) for environment in prod
    ],
)
