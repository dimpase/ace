#!/usr/bin/env python3
"""Run a command with a wall deadline; kill descendants, including ACE.

Usage: python3 tst/timeout.py SECONDS COMMAND [ARG ...]
This is deliberately outside GAP: a blocked stream read defeats engine limits.
"""
import os
import signal
import subprocess
import sys


def descendants(pid):
    # GAP puts its pty child in a separate process group. Killing only GAP's
    # group would leave a hung enumerator behind. Snapshot before killing GAP.
    rows = subprocess.check_output(["ps", "-axo", "pid=,ppid="], text=True)
    pairs = [tuple(map(int, row.split())) for row in rows.splitlines()]
    found = {pid}
    while True:
        children = {child for child, parent in pairs if parent in found}
        if children <= found:
            return found - {pid}
        found.update(children)


def main():
    seconds = float(sys.argv[1])
    process = subprocess.Popen(sys.argv[2:], start_new_session=True)
    try:
        return process.wait(timeout=seconds)
    except subprocess.TimeoutExpired:
        print(f"TIMEOUT after {seconds:g}s: {sys.argv[2:]}", file=sys.stderr)
        for child in descendants(process.pid):
            try:
                os.kill(child, signal.SIGKILL)
            except ProcessLookupError:
                pass
        return 124
    finally:
        # Also clean up descendants if GAP exits early following an error.
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        process.wait()


if __name__ == "__main__":
    sys.exit(main())
