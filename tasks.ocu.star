ocuroot("0.3.0")

def build(ctx):
    print("Building application")
    # Simulate a build process
    host.shell("sleep 1")
    
    return done(
        outputs={
            "version": "1.0.0",
            "timestamp": str(host.now()),
        },
    )

# Backend deployment function
def backend_up(ctx):
    print("Deploying backend to environment: {}".format(ctx.environment.name))
    # Generate a unique port for this backend deployment
    port = 8000 + (hash(ctx.environment.name) % 1000)
    
    return done(
        outputs={
            "env_name": ctx.environment.name,
            "deploy_time": str(host.now()),
            "count": ctx.inputs.previous_count + 1,
            "url": "http://backend-{}.example.com".format(ctx.environment.name),
            "port": port,
            "version": ctx.inputs.version,
        },
    )

# Frontend deployment function
def frontend_up(ctx):
    print("Deploying frontend to environment: {}".format(ctx.environment.name))
    print("Using backend URL: {}".format(ctx.inputs.backend_url))
    
    return done(
        outputs={
            "env_name": ctx.environment.name,
            "deploy_time": str(host.now()),
            "count": ctx.inputs.previous_count + 1,
            "version": ctx.inputs.version,
            "backend_url": ctx.inputs.backend_url,
        },
    )

# Common down function
def down(ctx):
    print("Tearing down from environment: {}".format(ctx.environment.name))
    # Simulate teardown process
    host.shell("sleep 1")
    
    return done(
        outputs={
            "success": True,
        },
    )
