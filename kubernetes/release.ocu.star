ocuroot("0.3.0")

load("../terraform.star", "setup_tf")
load("../infisical.star", "setup_infisical")

# Get all environments
envs = environments()
# Filter environments by type
dev = [e for e in envs if e.attributes["type"] == "development"]
staging = [e for e in envs if e.attributes["type"] == "staging"]
prod = [e for e in envs if e.attributes["type"] == "prod"]

def review(ctx):
    infisical = setup_infisical(project_id="f7b78b62-9edc-4b41-bc87-37c80b350c10")
    dev_env = struct(
        name = "dev",
    )
    tf = setup_tf({}, dev_env, "kubernetes", infisical)

    # HA
    tf.validate(
        vars = {
            "do_token": infisical.get("K8S_DEMO_DO_TOKEN"),
            "min_nodes": "2",
            "max_nodes": "6",
        }
    )

    # Non-HA
    tf.validate(
        vars = {
            "do_token": infisical.get("K8S_DEMO_DO_TOKEN"),
            "min_nodes": "1",
            "max_nodes": "2",
        }
    )
    return done()

phase(
    name="review",
    work=[call(review, name="review")],
)

def _deploy(ctx):
    infisical = setup_infisical(project_id="f7b78b62-9edc-4b41-bc87-37c80b350c10")
    tf = setup_tf({}, environment_from_dict(ctx.inputs.environment), "kubernetes", infisical)
    outputs = tf.apply(vars = {
        "do_token": infisical.get("K8S_DEMO_DO_TOKEN"),
        "min_nodes": "2",
        "max_nodes": "4",
    })

    env_name = ctx.inputs.environment["name"]
    secret_name = "K8S_DEMO_KUBECONFIG"
    infisical.set(secret_name, outputs["kubeconfig"], env=ctx.inputs.environment["attributes"]["infisical_env"])

    return done(
        outputs={
            "env_name": outputs["env_name"],
            "kubeconfig_secret": secret_name,
        },
    )

def _destroy(ctx):
    infisical = setup_infisical(project_id="f7b78b62-9edc-4b41-bc87-37c80b350c10")
    tf = setup_tf({}, environment_from_dict(ctx.inputs.environment), "kubernetes", infisical)
    outputs = tf.destroy(vars = {
        "do_token": infisical.get("K8S_DEMO_DO_TOKEN"),
    })
    # Clear the secret
    res = infisical.delete("K8S_DEMO_KUBECONFIG", env=ctx.inputs.environment["attributes"]["infisical_env"])
    if res.exit_code != 0:
        print("Failed to delete secret")
        print(res.stdout)
    return done()

# Staging deployment phase
phase(
    name="staging",
    work=[
        deploy(
            up=_deploy,
            down=_destroy,
            environment=environment,
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
        ) for environment in prod
    ],
)
