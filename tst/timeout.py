#!/usr/bin/env python3
"""Run a command with a wall deadline; kill its process group, including ACE.

Usage: python3 tst/timeout.py SECONDS COMMAND [ARG ...]
This is deliberately outside GAP: a blocked stream read defeats engine limits.
"""
import os
import signal
import subprocess
import sys


def main():
    seconds = float(sys.argv[1])
    process = subprocess.Popen(sys.argv[2:], start_new_session=True)
    try:
        return process.wait(timeout=seconds)
    except subprocess.TimeoutExpired:
        print(f"TIMEOUT after {seconds:g}s: {sys.argv[2:]}", file=sys.stderr)
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
