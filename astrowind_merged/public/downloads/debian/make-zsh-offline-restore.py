#!/usr/bin/env python3
import argparse
import base64
import fnmatch
import hashlib
import io
import os
import re
import tarfile
import textwrap
from pathlib import Path


def info(message: str) -> None:
    print(f"[INFO] {message}")


def warn(message: str) -> None:
    print(f"[WARN] {message}")


def fail(message: str) -> None:
    raise SystemExit(f"[ERROR] {message}")


def strip_comment_lines(text: str) -> str:
    return "\n".join(line for line in text.splitlines() if not line.lstrip().startswith("#")) + "\n"


def without_gitstatus_overrides(lines):
    patterns = (
        "POWERLEVEL9K_DISABLE_GITSTATUS",
        "GITSTATUS_AUTO_INSTALL",
    )
    return [line for line in lines if not any(pattern in line for pattern in patterns)]


def inject_zshrc_gitstatus_disable(text: str) -> str:
    lines = without_gitstatus_overrides(text.splitlines())
    disable_lines = [
        "typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true",
        "typeset -g GITSTATUS_AUTO_INSTALL=0",
    ]

    source_pattern = re.compile(r"^\s*source\s+.*oh-my-zsh\.sh\s*$")
    for index, line in enumerate(lines):
        if source_pattern.search(line):
            lines[index:index] = disable_lines + [""]
            return "\n".join(lines) + "\n"

    return "\n".join(disable_lines + [""] + lines) + "\n"


def inject_p10k_gitstatus_disable(text: str) -> str:
    lines = without_gitstatus_overrides(text.splitlines())
    disable_lines = [
        "  typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true",
        "  typeset -g GITSTATUS_AUTO_INSTALL=0",
    ]

    for index, line in enumerate(lines):
        if "unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'" in line:
            lines[index + 1:index + 1] = disable_lines + [""]
            return "\n".join(lines) + "\n"

    return "\n".join([
        "typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true",
        "typeset -g GITSTATUS_AUTO_INSTALL=0",
        "",
    ] + lines) + "\n"


def read_config(path: Path, *, p10k: bool = False, zshrc: bool = False, strip_comments: bool = False) -> str:
    raw = path.read_text(encoding="utf-8")
    stripped = strip_comment_lines(raw) if strip_comments else raw
    if p10k:
        return inject_p10k_gitstatus_disable(stripped)
    if zshrc:
        return inject_zshrc_gitstatus_disable(stripped)
    return stripped


def reset_tarinfo(info_obj: tarfile.TarInfo) -> tarfile.TarInfo:
    info_obj.uid = 0
    info_obj.gid = 0
    info_obj.uname = ""
    info_obj.gname = ""
    info_obj.mode &= ~0o022
    return info_obj


def clean_rel_name(name: str) -> str:
    name = name.replace(os.sep, "/")
    while name.startswith("./"):
        name = name[2:]
    return name


def should_exclude_omz(name: str) -> bool:
    name = clean_rel_name(name)
    if not name:
        return False
    parts = name.split("/")
    if parts[0] in {".git", "custom", "cache", "log"}:
        return True
    if any(part == ".git" for part in parts):
        return True
    if fnmatch.fnmatch(parts[-1], "*.zwc"):
        return True
    return False


def should_exclude_custom(name: str) -> bool:
    name = clean_rel_name(name)
    parts = name.split("/")
    if parts and parts[0] in {"cache", "log"}:
        return True
    if any(part == ".git" for part in parts):
        return True
    if parts and fnmatch.fnmatch(parts[-1], "*.zwc"):
        return True
    return False


def make_omz_base_archive(omz_dir: Path) -> bytes:
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode="w:gz") as archive:
        def tar_filter(info_obj: tarfile.TarInfo):
            return None if should_exclude_omz(info_obj.name) else reset_tarinfo(info_obj)

        archive.add(omz_dir, arcname=".", recursive=True, filter=tar_filter)
    return buffer.getvalue()


def make_custom_assets_archive(omz_dir: Path) -> bytes:
    custom_dir = omz_dir / "custom"
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode="w:gz") as archive:
        def tar_filter(info_obj: tarfile.TarInfo):
            return None if should_exclude_custom(info_obj.name) else reset_tarinfo(info_obj)

        if custom_dir.exists():
            archive.add(custom_dir, arcname="custom", recursive=True, filter=tar_filter)
        else:
            warn(f"custom directory not found: {custom_dir}; restoring an empty custom directory")
            info_obj = tarfile.TarInfo("custom")
            info_obj.type = tarfile.DIRTYPE
            info_obj.mode = 0o755
            archive.addfile(reset_tarinfo(info_obj))
    return buffer.getvalue()


def b64_block(data: bytes) -> str:
    encoded = base64.b64encode(data).decode("ascii")
    return "\n".join(textwrap.wrap(encoded, 76))


RESTORE_TEMPLATE = r'''#!/usr/bin/env python3
import base64
import binascii
import hashlib
import io
import os
import pwd
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
import time
from pathlib import Path, PurePosixPath


OMZ_BASE_TAR_GZ_B64 = """__OMZ_BASE_B64__"""
OMZ_BASE_TAR_GZ_SHA256 = "__OMZ_BASE_SHA256__"

CUSTOM_ASSETS_TAR_GZ_B64 = """__CUSTOM_ASSETS_B64__"""
CUSTOM_ASSETS_TAR_GZ_SHA256 = "__CUSTOM_ASSETS_SHA256__"

ZSHRC_TEXT = __ZSHRC_TEXT_REPR__
P10K_TEXT = __P10K_TEXT_REPR__


class Target:
    def __init__(self, user, home, uid, gid, groups):
        self.user = user
        self.home = Path(home)
        self.uid = uid
        self.gid = gid
        self.groups = groups


def info(message):
    print(f"[INFO] {{message}}", flush=True)


def warn(message):
    print(f"[WARN] {{message}}", file=sys.stderr, flush=True)


def fail(message):
    raise SystemExit(f"[ERROR] {{message}}")


def require_cmd(name):
    path = shutil.which(name)
    if not path:
        fail(f"missing command: {{name}}")
    return path


def decode_archive(block, expected_sha256):
    try:
        data = base64.b64decode("".join(block.split()), validate=True)
    except binascii.Error as exc:
        fail(f"invalid embedded archive base64: {{exc}}")

    actual_sha256 = hashlib.sha256(data).hexdigest()
    if actual_sha256 != expected_sha256:
        fail(f"embedded archive checksum mismatch: expected {{expected_sha256}}, got {{actual_sha256}}")
    return data


def get_user_groups(user, gid):
    try:
        return os.getgrouplist(user, gid)
    except AttributeError:
        return [gid]


def passwd_for_user(user):
    try:
        return pwd.getpwnam(user)
    except KeyError:
        return None


def resolve_target():
    current_uid = os.getuid()
    current_user = pwd.getpwuid(current_uid).pw_name
    target_user = os.environ.get("RESTORE_TARGET_USER")
    target_home = os.environ.get("RESTORE_TARGET_HOME")

    if target_home:
        if not target_user:
            if Path(target_home) == Path.home():
                target_user = current_user
            elif current_uid == 0:
                target_user = "root" if target_home == "/root" else None
    elif current_uid == 0 and os.environ.get("SUDO_USER") not in (None, "", "root"):
        target_user = os.environ["SUDO_USER"]
        pw = passwd_for_user(target_user)
        if not pw:
            fail(f"cannot resolve sudo user: {{target_user}}")
        target_home = pw.pw_dir
        info(f"running through sudo; restoring to invoking user: {{target_user}} ({{target_home}})")
        info("to restore root instead, run: sudo env RESTORE_TARGET_HOME=/root RESTORE_TARGET_USER=root python3 restore-zsh-offline.py")
    else:
        target_user = target_user or current_user
        target_home = os.environ.get("HOME") or str(Path.home())

    if not target_home or target_home == "/":
        fail(f"unsafe restore target home: {{target_home!r}}")

    if current_uid != 0 and Path(target_home) != Path(os.environ.get("HOME", str(Path.home()))):
        fail(f"non-root restore can only write to HOME={{os.environ.get('HOME')}}; requested target is {{target_home}}")

    pw = passwd_for_user(target_user) if target_user else None
    if pw:
        uid, gid, groups = pw.pw_uid, pw.pw_gid, get_user_groups(target_user, pw.pw_gid)
        home = target_home or pw.pw_dir
        user = target_user
    else:
        uid, gid, groups = current_uid, os.getgid(), os.getgroups()
        home = target_home
        user = target_user or current_user

    target = Target(user=user, home=home, uid=uid, gid=gid, groups=groups)
    info(f"restore target home: {{target.home}}")
    return target


def demote_preexec(target):
    def demote():
        os.setgroups(target.groups)
        os.setgid(target.gid)
        os.setuid(target.uid)
    return demote


def target_env(target, extra=None):
    env = os.environ.copy()
    env.update({
        "HOME": str(target.home),
        "USER": target.user,
        "LOGNAME": target.user,
        "ZSH": str(target.home / ".oh-my-zsh"),
        "CHSH": "no",
        "RUNZSH": "no",
        "OVERWRITE_CONFIRMATION": "no",
    })
    if extra:
        env.update(extra)
    return env


def run_as_target(target, args, *, env=None, cwd=None, input_text=None, check=True):
    kwargs = {
        "env": env or target_env(target),
        "cwd": str(cwd or target.home),
        "text": True,
        "input": input_text,
    }
    if os.getuid() == 0 and target.uid != 0:
        kwargs["preexec_fn"] = demote_preexec(target)

    result = subprocess.run(args, **kwargs)
    if check and result.returncode != 0:
        fail(f"command failed with exit {{result.returncode}}: {{' '.join(map(str, args))}}")
    return result


def write_text_as_target(target, path, text, mode=0o600):
    path = Path(path)
    if os.getuid() == 0 and target.uid != 0:
        code = (
            "import os, pathlib, sys\n"
            "path = pathlib.Path(sys.argv[1])\n"
            "path.parent.mkdir(parents=True, exist_ok=True)\n"
            "data = sys.stdin.read()\n"
            "path.write_text(data, encoding='utf-8')\n"
            "os.chmod(path, int(sys.argv[2], 8))\n"
        )
        run_as_target(
            target,
            [sys.executable, "-c", code, str(path), oct(mode)],
            input_text=text,
            check=True,
        )
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text, encoding="utf-8")
        path.chmod(mode)


def remove_tree(path):
    path = Path(path)
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.exists():
        shutil.rmtree(path)


def backup_existing(target):
    stamp = time.strftime("%Y%m%d-%H%M%S")
    backup_dir = target.home / ".zsh-offline-restore-backup" / f"{{stamp}}-{{os.getpid()}}"
    moved = False
    for name in (".zshrc", ".p10k.zsh", ".oh-my-zsh"):
        src = target.home / name
        if src.exists() or src.is_symlink():
            backup_dir.mkdir(parents=True, exist_ok=True)
            dst = backup_dir / name
            info(f"backing up {{src}} -> {{dst}}")
            shutil.move(str(src), str(dst))
            moved = True

    if moved and os.getuid() == 0:
        for root, dirs, files in os.walk(backup_dir):
            os.chown(root, target.uid, target.gid)
            for entry in dirs + files:
                try:
                    os.chown(Path(root) / entry, target.uid, target.gid)
                except FileNotFoundError:
                    pass
        return backup_dir

    return backup_dir if moved else None


def normalized_posix_parts(path):
    normalized = []
    for part in PurePosixPath(path).parts:
        if part in ("", "."):
            continue
        if part == "..":
            if not normalized:
                return None
            normalized.pop()
        else:
            normalized.append(part)
    return normalized


def symlink_target_stays_in_archive(member_name, link_name):
    link_path = PurePosixPath(link_name)
    if link_path.is_absolute():
        return False
    member_parts = normalized_posix_parts(member_name)
    if member_parts is None:
        return False
    combined = PurePosixPath(*member_parts[:-1], link_name)
    return normalized_posix_parts(combined) is not None


def hardlink_target_stays_in_archive(link_name):
    link_path = PurePosixPath(link_name)
    if link_path.is_absolute():
        return False
    return normalized_posix_parts(link_name) is not None


def safe_members(archive):
    for member in archive.getmembers():
        name = member.name
        target = PurePosixPath(name)
        if target.is_absolute() or ".." in target.parts:
            fail(f"unsafe archive member: {{name}}")
        if member.isdev():
            fail(f"unsafe archive special file: {{name}}")
        if member.issym() and not symlink_target_stays_in_archive(name, member.linkname):
            fail(f"unsafe archive link: {{name}} -> {{member.linkname}}")
        if member.islnk() and not hardlink_target_stays_in_archive(member.linkname):
            fail(f"unsafe archive link: {{name}} -> {{member.linkname}}")
        member.uid = os.getuid()
        member.gid = os.getgid()
        member.uname = ""
        member.gname = ""
        member.mode &= ~0o022
        yield member


def extractall_compat(archive, dest):
    members = list(safe_members(archive))
    try:
        archive.extractall(dest, members=members, filter="data")
    except TypeError:
        archive.extractall(dest, members=members)


def extract_archive_bytes(data, dest):
    dest = Path(dest)
    dest.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as archive:
        extractall_compat(archive, dest)


def extract_archive_file(archive_path, dest):
    dest = Path(dest)
    dest.mkdir(parents=True, exist_ok=True)
    with tarfile.open(archive_path, mode="r:gz") as archive:
        extractall_compat(archive, dest)


def extract_archive_file_as_target(target, archive_path, dest):
    if os.getuid() == 0 and target.uid != 0:
        code = r"""
import os
import pathlib
import sys
import tarfile

archive_path = pathlib.Path(sys.argv[1])
dest = pathlib.Path(sys.argv[2])
dest.mkdir(parents=True, exist_ok=True)

def normalized_posix_parts(path):
    normalized = []
    for part in pathlib.PurePosixPath(path).parts:
        if part in ("", "."):
            continue
        if part == "..":
            if not normalized:
                return None
            normalized.pop()
        else:
            normalized.append(part)
    return normalized

def symlink_target_stays_in_archive(member_name, link_name):
    link_path = pathlib.PurePosixPath(link_name)
    if link_path.is_absolute():
        return False
    member_parts = normalized_posix_parts(member_name)
    if member_parts is None:
        return False
    combined = pathlib.PurePosixPath(*member_parts[:-1], link_name)
    return normalized_posix_parts(combined) is not None

def hardlink_target_stays_in_archive(link_name):
    link_path = pathlib.PurePosixPath(link_name)
    if link_path.is_absolute():
        return False
    return normalized_posix_parts(link_name) is not None

def safe_members(archive):
    for member in archive.getmembers():
        target = pathlib.PurePosixPath(member.name)
        if target.is_absolute() or ".." in target.parts:
            raise SystemExit(f"unsafe archive member: {{member.name}}")
        if member.isdev():
            raise SystemExit(f"unsafe archive special file: {{member.name}}")
        if member.issym() and not symlink_target_stays_in_archive(member.name, member.linkname):
            raise SystemExit(f"unsafe archive link: {{member.name}} -> {{member.linkname}}")
        if member.islnk() and not hardlink_target_stays_in_archive(member.linkname):
            raise SystemExit(f"unsafe archive link: {{member.name}} -> {{member.linkname}}")
        member.uid = os.getuid()
        member.gid = os.getgid()
        member.uname = ""
        member.gname = ""
        member.mode &= ~0o022
        yield member

with tarfile.open(archive_path, mode="r:gz") as archive:
    members = list(safe_members(archive))
    try:
        archive.extractall(dest, members=members, filter="data")
    except TypeError:
        archive.extractall(dest, members=members)
"""
        run_as_target(target, [sys.executable, "-c", code, str(archive_path), str(dest)])
    else:
        extract_archive_file(archive_path, dest)


def patch_oh_my_zsh_installer(source_dir, patched_installer):
    install_sh = source_dir / "tools" / "install.sh"
    text = install_sh.read_text(encoding="utf-8")
    replacement = r"""setup_ohmyzsh() {
  umask g-w,o-w

  echo "${FMT_BLUE}Installing Oh My Zsh from embedded offline source...${FMT_RESET}"

  if [ -z "${OMZ_OFFLINE_SOURCE:-}" ]; then
    fmt_error "OMZ_OFFLINE_SOURCE is not set"
    exit 1
  fi

  if [ ! -d "$OMZ_OFFLINE_SOURCE" ]; then
    fmt_error "offline Oh My Zsh source not found: $OMZ_OFFLINE_SOURCE"
    exit 1
  fi

  command_exists tar || {
    fmt_error "tar is not installed"
    exit 1
  }

  mkdir -p "$ZSH" || {
    fmt_error "cannot create $ZSH"
    exit 1
  }

  (
    cd "$OMZ_OFFLINE_SOURCE" && \
    tar --exclude='./.git' --exclude='./custom' --exclude='./cache' --exclude='./log' --exclude='*.zwc' -cf - .
  ) | (
    cd "$ZSH" && tar -xf -
  ) || {
    fmt_error "offline Oh My Zsh install failed"
    exit 1
  }

  mkdir -p "$ZSH/custom"
  echo
}

setup_zshrc() {"""
    patched, count = re.subn(
        r"setup_ohmyzsh\(\) \{.*?\n\}\n\nsetup_zshrc\(\) \{",
        replacement,
        text,
        count=1,
        flags=re.S,
    )
    if count != 1:
        fail("could not patch oh-my-zsh tools/install.sh")
    patched_installer.write_text(patched, encoding="utf-8")
    patched_installer.chmod(0o644)


def restore_custom_assets(target, archive_path):
    target_omz = target.home / ".oh-my-zsh"
    custom_dir = target_omz / "custom"
    remove_tree(custom_dir)
    extract_archive_file_as_target(target, archive_path, target_omz)


def main():
    require_cmd("sh")
    require_cmd("zsh")
    require_cmd("tar")
    require_cmd("sed")

    target = resolve_target()
    target.home.mkdir(parents=True, exist_ok=True)

    backup_dir = backup_existing(target)

    with tempfile.TemporaryDirectory(prefix="zsh-offline-restore.") as tmp_name:
        tmp = Path(tmp_name)
        tmp.chmod(0o755)
        source_dir = tmp / "oh-my-zsh-source"
        patched_installer = tmp / "install-offline.sh"
        custom_archive = tmp / "custom-assets.tar.gz"

        info("extracting embedded oh-my-zsh source")
        extract_archive_bytes(decode_archive(OMZ_BASE_TAR_GZ_B64, OMZ_BASE_TAR_GZ_SHA256), source_dir)
        for root, dirs, files in os.walk(source_dir):
            os.chmod(root, 0o755)
            for name in files:
                path = Path(root) / name
                if not path.is_symlink():
                    mode = path.stat().st_mode
                    path.chmod(mode & ~0o022)

        patch_oh_my_zsh_installer(source_dir, patched_installer)

        custom_archive.write_bytes(decode_archive(CUSTOM_ASSETS_TAR_GZ_B64, CUSTOM_ASSETS_TAR_GZ_SHA256))
        custom_archive.chmod(0o644)

        info("running patched official oh-my-zsh installer without git")
        installer_env = target_env(target, {
            "OMZ_OFFLINE_SOURCE": str(source_dir),
            "KEEP_ZSHRC": "no",
        })
        run_as_target(target, [require_cmd("sh"), str(patched_installer), "--unattended"], env=installer_env)

        info("writing .zshrc from embedded plain text")
        write_text_as_target(target, target.home / ".zshrc", ZSHRC_TEXT, 0o600)

        info("writing .p10k.zsh from embedded plain text with gitstatus disabled")
        write_text_as_target(target, target.home / ".p10k.zsh", P10K_TEXT, 0o600)

        info("restoring custom oh-my-zsh assets")
        restore_custom_assets(target, custom_archive)

    zsh = require_cmd("zsh")
    result = run_as_target(
        target,
        [zsh, "-n", str(target.home / ".zshrc")],
        env=target_env(target),
        check=False,
    )
    if result.returncode == 0:
        info(".zshrc syntax check passed")
    else:
        warn(f".zshrc syntax check failed; inspect {{target.home / '.zshrc'}}")

    if backup_dir:
        info(f"previous files were backed up in: {{backup_dir}}")

    info("to set zsh as the default shell, run:")
    if os.getuid() == 0:
        print(f'  chsh -s "{{zsh}}" "{{target.user}}"')
    else:
        print(f'  chsh -s "{{zsh}}"')

    info("restore finished")


if __name__ == "__main__":
    main()
'''


def build_restore_script(output: Path, omz_dir: Path, zshrc: Path, p10k: Path, *, strip_comments: bool) -> None:
    zshrc_comment_count = sum(1 for line in zshrc.read_text(encoding="utf-8").splitlines() if line.lstrip().startswith("#"))
    if strip_comments:
        info(f"embedding .zshrc as plain text without comment-only lines: {zshrc_comment_count} removed")
    else:
        info(f"embedding .zshrc as plain text with comments preserved: {zshrc_comment_count} comment-only lines")
    zshrc_text = read_config(zshrc, zshrc=True, strip_comments=strip_comments)

    if p10k.exists():
        p10k_comment_count = sum(1 for line in p10k.read_text(encoding="utf-8").splitlines() if line.lstrip().startswith("#"))
        if strip_comments:
            info(f"embedding .p10k.zsh as plain text without comment-only lines: {p10k_comment_count} removed")
        else:
            info(f"embedding .p10k.zsh as plain text with comments preserved: {p10k_comment_count} comment-only lines")
        p10k_text = read_config(p10k, p10k=True, strip_comments=strip_comments)
    else:
        warn(f".p10k.zsh not found: {p10k}; writing minimal gitstatus-disabled config")
        p10k_text = "typeset -g POWERLEVEL9K_DISABLE_GITSTATUS=true\ntypeset -g GITSTATUS_AUTO_INSTALL=0\n"

    info(f"packing oh-my-zsh offline source without git metadata: {omz_dir}")
    omz_base = make_omz_base_archive(omz_dir)

    info("packing custom oh-my-zsh assets")
    custom_assets = make_custom_assets_archive(omz_dir)

    output.parent.mkdir(parents=True, exist_ok=True)
    script = RESTORE_TEMPLATE.replace("{{", "{").replace("}}", "}")
    script = script.replace("__OMZ_BASE_B64__", b64_block(omz_base))
    script = script.replace("__OMZ_BASE_SHA256__", hashlib.sha256(omz_base).hexdigest())
    script = script.replace("__CUSTOM_ASSETS_B64__", b64_block(custom_assets))
    script = script.replace("__CUSTOM_ASSETS_SHA256__", hashlib.sha256(custom_assets).hexdigest())
    script = script.replace("__ZSHRC_TEXT_REPR__", repr(zshrc_text))
    script = script.replace("__P10K_TEXT_REPR__", repr(p10k_text))
    output.write_text(script, encoding="utf-8")
    output.chmod(0o700)

    info(f"generated: {output}")
    info(f"size: {output.stat().st_size} bytes")
    info(f"copy this single file to the offline machine and run: python3 {output.name}")


def parse_args():
    parser = argparse.ArgumentParser(description="Generate a Python self-contained offline zsh restore script.")
    parser.add_argument("output", nargs="?", default="restore-zsh-offline.py")
    parser.add_argument("--omz-dir", default=os.environ.get("OMZ_DIR", str(Path.home() / ".oh-my-zsh")))
    parser.add_argument("--zshrc", default=os.environ.get("ZSHRC", str(Path.home() / ".zshrc")))
    parser.add_argument("--p10k", default=os.environ.get("P10K", str(Path.home() / ".p10k.zsh")))
    parser.add_argument(
        "--strip-comments",
        action="store_true",
        help="remove comment-only lines from .zshrc and .p10k.zsh before embedding",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    output = Path(args.output)
    omz_dir = Path(args.omz_dir).expanduser()
    zshrc = Path(args.zshrc).expanduser()
    p10k = Path(args.p10k).expanduser()

    if not omz_dir.is_dir():
        fail(f"oh-my-zsh directory not found: {omz_dir}")
    if not (omz_dir / "tools" / "install.sh").is_file():
        fail(f"oh-my-zsh tools/install.sh not found under: {omz_dir}")
    if not zshrc.is_file():
        fail(f".zshrc not found: {zshrc}")

    build_restore_script(output, omz_dir, zshrc, p10k, strip_comments=args.strip_comments)


if __name__ == "__main__":
    main()
