ocuroot("0.3.0")

repo_alias("github.com/ocuroot/k8s-demo")

def init_repo():
    # Default to ssh for local testing
    repo_url = "ssh://git@github.com/ocuroot/k8s-demo.git"

    # Always use https for checkout with GitHub actions
    env_vars = host.env()
    if "GITHUB_ACTIONS" in env_vars:
        repo_url = "https://github.com/ocuroot/k8s-demo.git"

    store.set(
        store.git(repo_url, branch="state"),
    )

init_repo()