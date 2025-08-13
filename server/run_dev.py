from sys import argv, stdout, stderr
from os import environ
from pathlib import Path
from time import sleep
from subprocess import Popen
from typing import Union, Optional
from argparse import ArgumentParser
from shutil import which

ROOT = Path(argv[0]).absolute().parent


def get_which(name: str) -> Path:
    result = which(name)
    assert result is not None, f"{name} not found"
    return Path(result)


pnpm = get_which("pnpm")
pnpx = get_which("pnpx")


def general_popen(
    *cmd: Union[str, Path], cwd: Path = ROOT, env_add: Optional[dict[str, str]] = None
):
    if env_add is None:
        env_add = {}
    new_env = environ.copy()
    new_env.update(env_add)
    return Popen(
        [str(c) for c in cmd], cwd=str(cwd), stdout=stdout, stderr=stderr, env=new_env
    )


def build_ts():
    return general_popen(pnpm, "run", "build", cwd=ROOT / "server")


def run_pocket_base():
    all_wait(
        general_popen(
            pnpx,
            "pocketbase-typegen",
            "--db",
            ROOT / "db" / "pb_data" / "data.db",
            "--out",
            ROOT / "types" / "pocketbase-types.d.ts",
        )
    )
    return general_popen(
        ROOT / "db" / "pocketbase.exe", "serve", "--http", "127.0.0.1:4133"
    )


def all_wait(*wait_list: Popen[bytes]):
    for p in wait_list:
        code = p.wait()
        if code != 0:
            raise ChildProcessError(f"Process {p.args} exited with code {code}")

def run_express_server():
    pocket_base = run_pocket_base()
    build_ts().wait()
    sleep(1)  # To make sure pocket base is ready to serve
    return (
        pocket_base,
        general_popen(
            "node",
            ROOT / "server" / "dist" / "main.mjs",
            env_add={
                "NODE_ENV": "development",
                "POCKETBASE_URL": "http://localhost:4133/",
            },
        ),
    )


def main():
    parser = ArgumentParser()
    parser.add_argument(
        "--gen-type",
        action="store_true",
        help="Generate TypeScript types for PocketBase",
    )
    parser.add_argument(
        "--production", "--prod", action="store_true", help="Run in production mode"
    )

    args = parser.parse_args()

    if args.gen_type:
        pocket_base = run_pocket_base()
        pocket_base.terminate()
    else:
        processes = run_express_server()
        try:
            all_wait(*processes)
        except KeyboardInterrupt:
            pass
        finally:
            for process in processes:
                process.terminate()


if __name__ == "__main__":
    main()
