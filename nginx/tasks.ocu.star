ocuroot("0.3.0")

load("../kubernetes.star", "setup_helm", "setup_k8s")
load("../infisical.star", "setup_infisical")

def build(ctx):
    message = host.shell("cat message.txt", mute=True).stdout.strip()
    print("Message is: {}".format(message))
    print("Build number is: {}".format(ctx.inputs.build_number))
    return done(
        outputs={
            "message": message,
            "build_number": ctx.inputs.build_number + 1,
        }
    )

def up(ctx):
    """Deploy nginx using our custom Helm chart"""
    env = environment_from_dict(ctx.inputs.environment)
    env_name = env.name
    
    print("Deploying nginx to {} environment".format(env_name))
    
    # Get infisical from the kubernetes release
    infisical = setup_infisical(project_id="f7b78b62-9edc-4b41-bc87-37c80b350c10")
    
    # Get kubeconfig from infisical
    kubeconfig_secret = ctx.inputs.kubeconfig_secret
    print("Retrieving kubeconfig from Infisical using key {}".format(kubeconfig_secret))
    kubeconfig = infisical.get(kubeconfig_secret, env=env.attributes["infisical_env"])
    
    if not kubeconfig or len(kubeconfig) < 100:
        fail("Retrieved kubeconfig appears invalid or too short")
    
    print("Successfully retrieved kubeconfig")
    
    # Setup helm
    helm = setup_helm(env, kubeconfig)
    
    # Setup kubernetes client for some operations
    k8s = setup_k8s(env, kubeconfig)
    
    # Test cluster connectivity before proceeding
    print("Testing cluster connectivity...")
    result = k8s.exec("kubectl version", continue_on_error=True, mute=False)
    
    if result.exit_code != 0:
        fail("Cannot connect to Kubernetes cluster. Please check that the cluster is running and the kubeconfig is valid.")
    
    # Create namespace if it doesn't exist
    print("Creating namespace if it doesn't exist...")
    k8s.exec(
        "kubectl create namespace nginx --dry-run=client -o yaml | kubectl apply -f -",
        mute=False
    )
    
    # Add bitnami repository if it doesn't exist
    print("Adding bitnami Helm repository...")
    helm.exec(
        "helm repo add bitnami https://charts.bitnami.com/bitnami",
        mute=False
    )
    helm.exec("helm repo update", mute=False)
    
    # First update dependencies to pull in nginx chart
    print("Updating Helm chart dependencies...")
    helm.exec(
        "cd ../nginx/chart && helm dependency update",
        mute=False
    )
    
    # Install our custom Helm chart without waiting for LoadBalancer
    print("Installing nginx via custom Helm chart in {} environment...".format(env_name))
    # Generate a consistent load balancer ID based on environment name
    loadbalancer_id = "k8s-nginx-{}".format(env_name)
    
    result = helm.exec(
        """helm upgrade --install nginx-custom ../nginx/chart \
        --namespace nginx \
        --set htmlMessage="$MESSAGE" \
        --set envName="$ENV_NAME" \
        --set buildNumber="$BUILD_NUMBER" \
        --set nginx.extraVolumeMounts[0].name=custom-html \
        --set nginx.extraVolumeMounts[0].mountPath=/app \
        --set nginx.extraVolumes[0].name=custom-html \
        --set nginx.extraVolumes[0].configMap.name=nginx-custom-html-content \
        --set-string nginx.service.annotations.kubernetes\.digitalocean\.com/load-balancer-id=$LOADBALANCER_ID""",
        env={
            "MESSAGE": ctx.inputs.message,
            "ENV_NAME": env_name.upper(),
            "BUILD_NUMBER": str(ctx.inputs.build_number),
            "LOADBALANCER_ID": loadbalancer_id,
        },
        mute=False
    )
    
    # Get the list of services to find the correct name
    print("Finding nginx service...")
    result = k8s.exec(
        "kubectl get services -n nginx -o custom-columns=':metadata.name' --no-headers",
        mute=False
    )
    
    services = result.stdout.strip().split('\n')
    nginx_service = None
    for service in services:
        if "nginx" in service:
            nginx_service = service
            break
    
    if not nginx_service:
        fail("Could not find nginx service")
    
    print("Found nginx service: {}".format(nginx_service))
    
    # Wait for the pods to be ready
    print("Waiting for nginx pods to be ready...")
    k8s.exec(
        "kubectl wait --namespace=nginx --for=condition=ready pod -l app.kubernetes.io/instance=nginx-custom --timeout=90s",
        mute=False,
        continue_on_error=True
    )
    
    # Check for LoadBalancer IP (but don't wait indefinitely)
    print("Checking for LoadBalancer IP assignment...")
    result = k8s.exec(
        "kubectl get service {} -n nginx -o jsonpath='{{.status.loadBalancer.ingress[0].ip}}'".format(nginx_service),
        mute=False,
        continue_on_error=True
    )
    
    if result.exit_code != 0:
        fail("Failed to deploy nginx via Helm: {}".format(result.stderr))
        return
    
    # Get the LoadBalancer IP
    print("Getting LoadBalancer IP...")
    result = k8s.exec(
        "kubectl get service nginx-custom -n nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}'",
        mute=False,
        continue_on_error=True
    )
    
    service_ip = result.stdout.strip()
    if not service_ip:
        # Try hostname instead of IP
        result = k8s.exec(
            "kubectl get service nginx-custom -n nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'",
            mute=False,
            continue_on_error=True
        )
        service_ip = result.stdout.strip()
    
    # Get LoadBalancer ID for reference
    lb_id = ""
    result = k8s.exec(
        "kubectl get service nginx-custom -n nginx -o jsonpath='{.metadata.annotations.service\\.beta\\.kubernetes\\.io/vultr-loadbalancer-id}'",
        mute=False,
        continue_on_error=True
    )
    if result.stdout.strip():
        lb_id = result.stdout.strip()
        print("LoadBalancer ID: {}".format(lb_id))
    
    service_url = "http://{}".format(service_ip) if service_ip else ""
    
    print("Nginx deployment completed in {} environment.".format(env_name))
    if service_ip:
        print("Access the service at: {}".format(service_url))
    else:
        print("LoadBalancer IP not yet assigned. To check status:")
        print("kubectl get service nginx-custom -n nginx")
    
    return done(
        outputs={
            "loadbalancer_ip": service_ip,
            "loadbalancer_id": lb_id,
            "service_url": service_url,
        },
    )

def down(ctx):
    """Destroy the nginx deployment"""
    env = environment_from_dict(ctx.inputs.environment)
    env_name = env.name
    
    # Get infisical from the kubernetes release
    infisical = setup_infisical(project_id="f7b78b62-9edc-4b41-bc87-37c80b350c10")
    
    # Get kubeconfig from infisical
    kubeconfig_secret = ctx.inputs.kubeconfig_secret
    kubeconfig = infisical.get(kubeconfig_secret, env=env.attributes["infisical_env"])
    
    # Setup helm
    helm = setup_helm(env, kubeconfig)
    
    print("Destroying nginx from {} environment...".format(env_name))
    
    # Delete the Helm release
    result = helm.exec(
        "helm uninstall nginx-custom --namespace nginx",
        mute=False,
        continue_on_error=True
    )
    
    print("Nginx destroyed successfully from {} environment".format(env_name))
    
    return done()
