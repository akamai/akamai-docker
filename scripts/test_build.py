#!/usr/bin/env python3
"""Unit tests for build.py."""

import subprocess
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).parent))
from build import (  # noqa: E402
    DEFAULT_SHELL_DEPS,
    VARIANTS,
    resolve_shell_chain,
    validate_no_conflicting_paths,
)

SCRIPT = Path(__file__).parent / "build.py"


class TestValidateNoConflictingPaths:
    def test_no_conflicts(self):
        calls = [("base",), ("base", "cli"), ("cli", "appsec")]
        validate_no_conflicting_paths(calls)  # should not raise

    def test_empty_calls(self):
        validate_no_conflicting_paths([])

    def test_single_call(self):
        validate_no_conflicting_paths([("base",)])

    def test_conflicting_paths_exits(self):
        calls = [("a", "target"), ("b", "target")]
        with pytest.raises(SystemExit, match="Conflicting build paths for 'target'"):
            validate_no_conflicting_paths(calls)

    def test_conflict_message_includes_both_paths(self):
        calls = [("a", "target"), ("b", "target")]
        with pytest.raises(SystemExit) as exc_info:
            validate_no_conflicting_paths(calls)
        msg = str(exc_info.value)
        assert "('a', 'target')" in msg
        assert "('b', 'target')" in msg


class TestResolveShellChain:
    def test_default_shell_includes_all_dep_targets(self):
        calls = resolve_shell_chain("shell")
        assert calls[-1][-1] == "shell"
        targets = {c[-1] for c in calls}
        for dep in DEFAULT_SHELL_DEPS:
            for variant in VARIANTS[dep]:
                assert variant[-1] in targets

    def test_shell_colon_selects_specific_deps(self):
        calls = resolve_shell_chain("shell:terraform,api-gateway")
        assert calls[-1] == ("terraform", "api-gateway", "shell")

    def test_shell_colon_only_includes_requested_variants(self):
        # terraform goes through base, not cli
        calls = resolve_shell_chain("shell:terraform")
        targets = {c[-1] for c in calls[:-1]}  # exclude the shell tuple itself
        for variant_tuple in VARIANTS["terraform"]:
            assert variant_tuple[-1] in targets
        assert "cli" not in targets

    def test_deduplication_on_shared_deps(self):
        # cli and appsec both include ("base",) — must appear only once
        calls = resolve_shell_chain("shell:cli,appsec")
        assert calls.count(("base",)) == 1

    def test_order_preserved(self):
        calls = resolve_shell_chain("shell:appsec")
        targets = [c[-1] for c in calls[:-1]]
        assert targets.index("base") < targets.index("cli")
        assert targets.index("cli") < targets.index("appsec")

    def test_onboard_deep_chain_order(self):
        calls = resolve_shell_chain("shell:onboard")
        targets = [c[-1] for c in calls[:-1]]
        assert targets.index("base") < targets.index("cli")
        assert targets.index("cli") < targets.index("property-manager")
        assert targets.index("property-manager") < targets.index("onboard")

    def test_shell_tuple_appended_last(self):
        calls = resolve_shell_chain("shell:cli")
        assert calls[-1][-1] == "shell"

    def test_whitespace_stripped_from_dep_names(self):
        calls = resolve_shell_chain("shell: terraform , api-gateway ")
        assert calls[-1] == ("terraform", "api-gateway", "shell")

    def test_unknown_dependency_exits(self):
        with pytest.raises(SystemExit, match="unknown dependency 'nonexistent'"):
            resolve_shell_chain("shell:nonexistent")

    def test_unknown_dep_in_list_exits(self):
        with pytest.raises(SystemExit, match="unknown dependency 'bad'"):
            resolve_shell_chain("shell:cli,bad")


class TestMainDryRun:
    def _run(self, *args):
        return subprocess.run(
            [sys.executable, str(SCRIPT)] + list(args),
            capture_output=True,
            text=True,
        )

    def _build_targets(self, stdout: str) -> list[str]:
        """Extract the last argument from each build-chain.sh invocation."""
        return [
            line.strip().split()[-1]
            for line in stdout.splitlines()
            if "build-chain.sh" in line
        ]

    # --- positive cases ---

    def test_base_prints_build_command(self):
        result = self._run("base", "--dry-run")
        assert result.returncode == 0
        assert "./scripts/build-chain.sh base" in result.stdout

    def test_base_summary_line(self):
        result = self._run("base", "--dry-run")
        assert "Building 'base':" in result.stdout

    def test_cli_chain_order(self):
        result = self._run("cli", "--dry-run")
        assert result.returncode == 0
        assert self._build_targets(result.stdout) == ["base", "cli"]

    def test_onboard_chain_order(self):
        result = self._run("onboard", "--dry-run")
        assert result.returncode == 0
        assert self._build_targets(result.stdout) == ["base", "cli", "property-manager", "onboard"]

    def test_shell_dry_run_prints_shell(self):
        result = self._run("shell", "--dry-run")
        assert result.returncode == 0
        assert "shell" in result.stdout

    def test_shell_subset_includes_only_requested(self):
        result = self._run("shell:terraform,api-gateway", "--dry-run")
        assert result.returncode == 0
        assert "terraform" in result.stdout
        assert "api-gateway" in result.stdout

    def test_shell_subset_summary_line(self):
        result = self._run("shell:terraform", "--dry-run")
        assert "Building 'shell':" in result.stdout

    def test_dry_run_does_not_execute_build_chain(self):
        # build-chain.sh won't be on PATH in the test runner's cwd;
        # returncode == 0 proves it was never invoked.
        result = self._run("base", "--dry-run")
        assert result.returncode == 0

    def test_httpie_bypasses_cli(self):
        # httpie goes through base only, not cli
        result = self._run("httpie", "--dry-run")
        assert result.returncode == 0
        targets = self._build_targets(result.stdout)
        assert "cli" not in targets
        assert "httpie" in targets

    # --- negative cases ---

    def test_unknown_image_exits_nonzero(self):
        result = self._run("nonexistent-image")
        assert result.returncode != 0

    def test_unknown_image_error_message(self):
        result = self._run("nonexistent-image")
        combined = result.stdout + result.stderr
        assert "unknown image 'nonexistent-image'" in combined

    def test_shell_unknown_dep_exits_nonzero(self):
        result = self._run("shell:bad-dep", "--dry-run")
        assert result.returncode != 0

    def test_shell_unknown_dep_error_message(self):
        result = self._run("shell:bad-dep", "--dry-run")
        combined = result.stdout + result.stderr
        assert "unknown dependency 'bad-dep'" in combined
