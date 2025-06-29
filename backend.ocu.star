ocuroot("0.3.0")

load("./tasks.ocu.star", "build", "backend_up", "down")

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
            up=backend_up,
            down=down,
            environment=environment,
        ) for environment in dev
    ],
)

# Staging deployment phase
phase(
    name="staging",
    work=[
        deploy(
            up=backend_up,
            down=down,
            environment=environment,
        ) for environment in staging
    ],
)

# Production deployment phase
phase(
    name="production",
    work=[
        deploy(
            up=backend_up,
            down=down,
            environment=environment,
        ) for environment in prod
    ],
)
