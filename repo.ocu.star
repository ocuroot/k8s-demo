ocuroot("0.3.0")

repo_alias("github.com/ocuroot/k8s-demo")

def init_repo():
    origin_url = host.shell("git remote get-url origin", mute=True).stdout.strip()
    store.set(
        store.git(origin_url, branch="state"),
    )

init_repo()