ocuroot("0.3.0")

def build(ctx):
    print("Building application")
    # Simulate a build process
    host.shell("sleep 1")
    
    return done(
        outputs={
            "version": "1.0.0",
        },
    )

# Backend deployment function
def backend_up(ctx):
    print("Deploying backend to environment: {}".format(ctx.inputs.environment["name"]))
    # Generate a unique port for this backend deployment
    port = 8000 + (hash(ctx.inputs.environment["name"]) % 1000)
    
    return done(
        outputs={
            "env_name": ctx.inputs.environment["name"],
            "url": "http://backend-{}.example.com".format(ctx.inputs.environment["name"]),
            "port": port,
        },
    )

# Frontend deployment function
def frontend_up(ctx):
    print("Deploying frontend to environment: {}".format(ctx.inputs.environment["name"]))
    print("Using backend URL: {}".format(ctx.inputs.backend_url))
    
    return done(
        outputs={
            "env_name": ctx.inputs.environment["name"],
            "frontend_url": "http://frontend-{}.example.com".format(ctx.inputs.environment["name"]),
        },
    )

# Common down function
def down(ctx):
    print("Tearing down from environment: {}".format(ctx.inputs.environment["name"]))
    # Simulate teardown process
    host.shell("sleep 1")
    
    return done(
        outputs={
            "success": True,
        },
    )
