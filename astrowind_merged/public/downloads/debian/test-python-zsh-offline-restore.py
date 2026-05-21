#!/usr/bin/env python3
import importlib.util
import io
import os
import shutil
import stat
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path


def fail(message: str) -> None:
    print(f"[FAIL] {message}", file=sys.stderr)
    raise SystemExit(1)


def require_tool(name: str) -> str:
    path = shutil.which(name)
    if not path:
        fail(f"missing required tool for test: {name}")
    return path


def symlink_tool(bin_dir: Path, name: str) -> None:
    target = require_tool(name)
    link = bin_dir / name
    if not link.exists():
        link.symlink_to(target)


def write_executable(path: Path, text: str) -> None:
    path.write_text(text, encoding="utf-8")
    path.chmod(path.stat().st_mode | stat.S_IXUSR)


def create_fixture_source(tmp: Path) -> tuple[Path, Path, Path]:
    omz = tmp / "fixture-omz"
    tools = omz / "tools"
    custom = omz / "custom"
    plugin = custom / "plugins" / "demo"
    theme = custom / "themes"
    zshrc = tmp / "source.zshrc"
    p10k = tmp / "source.p10k.zsh"

    tools.mkdir(parents=True)
    plugin.mkdir(parents=True)
    theme.mkdir(parents=True)
    (omz / "lib").mkdir()
    (omz / ".git").mkdir()
    (custom / "completions").mkdir()
    (plugin / ".git").mkdir()

    write_executable(
        tools / "install.sh",
        """#!/bin/sh
FMT_BLUE=''
FMT_RESET=''

fmt_error() {
  printf '%s\\n' "$*" >&2
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

setup_ohmyzsh() {
  git init "$ZSH"
  git fetch origin
}

setup_zshrc() {
  :
}

setup_ohmyzsh
setup_zshrc
""",
    )

    (omz / "lib" / "core.zsh").write_text("echo core\n", encoding="utf-8")
    (omz / ".git" / "config").write_text("[core]\n", encoding="utf-8")
    (omz / "compiled.zwc").write_text("skip\n", encoding="utf-8")
    (plugin / "demo.plugin.zsh").write_text("demo_plugin=1\n", encoding="utf-8")
    (plugin / ".git" / "config").write_text("[core]\n", encoding="utf-8")
    (theme / "demo.zsh-theme").write_text("PROMPT='demo'\n", encoding="utf-8")
    (custom / "aliases.zsh").write_text("alias ll='ls -la'\n", encoding="utf-8")
    (custom / "completions" / "_demo").write_text("#compdef demo\n", encoding="utf-8")
    (custom / "plugin-cache.zwc").write_text("skip\n", encoding="utf-8")

    zshrc.write_text(
        """# top-level comment must survive by default
export ZSH="$HOME/.oh-my-zsh"
cat <<'PAYLOAD' >/tmp/zsh-restore-payload
# literal payload, not a shell comment
PAYLOAD
source $ZSH/oh-my-zsh.sh
""",
        encoding="utf-8",
    )
    p10k.write_text(
        """# p10k comment must survive by default
unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
""",
        encoding="utf-8",
    )

    return omz, zshrc, p10k


def import_restore_module(path: Path):
    spec = importlib.util.spec_from_file_location("restore_zsh_offline_generated", path)
    if spec is None or spec.loader is None:
        fail(f"cannot import generated restore script: {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def assert_generated_rejects_unsafe_links(restore_script: Path, tmp: Path) -> None:
    module = import_restore_module(restore_script)
    archive_path = tmp / "unsafe-link.tar.gz"
    extract_dir = tmp / "unsafe-extract"

    data = b"unsafe"
    file_info = tarfile.TarInfo("custom/plugins/payload")
    file_info.size = len(data)
    link_info = tarfile.TarInfo("custom/plugins/escape")
    link_info.type = tarfile.SYMTYPE
    link_info.linkname = "/tmp/zsh-restore-escape"

    with tarfile.open(archive_path, "w:gz") as archive:
        archive.addfile(file_info, io.BytesIO(data))
        archive.addfile(link_info)

    try:
        module.extract_archive_file(archive_path, extract_dir)
    except SystemExit as exc:
        if "unsafe archive link" not in str(exc):
            fail(f"unsafe archive failed for the wrong reason: {exc}")
        return

    fail("generated restore script accepted an absolute symlink target in a tar archive")


def assert_generated_accepts_safe_relative_links(restore_script: Path, tmp: Path) -> None:
    module = import_restore_module(restore_script)
    archive_path = tmp / "safe-relative-link.tar.gz"
    extract_dir = tmp / "safe-relative-extract"

    data = b"safe docs"
    target_info = tarfile.TarInfo("custom/plugins/demo/docs/highlighters/brackets.md")
    target_info.size = len(data)
    link_info = tarfile.TarInfo("custom/plugins/demo/highlighters/brackets/README.md")
    link_info.type = tarfile.SYMTYPE
    link_info.linkname = "../../docs/highlighters/brackets.md"

    with tarfile.open(archive_path, "w:gz") as archive:
        archive.addfile(target_info, io.BytesIO(data))
        archive.addfile(link_info)

    try:
        module.extract_archive_file(archive_path, extract_dir)
    except SystemExit as exc:
        fail(f"generated restore script rejected a safe relative symlink: {exc}")

    readme = extract_dir / "custom" / "plugins" / "demo" / "highlighters" / "brackets" / "README.md"
    if not readme.is_symlink():
        fail("safe relative symlink was not restored as a symlink")
    if readme.read_bytes() != data:
        fail("safe relative symlink does not resolve to the restored target")


def main() -> None:
    project_dir = Path(__file__).resolve().parent
    generator = project_dir / "make-zsh-offline-restore.py"
    if not generator.exists():
        fail("make-zsh-offline-restore.py does not exist")

    with tempfile.TemporaryDirectory(prefix="zsh-python-restore-test.") as tmp_name:
        tmp = Path(tmp_name)
        restore_script = tmp / "restore-zsh-offline.py"
        test_home = tmp / "home"
        bin_dir = tmp / "bin"
        git_marker = tmp / "git-was-called"
        omz_source, zshrc_source, p10k_source = create_fixture_source(tmp)

        test_home.mkdir()
        bin_dir.mkdir()

        for tool in ("sh", "zsh", "sed", "tar", "mkdir", "mv", "rm"):
            symlink_tool(bin_dir, tool)

        git_wrapper = bin_dir / "git"
        write_executable(
            git_wrapper,
            "#!/bin/sh\n"
            f"printf 'git called: %s\\n' \"$*\" > {git_marker}\n"
            "exit 97\n",
        )

        subprocess.run(
            [
                sys.executable,
                str(generator),
                str(restore_script),
                "--omz-dir",
                str(omz_source),
                "--zshrc",
                str(zshrc_source),
                "--p10k",
                str(p10k_source),
            ],
            cwd=project_dir,
            check=True,
        )

        script_text = restore_script.read_text(encoding="utf-8")
        if "patch_oh_my_zsh_installer" not in script_text:
            fail("restore script does not patch the official installer")
        if "git init" in script_text or "git fetch" in script_text:
            fail("restore script contains direct git install commands")
        if "OMZ_BASE_TAR_GZ_SHA256" not in script_text:
            fail("restore script does not embed an archive checksum")

        env = os.environ.copy()
        env.update(
            {
                "HOME": str(test_home),
                "PATH": str(bin_dir),
                "USER": "offline-test",
            }
        )
        result = subprocess.run(
            [sys.executable, str(restore_script)],
            cwd=project_dir,
            env=env,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
        )
        if result.returncode != 0:
            print(result.stdout, file=sys.stderr)
            fail(f"restore script exited with {result.returncode}")

        if git_marker.exists():
            print(git_marker.read_text(encoding="utf-8"), file=sys.stderr)
            fail("restore script invoked git")

        zshrc = test_home / ".zshrc"
        p10k = test_home / ".p10k.zsh"
        omz = test_home / ".oh-my-zsh"

        for path in (
            zshrc,
            p10k,
            omz / "tools" / "install.sh",
            omz / "custom" / "plugins" / "demo" / "demo.plugin.zsh",
            omz / "custom" / "themes" / "demo.zsh-theme",
            omz / "custom" / "aliases.zsh",
            omz / "custom" / "completions" / "_demo",
        ):
            if not path.exists():
                fail(f"expected restored path missing: {path}")

        for path in (
            omz / ".git",
            omz / "compiled.zwc",
            omz / "custom" / "plugins" / "demo" / ".git",
            omz / "custom" / "plugin-cache.zwc",
        ):
            if path.exists():
                fail(f"excluded path was restored unexpectedly: {path}")

        zshrc_text = zshrc.read_text(encoding="utf-8")
        if "# top-level comment must survive by default" not in zshrc_text:
            fail(".zshrc comments were stripped even though --strip-comments was not used")
        if "# literal payload, not a shell comment" not in zshrc_text:
            fail(".zshrc heredoc payload was stripped as if it were a shell comment")

        p10k_text = p10k.read_text(encoding="utf-8")
        if "# p10k comment must survive by default" not in p10k_text:
            fail(".p10k.zsh comments were stripped even though --strip-comments was not used")
        if "POWERLEVEL9K_DISABLE_GITSTATUS=true" not in p10k_text:
            fail(".p10k.zsh does not disable POWERLEVEL9K gitstatus")
        if "GITSTATUS_AUTO_INSTALL=0" not in p10k_text:
            fail(".p10k.zsh does not disable gitstatus auto-install")

        source_index = zshrc_text.find("source $ZSH/oh-my-zsh.sh")
        disable_index = zshrc_text.find("POWERLEVEL9K_DISABLE_GITSTATUS=true")
        if source_index == -1 or disable_index == -1 or disable_index > source_index:
            fail(".zshrc does not disable gitstatus before sourcing oh-my-zsh")

        assert_generated_rejects_unsafe_links(restore_script, tmp)
        assert_generated_accepts_safe_relative_links(restore_script, tmp)

    print("[PASS] python offline restore script smoke test passed")


if __name__ == "__main__":
    main()
