ocuroot("0.3.0")

def setup_k8s(environment, kubeconfig):
    # Check if Go is installed and error out if not
    if host.shell("which kubectl", continue_on_error=True).exit_code != 0:
        fail("kubectl is not installed")
        return

    kubeconfig_path_relative = "../.ocuroot/tmp/{}/kubeconfig".format(environment.name)
    host.shell(
        "printenv KUBECONFIG > $KUBECONFIG_PATH",
        mute=True, 
        env={
            "KUBECONFIG": kubeconfig,
            "KUBECONFIG_PATH": kubeconfig_path_relative,
        },
    )    
    
    def exec(cmd, env={}, mute=False, continue_on_error=False):
        newEnv = env
        newEnv["KUBECONFIG"] = kubeconfig_path_relative
        
        return host.shell(
            cmd,
            env=newEnv,
            mute=mute,
            continue_on_error=continue_on_error,
        )

    return struct(
        exec=exec
    )

def setup_helm(environment, kubeconfig):
    # Check if Go is installed and error out if not
    if host.shell("which helm", continue_on_error=True).exit_code != 0:
        fail("helm is not installed")
        return

    kubeconfig_path_relative = "../.ocuroot/tmp/{}/kubeconfig".format(environment.name)
    
    host.shell(
        "printenv KUBECONFIG > $KUBECONFIG_PATH",
        mute=True, 
        env={
            "KUBECONFIG": kubeconfig,
            "KUBECONFIG_PATH": kubeconfig_path_relative,
        },
    )    

    def exec(cmd, env={}, mute=False, continue_on_error=False):
        newEnv = env
        newEnv["KUBECONFIG"] = kubeconfig_path_relative
        
        return host.shell(
            cmd,
            env=newEnv,
            mute=mute,
            continue_on_error=continue_on_error,
        )
    
    return struct(
        exec=exec
    )