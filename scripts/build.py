#!/usr/bin/env python3
"""Build akamai-docker images with automatic dependency resolution."""

import argparse
import subprocess
import sys

VARIANTS: dict[str, list[tuple[str, ...]]] = {
    "base":                    [("base",)],
    "cli":                     [("base",), ("base", "cli")],
    "adaptive-acceleration":   [("base",), ("base", "cli"), ("cli", "adaptive-acceleration")],
    "api-gateway":             [("base",), ("base", "cli"), ("cli", "api-gateway")],
    "appsec":                  [("base",), ("base", "cli"), ("cli", "appsec")],
    "cloudlets":               [("base",), ("base", "cli"), ("cli", "cloudlets")],
    "cps":                     [("base",), ("base", "cli"), ("cli", "cps")],
    "dns":                     [("base",), ("base", "cli"), ("cli", "dns")],
    "eaa":                     [("base",), ("base", "cli"), ("cli", "eaa")],
    "edgeworkers":             [("base",), ("base", "cli"), ("cli", "edgeworkers")],
    "firewall":                [("base",), ("base", "cli"), ("cli", "firewall")],
    "image-manager":           [("base",), ("base", "cli"), ("cli", "image-manager")],
    "jsonnet":                 [("base",), ("base", "cli"), ("cli", "jsonnet")],
    "property-manager":        [("base",), ("base", "cli"), ("cli", "property-manager")],
    "onboard":                 [("base",), ("base", "cli"), ("cli", "property-manager"), ("property-manager", "onboard")],
    "purge":                   [("base",), ("base", "cli"), ("cli", "purge")],
    "sandbox":                 [("base",), ("base", "cli"), ("cli", "sandbox")],
    "terraform-cli":           [("base",), ("base", "cli"), ("cli", "terraform-cli")],
    "etp":                     [("base",), ("base", "cli"), ("cli", "etp")],
    "gtm":                     [("base",), ("base", "cli"), ("cli", "gtm")],
    "test-center":             [("base",), ("base", "cli"), ("cli", "test-center")],
    "httpie":                  [("base",), ("base", "httpie")],
    "terraform":               [("base",), ("base", "terraform")],
}

DEFAULT_SHELL_DEPS: list[str] = [
    "cli", "adaptive-acceleration", "api-gateway", "appsec", "cloudlets", "cps", "dns",
    "eaa", "edgeworkers", "firewall", "httpie", "image-manager", "jsonnet", "property-manager",
    "onboard", "purge", "sandbox", "terraform", "terraform-cli", "etp", "gtm", "test-center"
]


def validate_no_conflicting_paths(calls: list[tuple[str, ...]]) -> None:
    """Ensures that no single target image can be built via conflicting paths."""
    built = {}
    for c in calls:
        if c[-1] in built:
            sys.exit(f"error: Conflicting build paths for '{c[-1]}'.\n  1: {built[c[-1]]}\n  2: {c}")
        built[c[-1]] = c


def resolve_shell_chain(spec: str) -> list[tuple[str, ...]]:
    """Parses, validates, and builds the dependency chain for a shell target."""
    deps = DEFAULT_SHELL_DEPS
    if ":" in spec:
        _, targets = spec.split(":", 1)
        deps = [s.strip() for s in targets.split(",") if s.strip()]

    for d in deps:
        if d not in VARIANTS:
            sys.exit(f"error: unknown dependency '{d}'")

    # Flatten and deduplicate preserving order via dict keys
    calls = list(dict.fromkeys(c for d in deps for c in VARIANTS[d]))
    validate_no_conflicting_paths(calls)
    calls.append(tuple(deps) + ("shell",))
    return calls


def run_build_chain(chain: tuple[str, ...], dry_run: bool) -> None:
    cmd = ["./scripts/build-chain.sh"] + list(chain)
    print(f"  $ {' '.join(cmd)}")
    if not dry_run:
        subprocess.run(cmd, check=True)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Build akamai-docker images with automatic dependency resolution.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="examples:\n  %(prog)s base\n  %(prog)s shell\n  %(prog)s \"shell:terraform,api-gateway\""
    )
    parser.add_argument("image", metavar="IMAGE", help="Image to build. Supports 'shell:img1,img2'.")
    parser.add_argument("--dry-run", action="store_true", help="Print commands without executing.")
    args = parser.parse_args()

    spec = args.image
    if spec == "shell" or spec.startswith("shell:"):
        calls = resolve_shell_chain(spec)
    elif spec in VARIANTS:
        calls = VARIANTS[spec]
    else:
        sys.exit(f"error: unknown image '{spec}'")

    print(f"Building '{spec.split(':', 1)[0]}': {' -> '.join(c[-1] for c in calls)}")
    for c in calls:
        run_build_chain(c, args.dry_run)


if __name__ == "__main__":
    main()
