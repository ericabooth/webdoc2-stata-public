*--------------------------------------------------------------------*
* mwe_full.do  --  full tour of webdoc2 features in one report
*
* Build with:    webdoc2 mwe_full.do, open cleanup
*
* Covers:  wdinit, wdnavbar (+ dropdown + external link),
*          wdtoc, wputh1/h2/h3, wput,
*          wd/wdclose (inline log),
*          button/buttonclose (collapsible code),
*          graphbutton/graphbuttonclose + wgraph,
*          wdimg, wdlist + wditem + wdlistend,
*          wditemize, wdenumerate,
*          wdwidth.
*
* House rules (memorize -- these silently misparse otherwise):
*   1. wdinit name        -- bare name, NOT quoted
*   2. Inside button blocks use plain "" quotes, not compound quotes
*   3. Do not put slash-star inside any wput / wputh text (Stata reads
*      it as the start of a block comment and swallows the rest)
*   4. wdnavbar* and wdwidth go OUTSIDE any wd/button block
*--------------------------------------------------------------------*

wdinit mwe_full, replace

* Page width (default is 90% -- tweak if you have wide tables/graphs)
wdwidth 1100px

* ── 1. Navbar with dropdown + external link ────────────────────────────
wdnavbar Webdoc2 MWE
wdnavdropdown Sections
    wdnavdropdownitem Intro      , href(#intro)
    wdnavdropdownitem Analysis   , href(#analysis)
    wdnavdropdownitem Findings   , href(#findings)
    wdnavdropdownitem Reference  , href(#reference)
wdnavdropdownclose
wdnavitem Stata , href(https://www.stata.com)
wdnavbarclose

* ── 2. Intro + auto TOC ───────────────────────────────────────────────
wputh1 Intro
wdtoc Contents, depth(2)
wput This is a webdoc2 minimum working example. Everything you see was generated from a single Stata do-file -- no HTML written by hand.

* ── 3. Analysis section ───────────────────────────────────────────────
wputh1 Analysis

wputh2 Summary statistics (inline)
wput The auto dataset, basic numeric summaries:
wd
sysuse auto, clear
summarize price mpg weight length, detail
wdclose

wputh2 Regression (collapsed by default)
wput Click the panel to reveal the model and coefficients.
button
sysuse auto, clear
regress price mpg weight foreign
buttonclose

wputh2 Scatter plot (collapsed graph)
graphbutton
sysuse auto, clear
twoway (scatter price mpg) (lfit price mpg), title("Price vs MPG with linear fit") legend(off)
wgraph, width(700)
graphbuttonclose

* ── 4. Findings -- lists ──────────────────────────────────────────────
wputh1 Findings

wputh3 Dashed bullets (wdlist)
wdlist
    wditem Price rises with weight; the linear fit slope is positive.
    wditem MPG falls as weight rises.
    wditem Foreign cars are lighter than domestic ones on average.
wdlistend

wputh3 Round bullets (wditemize)
wditemize
    wditem Loaded auto.dta with sysuse.
    wditem Regressed price on mpg, weight, foreign.
    wditem Plotted price vs mpg with a linear fit.
wdlistend

wputh3 Numbered (wdenumerate)
wdenumerate
    wditem Open quickstart.do or this file.
    wditem Run webdoc2 mwe_full.do, open in Stata.
    wditem A browser window opens with the rendered report.
wdlistend

* ── 5. Reference card ─────────────────────────────────────────────────
wputh1 Reference
wputh2 Headings + text
wput  wputh1, wputh2, wputh3 -- headings with auto-id anchors
wput  wput TEXT -- a single paragraph

wputh2 Code + graph blocks
wput  wd / wdclose -- run code, log output inline
wput  button / buttonclose -- run code, output in a collapsible panel
wput  graphbutton / graphbuttonclose -- same but for graphs (pair with wgraph)

wputh2 Navigation
wput  wdnavbar BRAND / wdnavbarclose -- responsive sticky navbar
wput  wdnavitem LABEL, href(URL) -- top-level external link
wput  wdnavdropdown LABEL -- dropdown menu for in-page anchors

wputh2 Layout
wput  wdtoc TITLE, depth(N) -- in-page table of contents
wput  wdwidth 90% -- override the page content width
wput  wdimg PATH, caption(TEXT) -- image with optional figure caption
wput  wdiframe SRC, height(H) -- iframe (dashboards, sub-reports)

wputh2 Lists
wput  wdlist -- dashed bullets
wput  wditemize -- round bullets
wput  wdenumerate -- numbered
wput  wditem TEXT -- one item (inside any list opener)
wput  wdlistend -- close any list

webdoc close
