# webdoc2

**A Bootstrap‑5 reporting wrapper for Ben Jann's [`webdoc`](https://ideas.repec.org/c/boc/bocode/s458530.html) — turn a Stata do‑file into a full HTML report without writing HTML. This program greatly benefits from the Stata programming of Ben Jann see: [https://github.com/benjann](https://github.com/benjann)**

`webdoc2` is a thin layer of conveniences on top of `webdoc`. You keep writing Stata. `webdoc2` gives you short, semantic commands (`wputh1`, `button`, `graphbutton`, `wdnavbar`, `wdtoc`, …) that compile to a polished, responsive, Bootstrap‑5‑themed HTML document — collapsible code panels, in‑page table of contents, navbar with anchor‑linked dropdowns, captioned figures, embedded iframes, the works.

```stata
wdinit quickstart, replace

wputh1 Quickstart
wput   This page was generated from a 20-line Stata do-file by webdoc2.

wputh2 Run a regression and show the output inline
wd
sysuse auto, clear
regress price mpg weight
wdclose

wputh2 Same regression but collapsed by default
button
sysuse auto, clear
regress price mpg weight foreign
buttonclose

webdoc close
```

That's a complete, navigable HTML report. Run `webdoc2 quickstart.do, open` and your browser opens it.

> [!IMPORTANT]
> **webdoc2 is a wrapper, not a fork.** It calls into Ben Jann's `webdoc` for the heavy lifting. **Changes to `webdoc` upstream may break `webdoc2`** — this is the trade‑off for the convenience layer. If you hit a parse error after a `webdoc` update, pin the working `webdoc` version (`ssc install webdoc, replace` from an older mirror) or open an issue.

---

<img width="720" height="405" alt="Slide1" src="https://github.com/user-attachments/assets/91a8c759-0048-48d9-abfc-0d7b91580025" />

## Why you'd reach for this

- **Literate programming in plain Stata.** Headings, paragraphs, code blocks, graphs, lists, navbars — every output type is a one-word command (`wputh2`, `button`, `wdlist`, `wdnavbar`…). No `<div class="...">` boilerplate, no HTML escapes, no JavaScript to wire up.
- **Click-to-expand code and graph panels.** `button`/`buttonclose` and `graphbutton`/`graphbuttonclose` wrap any logged block in a Bootstrap accordion. Readers see your narrative; they click to dig into the code.
- **Auto-anchored headings and TOC.** `wputh1 Summary Statistics` emits `<h1 id="summary-statistics">…</h1>` and a `wdtoc` placeholder JS-fills with links to every heading on the page — no manual `id` wiring.
- **Responsive Bootstrap-5 navbar.** `wdnavbar` + `wdnavdropdown` give you a sticky navbar with dropdown menus to in-page anchors and top-level external links — write the structure in 5 lines, never touch HTML.
- **Embed dashboards.** `wdiframe sparkta_dashboard.html, height(800px)` drops an interactive dashboard into the report. Works with [`sparkta`](https://ideas.repec.org/c/boc/bocode/s459167.html) and `statashiny`.
- **Reproducible by default.** Every report is built by re-running the do-file. Numbers, figures, and panel contents always match the code that produced them.
- **One command to build + open + clean up.** `webdoc2 myreport.do, open cleanup` runs the do-file, scrubs the intermediate logs, and opens the HTML in your default browser.

---

<img width="720" height="405" alt="Slide2" src="https://github.com/user-attachments/assets/90835d58-5f33-4c3a-a58b-1888ba817583" />

## Installation

This is the **slightly tricky part**: `webdoc2` is a wrapper, so it depends on Ben Jann's `webdoc` being installed first. All three steps are one-liners in Stata.

### 1. Install the upstream dependency (Ben Jann's `webdoc`)

```stata
ssc install webdoc, replace
```

That comes from SSC and is a hard dependency. `webdoc2` will not work without it.

### 2. Install `webdoc2` itself from GitHub

```stata
net install webdoc2, from("https://raw.githubusercontent.com/ericabooth/webdoc2-stata-public/main/") replace force
```

This drops ~28 `.ado` files and the help file into your `PLUS` directory.

### 3. (Optional) Get an editable `header.html`

`net install` copies only recognised extensions (`.ado`, `.sthlp`, …), so `header.html` — the Bootstrap‑5 CSS/JS template — is an **ancillary** file. Since 1.1.5 you do not need it: when no `header.html` is in the working directory or on the adopath, `wdinit` uses an identical built-in copy stored in `_webdoc2_header.ado`, which `net install` and `ssc install` do place. Fetch the file only to edit it into a custom theme. To get the editable copy, run `net get`, which places it in the current directory:

```stata
net get webdoc2, from("https://raw.githubusercontent.com/ericabooth/webdoc2-stata-public/main/")
```

`wdinit` prefers a `header.html` in the current directory, so run your report build from the folder you dropped it in. To make it available everywhere instead, copy it once onto your adopath:

```stata
copy header.html "`c(sysdir_personal)'header.html", replace
```

### 4. Confirm it's wired up

```stata
which webdoc2          // should print the .ado path
findfile _webdoc2_header.ado      // built-in header that wdinit falls back to
help  webdoc2          // shows the full reference
```

If `header.html` is missing and no `headerfile()` is named, `wdinit` uses the built-in header. `headerfile()` accepts absolute paths, paths relative to the working directory, `~/` paths, and file names on the adopath. See [Troubleshooting](#troubleshooting) below.

### Re-installing later

```stata
ado uninstall webdoc2
net install webdoc2, from("https://raw.githubusercontent.com/ericabooth/webdoc2-stata-public/main/") replace force
discard
which webdoc2
help webdoc2

```

### Manual install (no internet)

Drop every file from this repo (every `.ado` including `_webdoc2_header.ado`, the `.sthlp`, and optionally `header.html`) into a folder on your Stata `adopath` — e.g. `c(sysdir_personal)`. Then `help webdoc2` should work.

---

## Quickstart

Save the example as `report.do` and run `webdoc2 report.do, open`. (Both [examples/quickstart.do](examples/quickstart.do) and [examples/mwe_full.do](examples/mwe_full.do) are in this repo.)

```stata
wdinit report, replace

wputh1 My first webdoc2 report
wput   Everything below was generated by Stata.

wputh2 Inline log
wd
sysuse auto, clear
summarize price mpg weight
wdclose

wputh2 Click-to-view code
button
sysuse auto, clear
regress price mpg weight
buttonclose

wputh2 Click-to-view graph
graphbutton
sysuse auto, clear
scatter price mpg
wgraph, width(600)
graphbuttonclose

webdoc close
```

That's a complete, working report. Run `webdoc2 report.do, open`. Done.

---

## A fuller tour

```stata
wdinit report, replace
wdwidth 1100px

* Navbar with anchor-linked dropdown + external link
wdnavbar My Report
wdnavdropdown Contents
    wdnavdropdownitem Intro     , href(#intro)
    wdnavdropdownitem Analysis  , href(#analysis)
    wdnavdropdownitem Findings  , href(#findings)
wdnavdropdownclose
wdnavitem Stata , href(https://www.stata.com)
wdnavbarclose

* Intro + auto TOC
wputh1 Intro
wdtoc  Contents, depth(2)
wput   This report was built from a single Stata do-file.

* Analysis section
wputh1 Analysis
wputh2 Summary statistics
wd
sysuse auto, clear
summarize price mpg weight
wdclose

wputh2 Regression (collapsible)
button
regress price mpg weight foreign
buttonclose

wputh2 Scatter (collapsible graph)
graphbutton
twoway (scatter price mpg) (lfit price mpg), legend(off)
wgraph, width(700)
graphbuttonclose

* Findings as bullets
wputh1 Findings
wdlist
    wditem Price rises with weight.
    wditem MPG falls as weight rises.
    wditem Foreign cars are lighter on average.
wdlistend

* Optional: embed an interactive dashboard
* wdiframe dashboard.html, height(800px)

webdoc close
```

Build with `webdoc2 report.do, open cleanup`.

See [examples/mwe_full.do](examples/mwe_full.do) for a longer reference that exercises every command in the package — it builds without errors and is run as part of the package smoke tests.

---

## Command cheat sheet

| Command | What it emits |
| --- | --- |
| `wdinit [NAME] [, replace headerfile(PATH) webdoc-init-options]` | Open a report (Bootstrap‑5 header injected). Quote a name with spaces. Without a name the report is `DOFILE.html`. |
| `webdoc close` | Close and write the HTML. (Last line of every do‑file.) |
| `wput TEXT` | `<p>TEXT</p>` |
| `wputh1 TEXT` / `wputh2` / `wputh3` | `<h1 id="auto-slug">TEXT</h1>` — the `id` is auto-derived from the text |
| `wd [NAME] [, stlog-options]` … `wdclose` | Inline logged code block (`webdoc stlog`; not `nooutput`/`nodo`/`cmdlog`/`dosave`) |
| `button` … `buttonclose` | Collapsible "Click to view code" panel (runs the code, logs the output) |
| `graphbutton` … `graphbuttonclose` | Same as `button` but for graphs — pair with `wgraph` inside the block |
| `wgraph [NAME] [, width(N) webdoc-graph-options]` | Export the last graph (as `NAME.png` when named) at width `N` pixels — use inside `graphbutton`/`graphbuttonclose` |
| `wdnavbar BRAND [, color() bg() brandhref(URL) id()]` … `wdnavbarclose` | Responsive sticky navbar (defaults `navbar-dark`, `bg-dark`, `#`, `mainNavbar`) |
| `wdnavitem LABEL, href(URL) [active]` | Top‑level nav link (external URL or subpage) |
| `wdnavdropdown LABEL [, id()]` … `wdnavdropdownclose` | Dropdown menu inside the navbar |
| `wdnavdropdownitem LABEL, href(#anchor)` | One item inside a dropdown — `#anchor` matches a `wputh*` auto‑id |
| `wdtoc [TITLE] [, depth(N) id() center indent(CSS length)]` | In‑page table of contents (JS auto‑fills with heading links) |
| `wdwidth 1100px` | Override page content width (any CSS length; default 90%) |
| `wdimg PATH [, width() alt() caption(TEXT) src()]` | Static image, optionally wrapped in `<figure>` |
| `wdiframe SRC [, width() height(H) class() border src()]` | Embed an iframe (dashboards, sub‑reports) |
| `wdlist` / `wditemize` / `wdenumerate` … `wditem TEXT` … `wdlistend` | Dashed / round / numbered lists |
| `webdoc2 help` | Check that `webdoc` and the header are found, then show the help file |

Full reference: `help webdoc2` after install.

---

## Build options

```stata
webdoc2 myreport.do [, open cleanup OPTIONS]
```

| Option | What it does |
| --- | --- |
| `open` | After build, open the HTML in your default browser (`open` on macOS, `start` on Windows, `xdg-open` on Linux). |
| `cleanup` | Delete the intermediate `REPORT_1.log`, `REPORT_2.log`, … (and `.smcl`) files generated for each `wd`/`button`/`graphbutton` block. PNG/JPG graph files are kept (the HTML references them), and so is a `REPORT.log` of your own. |
| `replace` | Not needed: `webdoc2` always passes `replace` to `webdoc do`, so rebuilding over an existing report works. |
| other | Any other option is passed through to `webdoc do` unchanged (e.g. `grdir()`, `cd`). `logall` is rejected with r(198): it would wrap `wdinit` and the other webdoc2 commands in stlog sections, which stopped every build with r(499). |

A relative `wdinit` name is relative to Stata's working directory, not to the do-file: `webdoc2 sub/report.do` run from the parent folder writes `report.html` in the parent folder. Build from the do-file's folder, or add webdoc's `cd` option (`webdoc2 sub/report.do, cd`).

---

## Gotchas (memorize these — they silently misparse otherwise)

These are the lessons from building real reports with `webdoc2`. The help file documents them too; the highlights:

1. **Heading slugs are ASCII only.** `wputh1 Résumé` gets `id="r-sum"`: accented letters are dropped. For such headings, write the tag yourself with `webdoc put <h1 id="resume">Résumé</h1>`.
2. **`button … buttonclose` RUNS the code between them.** It does not just *show* it. To display a sample command in docs, use `webdoc put` with `<pre>` HTML, or escape the command.
3. **Don't put `/*` inside any `wput` / `wputh*` text.** Stata reads `/*` as the start of a block comment and swallows the rest of the do‑file. Use HTML entities (`&#42;`) or rephrase.
4. **Compound quotes inside logged blocks are fine since 1.1.6.** Before, a long command with `` `"..."' `` that wrapped across lines in the log made the post-build scrub fail with r(132).
5. **Apostrophes in possessives** (`Radyakin's`) terminate macro references mid-string. Phrase as "by X" or use `&#39;`.
6. **`wdnavbar*` and `wdwidth` go OUTSIDE any `wd`/`button` block.** They emit HTML structure; the logger interprets them as Stata commands inside a stlog.
7. **`else` must be on the same physical line as the preceding `}`.** Standalone `else if` lines silently fall through inside `webdoc do`.
8. **`wd` takes `webdoc stlog` options, but not `nooutput`, `nodo`, `cmdlog`, or `dosave`.** `webdoc do` applies those only to literal `webdoc stlog` lines it finds when scanning the do-file, so before 1.1.5 `wd, nooutput` published the output anyway. `wd` now stops with r(198); write `webdoc stlog, nooutput` … `webdoc stlog close` for such sections.
9. **Same-origin policy for iframes.** When you open the HTML via `file://`, iframes can only load files from the *same directory*. Either co-locate the iframe target with the report, or serve the directory with `python3 -m http.server`.

---

## Troubleshooting

**`wdinit: header.html not found ... built-in header (_webdoc2_header.ado) is not installed`**

Since 1.1.5 this appears only when `_webdoc2_header.ado` is missing too (for example after copying files by hand). Check:

```stata
which webdoc2
findfile _webdoc2_header.ado
```

Reinstall with `net install webdoc2, ... replace`, fetch `header.html` with `net get webdoc2`, or name a theme: `wdinit myfile, replace headerfile("my_theme.html")`.

**`file ...file.tmp already exists`**

A stale tempfile from a prior crashed build. Copy the full path from the error, run `rm "paste_path_here"` in Stata, re-run `webdoc2`.

**`invalid syntax` after `buttonclose` / `wdclose` etc.**

Almost always (a) an unclosed `wd`/`button`/`graphbutton`, or (b) a leftover `else` on its own line. See the gotchas list. `webdoc2 help` checks that `webdoc` and the header are found.

**The HTML built but the iframe is blank.**

Open the rendered HTML, open the browser's JS console (`Cmd-Option-J` in Chrome on Mac). You'll see a CORS / same-origin error. Co-locate the iframe target with the report, or serve via `python3 -m http.server`.

**My `webdoc` updated and now everything breaks.**

`webdoc2` calls into `webdoc` internals. Pin to the version of `webdoc` that was current when you installed `webdoc2`, or open an issue with the `webdoc` version string from `which webdoc`.


Example site it produces is here: [https://ericabooth.github.io/Webdoc2_Example_Site/](https://ericabooth.github.io/Webdoc2_Example_Site/)
---

## Version history

- **1.1.6** (2026-11-09): `webdoc2` parses `replace` as an option instead of deleting the word from every option (`grdir(replacefigs)` became `grdir(figs)`); `webdoc2 help` checks the environment and returns 0 instead of ending with r(198); a report next to a do-file run from another folder is no longer emptied and deleted; `cleanup` no longer erases `REPORT.log`, which webdoc never writes; a wrapped compound-quoted command no longer fails the build with r(132); `open` uses the absolute path and expands `~`; quoted names and labels in `wdinit`, `wdnavbar`, `wdnavitem`, `wdnavdropdown`, `wdnavdropdownitem`, and `wdtoc` lose their quotes; a bare `wdinit` works; each accordion gets its own id; `wgraph` passes the graph name to `webdoc graph`.
- **1.1.5** (2026-11-09): `wdimg` width() and alt() reach the HTML; `wd` rejects `nooutput`, `nodo`, `cmdlog`, and `dosave` (it silently ignored them, publishing output meant to be hidden); `webdoc2, logall` stops with a clear message instead of r(499); `wdinit` no longer leaks a file handle per build (r(3611) after 48 builds in one session), falls back to a built-in header when `header.html` was not installed, and accepts absolute and `~/` paths in `headerfile()`.
- **1.1.4** (2026-11-08): `wdnavbar` brandhref() is accepted.

---

## Acknowledgments

`webdoc2` is built on top of **`webdoc`** by **Ben Jann** (University of Bern). Install it from SSC: `ssc install webdoc`. Without `webdoc` doing the actual literate‑programming work, none of this layer exists.

The Bootstrap‑5 theme draws from the upstream Bootstrap CDN and a small amount of hand‑rolled CSS in `header.html`.

---

## Author

Eric A. Booth, Sr Researcher, Texas 2036 (eric.a.booth@gmail.com).

Issues and PRs welcome at [github.com/ericabooth/webdoc2-stata-public](https://github.com/ericabooth/webdoc2-stata-public).
