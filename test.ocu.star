ocuroot("0.3.0")

load("infisical.star", "setup_infisical")

def test(ctx):
    infisical = setup_infisical(project_id="f7b78b62-9edc-4b41-bc87-37c80b350c10", default_env="prod")

    key = infisical.get("EXAMPLE_KEY")
    print("We got a key of length " + str(len(key)))

    print("This is a test!")
    return done(
        outputs={
            "test": "test",
        },
    )

phase(
    "test",
    work=[
        call(fn=test, name="test")
    ]
)