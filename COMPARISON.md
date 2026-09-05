# Comparing `pbdutil` with Other macOS Clipboard Tools

`pbdutil` is not merely a more capable replacement for `pbcopy` and
`pbpaste`. Its strongest role is as a small command-line interface to the
macOS pasteboard: it can inspect the representations placed there by an
application and read or write the raw bytes of a selected representation.

That makes it particularly useful for diagnosing copy-and-paste compatibility,
extracting non-text data, and experimenting with AppKit pasteboards. Newer
tools offer broader format support and more polished workflows, but few retain
`pbdutil`'s compact, direct mapping onto `NSPasteboard`.

## At a glance

| Tool | Platforms | Best suited for | Typed data | Inspection | Writing | Notable limitation |
|---|---|---|---|---|---|---|
| `pbcopy` / `pbpaste` | macOS | Everyday text pipelines | Text, with limited RTF/EPS handling | None | Yes | Cannot request exactly one arbitrary representation |
| **`pbdutil`** | macOS | Inspecting and manipulating AppKit pasteboards | Fixed aliases for text, images, rich text, PDF, URLs, and more | Detailed type and size listing; raw indexed reads | One representation at a time | No arbitrary UTI argument or multi-representation write |
| `pbrich` | macOS | Writing rich or typed clipboard content | Arbitrary UTIs; common formats auto-detected | Lists common types, not current contents | Multiple types and file references | Primarily write-oriented |
| `copycat` | macOS, Linux, Windows | Cross-platform raw clipboard inspection and I/O | Arbitrary native format identifiers | List, preview, JSON, and watch | Single format from the CLI; atomic multiple formats through its C API | Larger scope and abstraction than `pbdutil` |
| `pngpaste` | macOS | Saving and converting clipboard images | Common image input/output formats | None | No | Image-only and file-oriented |
| `pbimg` | macOS | Sending a clipboard image to a file or stdout | Image data | None | No | Image extraction only |
| `clippy` | macOS | Copying files and rich content from Terminal into GUI apps | File references plus detected/rich formats | Workflow-oriented inspection through companion tooling | Yes | Not designed as a low-level raw-format debugger |

## Compared with `pbcopy` and `pbpaste`

The built-in commands deliberately provide a narrow Unix-style interface.
`pbcopy` reads stdin and normally stores it as plain text, while recognizing
RTF and EPS headers specially. `pbpaste` writes a preferred textual
representation to stdout; `-Prefer` changes the search order among text, RTF,
and PostScript, but does not restrict the result to one arbitrary pasteboard
type.

For ordinary shell use, that simplicity is an advantage:

```sh
printf '%s' 'hello' | pbcopy
pbpaste > note.txt
```

`pbdutil` becomes useful when the format itself matters:

```sh
pbdutil -r png > image.png
pbdutil -r html > fragment.html
pbdutil -w pdf < document.pdf
```

The current source maps the aliases `text`, `txt`, `tiff`, `png`, `pdf`,
`html`, `rtf`, `rtfd`, `tab`, `url`, `path`, and `font` to AppKit
`NSPasteboardType` constants. It can also operate as `pbcopy`, `pbpaste`, or
`pbclear` when installed under those names.

## Inspection is `pbdutil`'s defining feature

A macOS pasteboard can expose several representations of the same logical
content. A browser might publish plain text, HTML, RTF, and an application-
specific representation in one copy operation, allowing the receiving
application to choose the best format it understands.

`pbdutil` makes those representations visible:

```sh
pbdutil -l
pbdutil -lv
pbdutil -lvv
pbdutil -lvvv
```

The first three levels show supported aliases, native type names, and sizes.
At `-lvvv`, the program lists every advertised type, including types outside
its alias table, and assigns each an index. The raw bytes can then be read by
index:

```sh
pbdutil -R 3 > representation.bin
```

This is valuable when determining why content pasted from one GUI application
behaves differently in another. The built-in commands provide no comparable
inventory.

`pbdutil` also supports named/private pasteboards:

```sh
pbdutil -n scratch -w text
pbdutil -n scratch -r text
pbdutil -n scratch -d
```

This is unusual among clipboard CLIs and is useful for AppKit experiments or
simple local interprocess communication. `-c` clears a pasteboard and `-C`
counts its advertised types.

## The main limitation: writing only one representation

`pbdutil` declares a one-element type array before writing:

```objc
[pbd declareTypes:[NSArray arrayWithObject:type] owner:nil];
[pbd setData:data forType:type];
```

Each `-w` operation therefore replaces the pasteboard contents with a single
representation. It cannot reproduce a typical application copy operation
that publishes `public.utf8-plain-text`, `public.html`, and `public.rtf`
together. It also accepts only its built-in aliases; `-R` can read an unknown
type by index, but `-w` cannot write an arbitrary UTI string.

The companion `mkfw` fills one narrow gap: serialized RTFD data read by
`pbdutil -r rtfd` can be expanded into an RTFD file wrapper.

## Rich and arbitrary formats: `pbrich` and `copycat`

`pbrich` is the stronger choice when the task is to put rich content onto the
macOS clipboard. It auto-detects common binary formats, accepts arbitrary UTIs
with `-t`, supports a plain-text fallback, accepts file references, and can
register multiple types in one operation:

```sh
echo '<b>hello</b>' | pbrich -t public.html -p 'hello'
pbrich -f report.pdf
echo '<b>bold</b>' | pbrich -t public.html -t public.rtf
```

Its focus is the write path. `pbdutil` remains more convenient for examining
the representations already present on a pasteboard.

`copycat` is the closest modern general-purpose comparison. It treats the
clipboard as a map from native format identifiers to raw bytes. On macOS those
identifiers are UTIs; on Linux they are generally MIME types, and on Windows
they are Clipboard Format names. Its CLI can list, inspect, read, write, clear,
watch, and emit JSON:

```sh
copycat list
copycat read public.html > page.html
cat page.html | copycat write public.html
copycat --json
copycat watch
```

It also supports OSC 52 for remote shells and exposes a C ABI, including an
atomic multi-format write API. Compared with `pbdutil`, it is more portable,
more scriptable, and open-ended about format names. `pbdutil` is smaller,
macOS-native, supports named pasteboards, and uses short aliases that are easy
to type.

## Image-focused tools: `pngpaste` and `pbimg`

`pngpaste` is preferable when the goal is simply to save a clipboard image:

```sh
pngpaste screenshot.png
```

It accepts PNG, PDF, GIF, TIFF, and JPEG clipboard input and chooses PNG, GIF,
JPEG, or TIFF output from the filename extension. It therefore performs image
interpretation and conversion rather than exposing raw pasteboard bytes.

`pbimg` has a similarly focused interface and can write the image either to a
named file or to stdout:

```sh
pbimg screenshot.png
pbimg > screenshot.png
```

Use one of these tools to obtain an image conveniently. Use `pbdutil` when you
need to know whether the pasteboard contains PNG, TIFF, PDF, or several image
representations, or when you need the bytes of one exact representation.

## File-oriented workflows: `clippy`

Passing a file through `pbcopy` copies its bytes, not the Finder-style file
reference expected by applications such as Mail or Slack. `clippy` is designed
to bridge that gap:

```sh
clippy report.pdf
clippy *.jpg
```

It also detects content types, can publish rich HTML/RTF/plain-text content,
and includes terminal-oriented features such as recent-download selection and
an MCP server. These are higher-level productivity workflows. They overlap
with `pbdutil` at the pasteboard API boundary, but not in purpose: `clippy`
tries to make copying convenient, while `pbdutil` exposes what is actually on
the pasteboard.

## Which tool should you choose?

- Use `pbcopy` / `pbpaste` for ordinary text pipelines and maximum availability
  on macOS.
- Use `pbdutil` to inspect pasteboard types, extract a precise raw
  representation, test named pasteboards, or debug interoperability between
  applications.
- Use `pbrich` to write arbitrary UTIs, multiple representations, or file
  references on macOS.
- Use `copycat` when you want arbitrary-format inspection and I/O across
  macOS, Linux, and Windows, especially with JSON, watching, or remote-shell
  support.
- Use `pngpaste` or `pbimg` when the task is specifically to save an image.
- Use `clippy` when the desired result is Finder-like file copying or a richer
  terminal-to-GUI workflow.

The best shorthand is that `pbcopy` / `pbpaste` are text pipeline tools,
whereas `pbdutil` is a compact `NSPasteboard` inspection and manipulation
tool. Its implementation is old-fashioned and deliberately small, but that
directness is still useful.

## Sources

- [`pbdutil` repository](https://github.com/rok-git/pbdutil) and the source in
  this repository
- The `pbcopy(1)` / `pbpaste(1)` man page supplied with macOS
- [Apple `NSPasteboard` documentation](https://developer.apple.com/documentation/appkit/nspasteboard)
- [`pbrich`](https://github.com/waynehoover/pbrich)
- [`copycat`](https://github.com/georgemandis/copycat)
- [`pngpaste`](https://github.com/jcsalterego/pngpaste)
- [`pbimg`](https://github.com/paulsmith/pbimg)
- [`clippy`](https://github.com/neilberkman/clippy)

Information was checked on September 5, 2026. Features of third-party tools
may change after that date.
