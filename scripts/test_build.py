#!/usr/bin/env python3


import subprocess
import sys
from pathlib import Path

import pytest
from build import validate_no_conflicting_paths


SCRIPT = Path(__file__).parent / "build.py"


def run_dry(image: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        [sys.executable, str(SCRIPT), image, "--dry-run"],
        capture_output=True,
        text=True,
    )


DRY_RUN_CASES = [
    (
        "base",
        "Building 'base': base\n"
        "  $ ./scripts/build-chain.sh base\n",
    ),
    (
        "cli",
        "Building 'cli': base -> cli\n"
        "  $ ./scripts/build-chain.sh base\n"
        "  $ ./scripts/build-chain.sh base cli\n",
    ),
    (
        "httpie",
        "Building 'httpie': base -> httpie\n"
        "  $ ./scripts/build-chain.sh base\n"
        "  $ ./scripts/build-chain.sh base httpie\n",
    ),
    (
        "onboard",
        "Building 'onboard': base -> cli -> property-manager -> onboard\n"
        "  $ ./scripts/build-chain.sh base\n"
        "  $ ./scripts/build-chain.sh base cli\n"
        "  $ ./scripts/build-chain.sh cli property-manager\n"
        "  $ ./scripts/build-chain.sh property-manager onboard\n",
    ),
    (
        "terraform",
        "Building 'terraform': base -> terraform\n"
        "  $ ./scripts/build-chain.sh base\n"
        "  $ ./scripts/build-chain.sh base terraform\n",
    ),
    (
        "shell:terraform",
        "Building 'shell': base -> terraform -> shell\n"
        "  $ ./scripts/build-chain.sh base\n"
        "  $ ./scripts/build-chain.sh base terraform\n"
        "  $ ./scripts/build-chain.sh terraform shell\n",
    ),
    (
        "shell:terraform,api-gateway",
        "Building 'shell': base -> terraform -> cli -> api-gateway -> shell\n"
        "  $ ./scripts/build-chain.sh base\n"
        "  $ ./scripts/build-chain.sh base terraform\n"
        "  $ ./scripts/build-chain.sh base cli\n"
        "  $ ./scripts/build-chain.sh cli api-gateway\n"
        "  $ ./scripts/build-chain.sh terraform api-gateway shell\n",
    ),
]


@pytest.mark.parametrize("image,expected_output", DRY_RUN_CASES)
def test_dry_run(image, expected_output):
    result = run_dry(image)
    assert result.returncode == 0
    assert result.stdout == expected_output


class TestValidateNoConflictingPaths:
    def test_conflicting_paths_exits_with_error(self):
        calls = [("a", "target"), ("b", "target")]
        with pytest.raises(SystemExit) as exc_info:
            validate_no_conflicting_paths(calls)
        msg = str(exc_info.value)
        assert "Conflicting build paths for 'target'" in msg
        assert "('a', 'target')" in msg
        assert "('b', 'target')" in msg

    def test_no_conflicts_passes(self):
        validate_no_conflicting_paths([("base",), ("base", "cli"), ("cli", "appsec")])


class TestEdgeCases:
    def test_unknown_image_exits_with_error(self):
        result = subprocess.run(
            [sys.executable, str(SCRIPT), "nonexistent-image"],
            capture_output=True, text=True,
        )
        assert result.returncode != 0
        assert "unknown image 'nonexistent-image'" in result.stdout + result.stderr

    def test_shell_unknown_dep_exits_with_error(self):
        result = run_dry("shell:bad-dep")
        assert result.returncode != 0
        assert "unknown dependency 'bad-dep'" in result.stdout + result.stderr

    def test_shell_whitespace_in_deps_is_stripped(self):
        result = run_dry("shell: terraform , api-gateway ")
        assert result.returncode == 0

    def test_no_args_exits_with_error(self):
        result = subprocess.run(
            [sys.executable, str(SCRIPT)],
            capture_output=True, text=True,
        )
        assert result.returncode != 0

    def test_shell_with_empty_dep_list_builds_only_shell(self):
        result = run_dry("shell:")
        assert result.returncode == 0
        assert result.stdout == "Building 'shell': shell\n  $ ./scripts/build-chain.sh shell\n"
