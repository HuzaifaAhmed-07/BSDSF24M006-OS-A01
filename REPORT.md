# OS Assignment 01: Core C Utilities Library — REPORT

**Repository:** BSDSF24M006-OS-A01
**Library:** libmyutils

---

# Feature 1: Project Scaffolding

The repository was initialized on `main` following the Linux File Hierarchy
Standard convention adapted for a C project: source (`src/`), public headers
(`include/`), build outputs kept separate from source (`obj/`, `lib/`,
`bin/`), and documentation (`man/man3/`). Keeping generated files (`obj/`,
`lib/`, `bin/`) separate from source is standard practice so the build can
be cleaned (`make clean`) without touching anything under version control
logic that matters — though note `.gitignore` should typically exclude
compiled artifacts like `.o`/`.a`/`.so`/binaries from being tracked, keeping
the repo to source + build recipe.

---

# Feature 2: Multi-file Compilation (v0.1.1)

## Makefile linking rules vs library linking

In the multi-file build, the Makefile compiles each `.c` file to its own
`.o` object file, then links all objects directly into one executable in a
single `gcc` invocation:

```
$(CC) $(CFLAGS) $^ -o $@
```

There is no intermediate library — the linker resolves symbols directly
between the object files at link time. This differs from library linking
(Features 3 and 4), where the objects are first archived/packaged into a
`.a` or `.so`, and the final executable links *against that library* using
`-L<path> -l<name>` rather than listing the object files individually. The
practical difference: with direct object linking, every consumer of the
code needs the `.o` files or source; with a library, consumers only need
the header and the compiled library file.

## Git tags: simple (lightweight) vs annotated

A **lightweight tag** is just a named pointer to a specific commit — created
with `git tag v0.1.1-multifile`, storing no extra metadata.

An **annotated tag** (`git tag -a v0.1.1-multifile -m "message"`) creates a
full object in Git's database with its own author, date, message, and
(optionally) a GPG signature. Annotated tags are recommended for releases
because they're checksummed and carry history — this is what was used for
every version tag in this project (`v0.1.1-multifile`, `v0.2.1-static`,
`v0.3.1-dynamic`, `v0.4.1-final`).

## GitHub releases and binary distribution

A GitHub Release wraps an existing tag with release notes and, optionally,
uploaded binary assets (in this case `bin/client`). This lets consumers
download a ready-to-run executable without cloning the repo or building
from source — the standard way open-source and internal tools distribute
versioned builds.

---

# Feature 3: Static Library (v0.2.1)

## Makefile differences for library creation

Instead of linking objects straight into an executable, the static-library
build archives them first:

```
$(AR) $(ARFLAGS) $@ $^        # ar rcs lib/libmyutils.a obj/*.o
```

The client executable then links against the archive rather than the raw
objects:

```
$(CC) $(CFLAGS) main.c lib/libmyutils.a -o bin/client_static
```

## Purpose of `ar` and `ranlib`

`ar` (archiver) bundles multiple `.o` files into a single `.a` archive file
— essentially a container format, not compiled/linked code in itself.
`ranlib` builds/updates an index (symbol table) inside the archive so the
linker can quickly locate which object file inside the archive defines a
given symbol, instead of scanning every member sequentially. Modern `ar`
with the `s` flag (as in `rcs`) performs this indexing automatically,
which is why a separate explicit `ranlib` call often isn't needed when `s`
is already part of `ARFLAGS`.

## Symbol analysis with `nm`

`nm lib/libmyutils.a` lists the symbol table of every object file in the
archive — showing which functions (`T` = defined in the text/code section)
each `.o` provides, and any undefined external references (`U`) it needs.
Running `nm bin/client_static` on the final executable shows the same
library functions now defined directly inside the binary (statically
linked in), confirming the code was copied into the executable rather than
referenced externally.

---

# Feature 4: Dynamic Library (v0.3.1)

## Position-Independent Code (PIC) requirements

Shared libraries must be loadable at any memory address chosen by the
dynamic linker at runtime, since multiple unrelated processes may map the
same `.so` at different addresses in their own address space. Compiling
with `-fPIC` generates code that accesses data and calls functions using
relative addressing (through the Global Offset Table / Procedure Linkage
Table) instead of hardcoded absolute addresses, making the resulting object
code relocatable. This is why the dynamic build uses separate
`*_pic.o` object files, compiled with `$(PIC_FLAGS) = -fPIC`, kept distinct
from the plain objects used in the static build.

## Executable size differences


```bash
ls -lh bin/client_static bin/client_dynamic
```
In typical projects, `client_static` is noticeably larger than `client_dynamic` because the static build copies the library's compiled machine code directly into the final executable, whereas the dynamic binary merely holds runtime symbol references.
However, in this implementation, inspecting the two binaries reveals little to no noticeable difference in disk size. This occurs because libmyutils implements a concise set of small utility functions (mystrlen, mycat, etc.), contributing only a trivial amount of raw machine instructions (typically a few hundred bytes)

## `LD_LIBRARY_PATH` and the dynamic loader

At runtime, `ld.so` (the dynamic linker) must locate every shared library
an executable depends on. It searches, in order: paths baked into the
binary via `-rpath` (not used here), directories listed in
`LD_LIBRARY_PATH`, then the system cache built by `ldconfig`
(`/etc/ld.so.cache`), then default paths like `/lib` and `/usr/lib`. During
development, `export LD_LIBRARY_PATH=$PWD/lib:$LD_LIBRARY_PATH` was
required because `lib/libmyutils.so` lives outside any default search path.
`ldd bin/client_dynamic` confirms which shared objects the binary depends
on and whether they currently resolve. After `make install` (Feature 5),
this workaround is no longer necessary because the library is copied to
`/usr/local/lib` and `ldconfig` is run to refresh the cache.

---

# Feature 5: Documentation & Installation (v0.4.1)

## What is `groff` and how does man page formatting work?

`groff` (GNU roff) is the typesetting system `man` uses to render man
pages. Pages are plain text using roff "dot commands" — macros at the
start of a line, from the `man` macro package: `.TH` (title heading —
name, section, date, source), `.SH` (section heading), `.B`/`.I` (bold /
italic), `.BI` (alternating bold/italic, used for signatures), `.nf`/`.fi`
(no-fill / fill, to preserve literal code blocks), and `.PP` (new
paragraph). Running `man mycat` locates `mycat.3`, pipes it through groff,
and displays it via a pager.

## Why section 3 specifically?

The manual is split into numbered sections: 1 = user commands, 2 = system
calls, **3 = library functions**, 5 = file formats, 7 = miscellaneous,
8 = admin commands. Since `mycat()`, `mystrlen()`, etc. are C library
functions called from code (not standalone shell commands), they belong in
section 3 — installed to `man/man3/` and later
`$(PREFIX)/share/man/man3/`.

## What does the `install` target do, and why those specific paths?

`install` copies build artifacts from the project tree into standard FHS
locations so the library, headers, binary, and docs are usable system-wide:

- `bin/client_dynamic` → `$(PREFIX)/bin/client`
- `lib/libmyutils.so`, `lib/libmyutils.a` → `$(PREFIX)/lib/`
- `include/*.h` → `$(PREFIX)/include/`
- `man/man3/*.3` → `$(PREFIX)/share/man/man3/`

`PREFIX` defaults to `/usr/local`, the conventional location for
locally-built software, kept separate from files owned by the distro's
package manager under `/usr`.

## Why is `ldconfig` needed after installing the shared library?

`ldconfig` rebuilds the dynamic linker's cache (`/etc/ld.so.cache`). Even
though `/usr/local/lib` is typically already in the default search path,
the cache only updates when `ldconfig` runs — without it, `client` can fail
at launch with `error while loading shared libraries: libmyutils.so:
cannot open shared object file`, the same class of problem
`LD_LIBRARY_PATH` worked around during development in Feature 4.

## Why provide an `uninstall` target?

Clean removal is expected of any install system. `uninstall` mirrors
`install` exactly, deleting the same explicit paths, returning the system
to its pre-install state and making it easy to repeat
`make uninstall && make install` while testing.

## Why does `make install` need `sudo`?

`/usr/local/{bin,lib,include,share/man}` are root-owned; `install` fails
with a permission error otherwise, hence `sudo make install`. `PREFIX` can
be overridden (`make install PREFIX=$HOME/.local`) for a non-root,
user-local install.

## Git workflow for this feature

Branch `man-pages` was created off `dynamic-build`. Man pages and the
`install`/`uninstall` Makefile targets were added and committed
incrementally. An **annotated** tag `v0.4.1-final` was created
(`git tag -a v0.4.1-final -m "Documentation and installation system"`),
pushed with `git push origin man-pages --tags`, and a GitHub Release was
published from that tag. Finally, `man-pages` was merged into `main` via
`git checkout main && git merge man-pages`, closing out the project.

---

# Final Submission Notes

- All feature branches (`multifile-build`, `static-build`, `dynamic-build`,
  `man-pages`) remain pushed to GitHub alongside `main` for grading.
- Each version has a corresponding annotated tag and GitHub Release with
  compiled assets where applicable.
- `main` contains the fully merged history of all five features.
