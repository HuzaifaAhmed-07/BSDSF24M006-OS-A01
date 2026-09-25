# Feature 5: Documentation & Installation

## 1. What is `groff` and how does man page formatting work?

`groff` (GNU roff) is the typesetting system that Linux's `man` command uses
to render man pages. Man pages are plain text files written using roff
"dot commands" — macros beginning with a `.` at the start of a line — from
the `man` (`mdoc`/`man` macro package). The most common macros are:

- `.TH` — the title heading: name, section number, date, source, manual name
- `.SH` — a section heading (NAME, SYNOPSIS, DESCRIPTION, etc.)
- `.B` / `.I` — bold / italic text
- `.BI` — alternating bold/italic (used for function signatures)
- `.nf` / `.fi` — no-fill / fill mode, used to preserve literal formatting
  (e.g. code blocks) without groff rewrapping the lines
- `.PP` — start a new paragraph
- `.RI` — alternating roman/italic

When `man mycat` is run, `man` locates `mycat.3`, pipes it through `groff -man
-Tascii` (or equivalent), and displays the result via a pager. The trailing
`3` in the filename places it in **section 3** of the manual, which is
reserved for library functions (as opposed to section 1, user commands, or
section 2, system calls).

## 2. Why section 3 specifically?

The Linux manual is divided into numbered sections:

| Section | Contents |
|---|---|
| 1 | User commands |
| 2 | System calls |
| **3** | **Library functions (C library, our `libmyutils`)** |
| 5 | File formats |
| 7 | Miscellaneous |
| 8 | Admin/root commands |

Since `mycat()`, `mystrlen()`, etc. are C library functions callable from
code (not standalone shell commands), they belong in section 3, installed
to `man/man3/` and later `$(PREFIX)/share/man/man3/`.

## 3. What does the `install` target do, and why those specific paths?

The `install` target copies build artifacts out of the project tree and into
standard Linux Filesystem Hierarchy Standard (FHS) locations so the library,
headers, binary, and documentation are available system-wide instead of only
from inside the repo:

- `bin/client_dynamic` → `$(PREFIX)/bin/client` — so `client` runs from any
  directory without needing `./` or `LD_LIBRARY_PATH`
- `lib/libmyutils.so` and `lib/libmyutils.a` → `$(PREFIX)/lib/` — the
  standard runtime/link-time library search path
- `include/*.h` → `$(PREFIX)/include/myutils/` — so other projects can
  `#include <myutils/mystrfunctions.h>`
- `man/man3/*.3` → `$(PREFIX)/share/man/man3/` — so `man mycat` works
  globally

`PREFIX` defaults to `/usr/local`, the conventional location for
locally-built (non-package-manager) software, keeping it separate from
files owned by the distro's package manager under `/usr`.

## 4. Why is `ldconfig` needed after installing the shared library?

`ldconfig` rebuilds the dynamic linker's cache (`/etc/ld.so.cache`), which
maps library names to their locations on disk. Even though
`/usr/local/lib` is normally already in the linker's default search path,
the cache is only updated when `ldconfig` runs. Without it, `ld.so` may not
find the newly installed `libmyutils.so` at runtime, and `client` would fail
with an error like `error while loading shared libraries: libmyutils.so:
cannot open shared object file`. This is the same reason we previously had
to set `LD_LIBRARY_PATH` manually during development in Feature 4 — a
system-wide install with `ldconfig` removes that requirement for end users.

## 5. Why provide an `uninstall` target?

Clean removal is expected of any well-behaved install system. Since
`install` never records what it wrote anywhere else, `uninstall` mirrors it
exactly — deleting the same explicit paths — so the system is returned to
its pre-install state without leftover files. This also makes it easy to
re-test the install process repeatedly during development
(`make uninstall && make install`).

## 6. Why does `make install` need `sudo`?

`/usr/local/{bin,lib,include,share/man}` are owned by root and not writable
by a normal user. `install` (the coreutils command, not just the Makefile
target) will fail with a permission error without elevated privileges,
hence `sudo make install`. `PREFIX` can be overridden
(`make install PREFIX=$HOME/.local`) to install to a user-writable location
without root, which is common practice for local/non-system installs.

## 7. Git workflow for this feature

- Branch: `man-pages`, created from `main` (or the previous feature branch)
  with `git checkout -b man-pages`
- Commits made incrementally as each man page and the install/uninstall
  targets were added
- Tag: `v0.4.1-final`, created as an **annotated** tag
  (`git tag -a v0.4.1-final -m "Documentation and installation system"`)
  so it carries author, date, and message metadata — unlike a lightweight
  tag, which is just a pointer to a commit
- Pushed with `git push origin man-pages --tags`
- GitHub Release created from the `v0.4.1-final` tag, with no binary asset
  required for this feature since it's the final merge point rather than a
  new artifact type
- Finally merged into `main` with `git checkout main && git merge man-pages`,
  completing the project's Git history across all five features
