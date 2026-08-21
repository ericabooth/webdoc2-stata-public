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

### 3. Get `header.html` (for the Bootstrap theme — `net install` will not place it)

`net install` copies only recognised extensions (`.ado`, `.sthlp`, …), so `header.html` — the Bootstrap‑5 CSS/JS template — is an **ancillary** file. Two situations need no fetch at all: `wdinit myfile, replace headerfile("mytheme.html")` injects any header file you name (the `headerfile()` option works as of the Aug 2026 fix; earlier copies silently ignored it), and projects scaffolded by `projectbuilder` v2.1.0+ ship their own fallback header, so their docs render with nothing beyond this install. For webdoc2's own Bootstrap theme, `net get` fetches it into the current directory:

```stata
net get webdoc2, from("https://raw.githubusercontent.com/ericabooth/webdoc2-stata-public/main/")
```

`wdinit` reads `header.html` from the current directory, so run your report build from the folder you dropped it in. To make it available everywhere instead, copy it once onto your adopath:

```stata
copy header.html "`c(sysdir_personal)'header.html", replace
```

### 4. Confirm it's wired up

```stata
which webdoc2          // should print the .ado path
capture confirm file header.html   // rc=0 means wdinit can find it
help  webdoc2          // shows the full reference
```

If `header.html` is missing and no `headerfile()` is named, `wdinit` stops and says so. See [Troubleshooting](#troubleshooting) below.

### Re-installing later

```stata
ado uninstall webdoc2
net install webdoc2, from("https://raw.githubusercontent.com/ericabooth/webdoc2-stata-public/main/") replace force
discard
which webdoc2
help webdoc2

```

### Manual install (no internet)

Drop every file from this repo (every `.ado`, the `.sthlp`, **and** `header.html`) into a folder on your Stata `adopath` — e.g. `c(sysdir_personal)`. Then `help webdoc2` should work.

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
| `wdinit NAME, replace` | Open a report (Bootstrap‑5 header injected). Use the **bare** name, NOT quoted. |
| `webdoc close` | Close and write the HTML. (Last line of every do‑file.) |
| `wput TEXT` | `<p>TEXT</p>` |
| `wputh1 TEXT` / `wputh2` / `wputh3` | `<h1 id="auto-slug">TEXT</h1>` — the `id` is auto-derived from the text |
| `wd` … `wdclose` | Inline logged code block (`webdoc stlog`) |
| `button` … `buttonclose` | Collapsible "Click to view code" panel (runs the code, logs the output) |
| `graphbutton` … `graphbuttonclose` | Same as `button` but for graphs — pair with `wgraph` inside the block |
| `wgraph, width(N)` | Export the last graph at width `N` (pixels) — use inside `graphbutton`/`graphbuttonclose` |
| `wdnavbar BRAND` … `wdnavbarclose` | Responsive sticky navbar |
| `wdnavitem LABEL, href(URL) [active]` | Top‑level nav link (external URL or subpage) |
| `wdnavdropdown LABEL` … `wdnavdropdownclose` | Dropdown menu inside the navbar |
| `wdnavdropdownitem LABEL, href(#anchor)` | One item inside a dropdown — `#anchor` matches a `wputh*` auto‑id |
| `wdtoc TITLE, depth(N)` | In‑page table of contents (JS auto‑fills with heading links) |
| `wdwidth 1100px` | Override page content width (any CSS length; default 90%) |
| `wdimg PATH, caption(TEXT)` | Static image, optionally wrapped in `<figure>` |
| `wdiframe SRC, height(H)` | Embed an iframe (dashboards, sub‑reports) |
| `wdlist` / `wditemize` / `wdenumerate` … `wditem TEXT` … `wdlistend` | Dashed / round / numbered lists |

Full reference: `help webdoc2` after install.

---

## Build options

```stata
webdoc2 myreport.do [, open cleanup OPTIONS]
```

| Option | What it does |
| --- | --- |
| `open` | After build, open the HTML in your default browser (`open` on macOS, `start` on Windows, `xdg-open` on Linux). |
| `cleanup` | Delete intermediate `.log` / `.smcl` files generated for each `wd`/`button`/`graphbutton` block. PNG/JPG graph files are kept (the HTML references them). |
| `replace` | Passed through to `webdoc do` — overwrites existing HTML. |
| other | Any other option is passed through to `webdoc do` unchanged (e.g. `logall`, `grdir()`). |

---

## Gotchas (memorize these — they silently misparse otherwise)

These are the lessons from building real reports with `webdoc2`. The help file documents them too; the highlights:

1. **`wdinit NAME` must be a bare name, NOT quoted.** `wdinit "report"` breaks `button`/`buttonclose` accordion handling inside the build.
2. **`button … buttonclose` RUNS the code between them.** It does not just *show* it. To display a sample command in docs, use `webdoc put` with `<pre>` HTML, or escape the command.
3. **Don't put `/*` inside any `wput` / `wputh*` text.** Stata reads `/*` as the start of a block comment and swallows the rest of the do‑file. Use HTML entities (`&#42;`) or rephrase.
4. **Use plain `""` quotes inside `button`/`buttonclose` blocks**, not Stata's compound `` `"..."' ``. Compound quotes get logged into the HTML and then trip Stata's parser when `webdoc2findreplace` re-reads the file.
5. **Apostrophes in possessives** (`Radyakin's`) terminate macro references mid-string. Phrase as "by X" or use `&#39;`.
6. **`wdnavbar*` and `wdwidth` go OUTSIDE any `wd`/`button` block.** They emit HTML structure; the logger interprets them as Stata commands inside a stlog.
7. **`else` must be on the same physical line as the preceding `}`.** Standalone `else if` lines silently fall through inside `webdoc do`.
8. **Same-origin policy for iframes.** When you open the HTML via `file://`, iframes can only load files from the *same directory*. Either co-locate the iframe target with the report, or serve the directory with `python3 -m http.server`.

---

## Troubleshooting

**`wdinit: header.html not found`**

The Bootstrap‑5 template `header.html` isn't on your adopath. Check:

```stata
adopath
which header.html
```

The directory containing `webdoc2.ado` must also contain `header.html`. If `net install` placed the ado in `PLUS` but not the html, redo the install with `replace`. To use a custom theme: `wdinit myfile, replace headerfile("my_theme.html")`.

**`file ...file.tmp already exists`**

A stale tempfile from a prior crashed build. Copy the full path from the error, run `rm "paste_path_here"` in Stata, re-run `webdoc2`.

**`invalid syntax` after `buttonclose` / `wdclose` etc.**

Almost always (a) compound quotes inside the block, (b) an unclosed `wd`/`button`/`graphbutton`, or (c) a leftover `else` on its own line. See the gotchas list.

**The HTML built but the iframe is blank.**

Open the rendered HTML, open the browser's JS console (`Cmd-Option-J` in Chrome on Mac). You'll see a CORS / same-origin error. Co-locate the iframe target with the report, or serve via `python3 -m http.server`.

**My `webdoc` updated and now everything breaks.**

`webdoc2` calls into `webdoc` internals. Pin to the version of `webdoc` that was current when you installed `webdoc2`, or open an issue with the `webdoc` version string from `which webdoc`.


Example site it produces is here: [https://ericabooth.github.io/Webdoc2_Example_Site/](https://ericabooth.github.io/Webdoc2_Example_Site/)
---

## Acknowledgments

`webdoc2` is built on top of **`webdoc`** by **Ben Jann** (University of Bern). Install it from SSC: `ssc install webdoc`. Without `webdoc` doing the actual literate‑programming work, none of this layer exists.

The Bootstrap‑5 theme draws from the upstream Bootstrap CDN and a small amount of hand‑rolled CSS in `header.html`.

---

## Author

Eric A. Booth, Sr Researcher, Texas 2036 (eric.a.booth@gmail.com).

Issues and PRs welcome at [github.com/ericabooth/webdoc2-stata-public](https://github.com/ericabooth/webdoc2-stata-public).
