{smcl}
{* *! version 1.1.2 23may2026 Author: Eric Booth}{...}
{vieweralsosee "[P] webdoc" "help webdoc"}{...}
{viewerjumpto "Syntax" "webdoc2##syntax"}{...}
{viewerjumpto "Description" "webdoc2##description"}{...}
{viewerjumpto "Subcommands" "webdoc2##subcommands"}{...}
{viewerjumpto "Installation" "webdoc2##installation"}{...}
{viewerjumpto "Troubleshooting" "webdoc2##troubleshooting"}{...}
{viewerjumpto "Tips & Tricks" "webdoc2##tips"}{...}
{viewerjumpto "Examples" "webdoc2##examples"}{...}
{viewerjumpto "Author" "webdoc2##author"}{...}
{hline}
Help file for {hi:webdoc2}
{hline}

{title:Title}

{phang}
{bf:webdoc2} {hline 2} A custom wrapper and utility suite for Ben Jann's {help webdoc} that
reduces HTML boilerplate and header/CSS setup, generates interactive and collapsible
navigation bars and logged-code sections, and supports embedding interactive JavaScript
content in reports (e.g., {bf:sparkta}-style dashboards from SSC)


{marker syntax}{...}
{title:Syntax}

{pstd}
Execute a do-file and process custom tags:

{phang2}
{cmd:webdoc2} {it:filename.do} [{cmd:,} {cmd:open} {cmd:cleanup} {it:options}]

{pstd}
Display this help file and diagnose the environment:

{phang2}
{cmd:webdoc2 help}

{pstd}
{bf:Custom Subcommands (used inside your do-file):}

{phang2}{cmd:wdinit} [{it:filename}] [{cmd:,} {cmd:headerfile(}{it:path}{cmd:)} {it:webdoc_init_options}] {hline 2} Initialize a report with Bootstrap 5 (replaces {cmd:webdoc init}){p_end}

{phang2}{cmd:wd} [{it:name}] [{cmd:,} {it:options}] {hline 2} Open a webdoc stlog (alias for {cmd:webdoc stlog}){p_end}
{phang2}{cmd:wdclose} {hline 2} Close a webdoc stlog (alias for {cmd:webdoc stlog close}){p_end}

{phang2}{cmd:button} {hline 2} Open a Bootstrap accordion "Click to view code" section (starts stlog){p_end}
{phang2}{cmd:buttonclose} {hline 2} Close the code accordion (ends stlog){p_end}

{phang2}{cmd:graphbutton} {hline 2} Open a Bootstrap accordion "Click to view" section (starts stlog){p_end}
{phang2}{cmd:graphbuttonclose} {hline 2} Close the graph accordion (ends stlog){p_end}

{phang2}{cmd:wput} {it:text} {hline 2} Insert {cmd:<p>} {it:text} {cmd:</p>}{p_end}
{phang2}{cmd:wputh1} {it:text} {hline 2} Insert {cmd:<h1 id="auto-slug">} {it:text} {cmd:</h1>} (id is the text slugified — see below){p_end}
{phang2}{cmd:wputh2} {it:text} {hline 2} Insert {cmd:<h2 id="auto-slug">} {it:text} {cmd:</h2>} (id is the text slugified){p_end}
{phang2}{cmd:wputh3} {it:text} {hline 2} Insert {cmd:<h3 id="auto-slug">} {it:text} {cmd:</h3>} (id is the text slugified){p_end}

{phang2}{cmd:wdnavbar} [{it:brand}] [{cmd:,} {cmd:color()} {cmd:bg()} {cmd:brandhref()} {cmd:id()}] {hline 2} Open a Bootstrap 5 navbar{p_end}
{phang2}{cmd:wdnavitem} [{it:label}] [{cmd:,} {cmd:href(}{it:url}{cmd:)} {cmd:active}] {hline 2} Add a top-level nav link (for subpages or external URLs){p_end}
{phang2}{cmd:wdnavbarclose} {hline 2} Close the navbar{p_end}

{phang2}{cmd:wdnavdropdown} [{it:label}] [{cmd:,} {cmd:id(}{it:string}{cmd:)}] {hline 2} Open a dropdown menu inside the navbar (default label: {cmd:Contents}){p_end}
{phang2}{cmd:wdnavdropdownitem} [{it:label}] [{cmd:,} {cmd:href(}{it:url}{cmd:)}] {hline 2} Add one item to the dropdown (use {cmd:href(#anchor)} for in-page links){p_end}
{phang2}{cmd:wdnavdropdownclose} {hline 2} Close the dropdown menu{p_end}

{phang2}{cmd:wdtoc} [{it:title}] [{cmd:,} {cmd:id(}{it:string}{cmd:)} {cmd:center} {cmd:indent(}{it:spec}{cmd:)} {cmd:depth(}{it:#}{cmd:)}] {hline 2} Insert an auto-generated in-page table of contents{p_end}

{phang2}{cmd:wdwidth} [{it:width}] {hline 2} Set page content width (default: {cmd:90%}). Any CSS value accepted: {cmd:80%}, {cmd:1200px}, {cmd:100%}, etc.{p_end}

{phang2}{cmd:wdiframe} {it:src} [{cmd:,} {cmd:width()} {cmd:height()} {cmd:class()} {cmd:border}] {hline 2} Embed an iframe (Sparkta dashboards, external pages, sub-reports){p_end}

{phang2}{cmd:wdimg} {it:path} [{cmd:,} {cmd:width()} {cmd:alt()} {cmd:caption()}] {hline 2} Insert an image, optionally wrapped in {cmd:<figure>} with a caption{p_end}

{phang2}{cmd:wdlist} / {cmd:wditemize} / {cmd:wdenumerate} + {cmd:wditem} {it:text} + {cmd:wdlistend} {hline 2} LaTeX-style lists: dashed bullets, round bullets, or numbered{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:webdoc2} is a post-processor and shortcut suite for {help webdoc}.
{bf:Acknowledgment:} This package wraps Ben Jann's {help webdoc} to reduce HTML
boilerplate when building Bootstrap-enabled reports.

{pstd}
When you run {cmd:webdoc2 myfile.do}, the program executes your code using
{cmd:webdoc do} and then triggers {cmd:webdoc2findreplace}, which scrubs any
stray closing-command echoes (e.g. {cmd:. buttonclose}, {cmd:. wdclose}) from
the HTML output at any indentation level.

{pstd}
{cmd:webdoc2} options:

{p2colset 9 20 20 2}
{p2col:{cmd:open}}After building the report, open the HTML file in the
system default browser. Works on macOS ({cmd:open}), Windows ({cmd:start}),
and Linux ({cmd:xdg-open}).{p_end}
{p2col:{cmd:cleanup}}After building, delete the intermediate {cmd:.log} and
{cmd:.smcl} files generated by {cmd:webdoc do} for each stlog block
({cmd:report_1.log}, {cmd:report_2.log}, ...). PNG/JPG/SVG graph files are
kept because the HTML references them. The output HTML and any image files
are untouched.{p_end}
{p2col:{it:other options}}All standard {cmd:webdoc do} options pass through
unchanged (e.g. {cmd:logall}, {cmd:grdir()}).{p_end}
{p2colreset}{...}


{marker subcommands}{...}
{title:Subcommands in Detail}

{phang}{bf:wdinit — Bootstrap 5 initializer}

{phang2}
Drop-in replacement for {cmd:webdoc init}. Locates {cmd:header.html} in the
adopath (or a file you specify) and injects it into the document {cmd:<head>}.
This enables the Bootstrap 5 accordion, responsive navbar, back-to-top button,
and the TOC without any manual {cmd:header()} options.

{p2colset 9 30 30 2}
{p2col:{cmd:headerfile(}{it:path}{cmd:)}}Path to a custom header file.
Default: {cmd:header.html} from the adopath. Use this to apply a completely
different Bootstrap theme without changing your do-file.{p_end}
{p2col:{it:other options}}All standard {cmd:webdoc init} options pass through
unchanged (e.g. {cmd:replace}, {cmd:logall}, {cmd:grdir()}).{p_end}
{p2colreset}{...}

{phang}{bf:Logging Shortcuts}

{phang2}
{cmd:wd} / {cmd:wdclose}: Wraps a block of Stata output in a plain
{cmd:webdoc stlog} section — output appears inline on the page.

{phang}{bf:Interactive Bootstrap Accordions}

{phang2}
{cmd:button} / {cmd:buttonclose}: Wraps code + output in a "Click to view
code" collapsible accordion. Requires Bootstrap 5 JS (loaded by {cmd:wdinit}).

{phang2}
{cmd:graphbutton} / {cmd:graphbuttonclose}: Same as above, labelled
"Click to view".

{phang}{bf:HTML Wrappers}

{phang2}
{cmd:wput}, {cmd:wputh1}–{cmd:wputh3}: Insert paragraph and heading tags.
All accept free-form text including commas and words like "using", "if", "in".

{phang2}
The three heading commands ({cmd:wputh1}, {cmd:wputh2}, {cmd:wputh3})
automatically receive an {cmd:id="..."} attribute derived from the heading
text — lowercased, runs of non-alphanumeric characters replaced by {cmd:-},
trimmed at both ends. This means you can link to a heading with
{cmd:wdnavdropdownitem ..., href(#auto-slug)} without writing any HTML by
hand, and you do {bf:not} need to wrap sections in {cmd:<div id="...">}.

{phang2}
Slug examples:

{p2colset 9 38 38 2}
{p2col:{cmd:wputh1 Home}}{cmd:<h1 id="home">Home</h1>}{p_end}
{p2col:{cmd:wputh2 Summary Statistics}}{cmd:<h2 id="summary-statistics">...</h2>}{p_end}
{p2col:{cmd:wputh3 R & D Notes}}{cmd:<h3 id="r-d-notes">...</h3>}{p_end}
{p2col:{cmd:wputh1 Section 1.2}}{cmd:<h1 id="section-1-2">...</h1>}{p_end}
{p2colreset}{...}

{phang2}
{bf:Note:} If two headings share identical text, they'll receive identical ids.
For unique custom ids, write the {cmd:<h?>} tag yourself with {cmd:webdoc put}.

{phang}{bf:Bootstrap 5 Navbar}

{phang2}
{cmd:wdnavbar} / {cmd:wdnavbarclose}: Opens and closes a responsive sticky
navigation bar. Brand names may be quoted or unquoted. Place outside any
stlog block.

{phang2}
The recommended pattern: use {cmd:wdnavdropdown} for in-page anchor links
(grouped in a dropdown menu) and {cmd:wdnavitem} for top-level links to
subpages or external URLs.

{phang2}
{cmd:wdnavbar} options:

{p2colset 9 26 26 2}
{p2col:{cmd:color()}}Navbar text scheme. Default: {cmd:navbar-dark}.{p_end}
{p2col:{cmd:bg()}}Background class. Default: {cmd:bg-dark}. Others: {cmd:bg-primary}, {cmd:bg-light}.{p_end}
{p2col:{cmd:brandhref()}}Brand link URL. Default: {cmd:#}.{p_end}
{p2col:{cmd:id()}}Collapse div ID. Default: {cmd:mainNavbar}. Change when using multiple navbars.{p_end}
{p2colreset}{...}

{phang2}
{cmd:wdnavitem} options (top-level links — subpages, external URLs):

{p2colset 9 18 18 2}
{p2col:{cmd:href()}}Link target. Use {cmd:file.html} for multi-page or a full URL for external.{p_end}
{p2col:{cmd:active}}Marks this tab as the current page.{p_end}
{p2colreset}{...}

{phang2}
{cmd:wdnavdropdown} / {cmd:wdnavdropdownitem} / {cmd:wdnavdropdownclose}:
Adds a dropdown menu inside the navbar — the preferred way to list in-page
anchor links. One {cmd:wdnavdropdown} block per page section group.

{phang2}
{cmd:wdnavdropdown} options:

{p2colset 9 12 12 2}
{p2col:{it:label}}Dropdown button label. Default: {cmd:Contents}.{p_end}
{p2col:{cmd:id()}}HTML id for aria. Default: {cmd:wdNavDD1} (auto-increments).{p_end}
{p2colreset}{...}

{phang2}
{cmd:wdnavdropdownitem} options:

{p2colset 9 12 12 2}
{p2col:{cmd:href()}}Link target. Use {cmd:#anchor} for in-page sections.{p_end}
{p2colreset}{...}

{phang}{bf:In-page Table of Contents}

{phang2}
{cmd:wdtoc} writes a placeholder div; JavaScript in {cmd:header.html} fills
it automatically with links to every heading on the page up to the requested
{cmd:depth()} (skipping navbar and accordion headers). Place {cmd:wdtoc}
anywhere in the page body.

{p2colset 9 22 22 2}
{p2col:{it:title}}Optional heading above the links. Default: {cmd:Contents}.{p_end}
{p2col:{cmd:id()}}HTML id of the container. Default: {cmd:wd-toc}. Change when using multiple TOCs.{p_end}
{p2col:{cmd:center}}Center the TOC horizontally on the page (wraps it in a centered container).{p_end}
{p2col:{cmd:indent(}{it:spec}{cmd:)}}Indent the TOC from the left margin. Accepts any CSS length, e.g. {cmd:2em}, {cmd:40px}, {cmd:5%}.{p_end}
{p2col:{cmd:depth(}{it:#}{cmd:)}}Heading levels to include, {cmd:1}-{cmd:6}. Default: {cmd:3} (h1+h2+h3). Use {cmd:depth(2)} for top-level sections only, {cmd:depth(4)} or higher to include subsections.{p_end}
{p2colreset}{...}

{phang2}
Examples:{break}
{cmd:wdtoc Contents, center}{break}
{cmd:wdtoc Sections, depth(2)}{break}
{cmd:wdtoc Outline, indent(2em) depth(4)}{break}
{cmd:wdtoc} {space 2}(defaults: title {cmd:Contents}, depth {cmd:3}, left-aligned)

{phang}{bf:Page Width}

{phang2}
{cmd:wdwidth} writes a short {cmd:<style>} block that overrides the
{cmd:--wd-page-width} CSS variable. The default (set in {cmd:header.html}) is
{cmd:90%}. Call {cmd:wdwidth} anywhere outside a stlog block to change the
width for the rest of the page. Any CSS length is accepted.

{phang2}
Examples:{break}
{cmd:wdwidth 80%}{break}
{cmd:wdwidth 1200px}{break}
{cmd:wdwidth 100%}{break}
{cmd:wdwidth} {space 4}(resets to {cmd:90%})

{phang}{bf:Media & Lists}

{phang2}
{cmd:wdiframe}: Embed an iframe with sensible defaults (no border, rounded
corners, drop shadow, vertical margin). Useful for Sparkta dashboards,
embedded HTML reports, and external pages.

{p2colset 9 22 22 2}
{p2col:{it:src}}First positional argument or {cmd:src()}: URL or file path.{p_end}
{p2col:{cmd:width()}}CSS width. Default: {cmd:100%}.{p_end}
{p2col:{cmd:height()}}CSS height. Default: {cmd:800px}.{p_end}
{p2col:{cmd:class()}}Extra CSS class(es) for custom styling.{p_end}
{p2col:{cmd:border}}Add a thin grey border (off by default).{p_end}
{p2colreset}{...}

{phang2}
Examples:{break}
{cmd:wdiframe testsparkta.html}{break}
{cmd:wdiframe dashboard.html, height(600px)}{break}
{cmd:wdiframe https://example.com, width(80%) height(900px) border}

{phang2}
{bf:Important — iframe targets must live in the same directory as the report.}
When the parent HTML is opened via {cmd:file://} (the default for webdoc2
output), modern browsers (Chrome, Safari, Firefox) enforce the same-origin
policy {it:per directory} for the {cmd:file://} scheme. An iframe in
{cmd:/Shared drives/Data and Research Team/report.html} cannot load {cmd:/Desktop/dashboard.html} even
though both paths resolve correctly on disk. The iframe silently renders
blank (and the browser console will usually show a CORS/cross-origin error).

{phang2}
{bf:Two fixes:}

{p2colset 9 4 4 2}
{p2col:{cmd:(1)}}Export the dashboard / sub-report into the {it:same directory}
as the parent HTML and use a relative path:{p_end}
{p2colreset}{...}

{hline}
{cmd}
    * sparkta (SSC): use a plain filename — sparkta writes to Stata's CWD,
    * which is also where webdoc2 builds the report when you run it from a do-file.
    sparkta y x, export("testsparkta.html") offline
    wdiframe testsparkta.html, height(800px)

    * statashiny: pass export() so it doesn't fall back to the default path
    statashiny, build export("dash.html") open
    wdiframe dash.html, height(600px)
{txt}{hline}

{p2colset 9 4 4 2}
{p2col:{cmd:(2)}}Serve the report directory with a local web server (one line):{p_end}
{p2colreset}{...}

{hline}
{cmd}
    cd "/path/to/your/report/dir"
    python3 -m http.server 8000
    # then open http://localhost:8000/yourreport.html in a browser
{txt}{hline}

{phang2}
Under {cmd:http://}, the file:// per-directory restriction disappears entirely —
absolute paths and external URLs all work. This is the recommended setup if
you want dashboards on Desktop / Documents / elsewhere and a report stored
on Google Drive.

{phang2}
{bf:Symptom of the bug:} the iframe in your rendered HTML has an empty
{cmd:src}, malformed {cmd:src=""path""} (two quotes from passing a quoted
positional arg into wdiframe — fixed in v1.1.3), or a 404-like blank panel.
Open the rendered HTML in a browser and check the JavaScript console
({cmd:Cmd-Option-J} in Chrome on Mac) for the underlying error.

{phang2}
{cmd:wdimg}: Insert a static image. Without {cmd:caption()}, emits a plain
{cmd:<img>} sized to fit the page width. With {cmd:caption()}, wraps it in
{cmd:<figure>}/{cmd:<figcaption>} for styled rendering (figure styling lives
in {cmd:header.html}). Use {cmd:wgraph} for Stata-generated graphs;
{cmd:wdimg} is for PNG/JPG/SVG files you reference directly.

{p2colset 9 22 22 2}
{p2col:{it:path}}First positional argument or {cmd:src()}: image path or URL.{p_end}
{p2col:{cmd:width()}}Pixel or percentage width on the {cmd:<img>} element.{p_end}
{p2col:{cmd:alt()}}Alt text for accessibility.{p_end}
{p2col:{cmd:caption()}}Caption text — triggers the {cmd:<figure>} wrapper.{p_end}
{p2colreset}{...}

{phang2}
Examples:{break}
{cmd:wdimg logo.png}{break}
{cmd:wdimg figure1.png, width(600) alt(Distribution of price)}{break}
{cmd:wdimg figure2.png, caption(Figure 2: Price by region)}

{phang2}
{bf:Lists — LaTeX-style.} Three opener commands choose the marker style; one
item command works inside any of them; one universal close command works for
all three:

{p2colset 9 22 22 2}
{p2col:{cmd:wdlist}}Dashed bullets ({cmd:—}). Use for plain bulleted notes.{p_end}
{p2col:{cmd:wditemize}}Round bullets (default browser disc/circle markers).{p_end}
{p2col:{cmd:wdenumerate}}Numbered list ({cmd:<ol>} — 1, 2, 3, ...).{p_end}
{p2col:{cmd:wditem} {it:text}}Adds one item. Accepts commas, "if", "in", etc.{p_end}
{p2col:{cmd:wdlistend}}Closes whichever list is currently open.{p_end}
{p2colreset}{...}

{phang2}
Example:

{hline}
{cmd}
    wputh2 Key findings (dashed)
    wdlist
        wditem Price is positively correlated with weight.
        wditem MPG declines as engine size grows.
        wditem Foreign cars are, on average, lighter.
    wdlistend

    wputh2 Sub-tasks (round bullets)
    wditemize
        wditem Load auto data.
        wditem Generate summary tables.
        wditem Export charts.
    wdlistend

    wputh3 Steps reproduced (numbered)
    wdenumerate
        wditem Load auto data with sysuse auto, clear.
        wditem Regress price on mpg and weight.
        wditem Plot residuals.
    wdlistend
{txt}{hline}


{marker installation}{...}
{title:Installation}

{pstd}
{bf:Adopath Setup:} Ensure the directory containing the {cmd:webdoc2} package
files is in your Stata adopath. {cmd:wdinit} uses {cmd:findfile} to locate
{cmd:header.html}, so the package directory must be on the path.


{marker troubleshooting}{...}
{title:Troubleshooting}

{phang}{bf:Tempfile Conflict Error}{p_end}
{pstd}
If {cmd:webdoc} fails to close a temp file, Stata reports:{break}
{it:file .../file.tmp already exists}

{pstd}
{bf:Solution:} Copy the full path from the error, run{break}
{cmd:rm "paste_path_here"}{break}
then re-run {cmd:webdoc2}.

{phang}{bf:wdinit: header.html not found}{p_end}
{pstd}
Verify the webdoc2 package directory is in {cmd:adopath}. To check:{break}
{cmd:adopath}{break}
Add the directory with {cmd:adopath + "your/path"} or in your {cmd:profile.do}.
To use a custom theme file instead: {cmd:wdinit myfile, replace headerfile("myheader.html")}.


{marker tips}{...}
{title:Tips & Tricks}

{pstd}
{bf:1. Use wdinit, not webdoc init.} {cmd:wdinit} loads Bootstrap 5 CSS, Bootstrap 5
JS (accordions + navbar), Google Fonts, and the back-to-top button in one step.

{pstd}
{bf:2. Custom themes.} Copy {cmd:header.html} from the package, edit the
{cmd::root} CSS variables (e.g. {cmd:--wd-primary}, {cmd:--wd-accent}),
and point {cmd:wdinit} at your copy:
{cmd:wdinit myfile, replace headerfile("my_theme.html")}

{pstd}
{bf:3. Bootstrap CDN themes.} To use a Bootstrap CDN Bootswatch theme instead
of {cmd:header.html}, use {cmd:webdoc init} directly with the {cmd:header2}
option — note this uses Bootstrap 3, which does NOT support the accordion or
navbar features of webdoc2.

{pstd}
{bf:4. Global ID counter.} {cmd:$tttt1} tracks accordion IDs. Do not overwrite
it or collapsible panels will break.

{pstd}
{bf:5. Anchor navigation.} Single-page reports just need {cmd:href(#slug)} —
no section wrapper {cmd:<div>} required. {cmd:wputh1}/{cmd:wputh2}/{cmd:wputh3}
auto-generate the {cmd:id} attribute from the heading text (lowercased,
non-alphanumerics → {cmd:-}). For multi-page reports, use {cmd:href(page.html)}.

{pstd}
{bf:6. Quoting.} All text commands ({cmd:wput}, {cmd:wdnavbar}, etc.) accept
free-form text with or without outer quotes.


{marker examples}{...}
{title:Examples}

{pstd}
{bf:Full working example — every output type}

{pstd}
Demonstrates: {cmd:wdinit}, navbar with dropdown (in-page links) and top-level
item (external link), in-page TOC, plain {cmd:wd}/{cmd:wdclose} logging,
collapsible code ({cmd:button}/{cmd:buttonclose}), collapsible graph
({cmd:graphbutton}/{cmd:graphbuttonclose}), bullet lists ({cmd:wdlist}),
embedded iframe ({cmd:wdiframe}), an inline image ({cmd:wdimg}), page width
control, and all heading/text helpers. Save as {hi:myreport.do} and run
{cmd:webdoc2 myreport.do, open}.

{hline}
{cmd}
    * ── 1. Initialize with Bootstrap 5 default theme ──────────────────────
    wdinit myreport, replace

    * ── 2. Navbar — place OUTSIDE any wd/button block ─────────────────────
    * In-page section links go in a dropdown; external links are top-level.
    wdnavbar My Stata Report
    wdnavdropdown Contents
        wdnavdropdownitem Home      , href(#home)
        wdnavdropdownitem Analysis  , href(#analysis)
        wdnavdropdownitem Help      , href(#help)
    wdnavdropdownclose
    wdnavitem Texas 2036 , href(http://www.texas2036.org)
    wdnavbarclose

    * ── HOME SECTION ───────────────────────────────────────────────────────
    * No wrapper <div> needed — wputh1 auto-generates id="home" from the title,
    * which matches href(#home) in the navbar dropdown above.
    wputh1 Home

    * In-page table of contents (JS fills this in automatically)
    wdtoc Report Contents

    wput Welcome to this report generated with webdoc2.
    wput Navigate using the navbar above or the table of contents.

    * ── ANALYSIS SECTION ───────────────────────────────────────────────────
    wputh1 Analysis

    * Output type 1: plain inline log (wd / wdclose)
    wputh2 Summary Statistics
    wd
    sysuse auto, clear
    summarize price mpg weight
    wdclose

    * Output type 2: collapsible code accordion (button / buttonclose)
    wputh2 Regression
    button
    regress price mpg weight
    buttonclose

    * Output type 3: collapsible graph accordion (graphbutton / graphbuttonclose)
    wputh2 Scatter Plot
    graphbutton
    scatter price mpg
    wgraph, width(600)
    graphbuttonclose

    * Output type 4: static image with caption
    wputh2 Logo
    wdimg logo.png, width(200) caption(Texas 2036 brand mark)

    * Output type 5: dashed bullet list of key findings
    wputh2 Key findings
    wdlist
        wditem Price is positively correlated with weight.
        wditem MPG declines as engine size grows.
        wditem Foreign cars are, on average, lighter.
    wdlistend

    * Output type 6: embedded interactive dashboard via iframe
    wputh2 Interactive dashboard
    wdiframe testsparkta.html, height(700px)

    * ── HELP SECTION ───────────────────────────────────────────────────────
    wputh1 Help
    wputh2 Initializing
    wput Use wdinit instead of webdoc init for automatic Bootstrap 5 setup.
    wput Custom theme: wdinit myfile [headerfile(mytheme.html)]
    wputh2 Navigation
    wput wdnavbar brand -- opens a responsive navbar
    wput wdnavitem label [href() active] -- adds one nav tab
    wput wdnavbarclose -- closes the navbar
    wputh2 Table of Contents
    wput wdtoc [title] [id() center indent() depth()] -- auto-populated TOC
    wputh2 Output types
    wput wd / wdclose -- plain inline stlog section
    wput button / buttonclose -- collapsible code accordion
    wput graphbutton / graphbuttonclose -- collapsible graph accordion
    wputh2 Media
    wput wdimg path [, width() alt() caption()] -- static image (optional caption)
    wput wdiframe src [, width() height() border] -- embed iframe / dashboard
    wputh2 Lists
    wput wdlist / wditemize / wdenumerate + wditem text + wdlistend
    wputh2 Text helpers
    wput wput text -- inserts a paragraph
    wput wputh1 / wputh2 / wputh3 text -- inserts a heading with auto-id

    webdoc close
{txt}{hline}

{pstd}
Open {hi:myreport.html} in a browser to see the result.
The accordion buttons collapse/expand, the navbar scrolls and collapses
on small screens, the TOC links jump to each section, and the
floating back-to-top button appears after scrolling down.


{marker author}{...}
{title:Author}

{pstd}
Eric A. Booth{break}
Texas 2036{break}
Email: {browse "mailto:eric.a.booth@gmail.com":eric.a.booth@gmail.com}{break}
GitHub: {browse "https://www.github.com/ericabooth":www.github.com/ericabooth}

{hline}
{pstd}
{it:Note: This package requires {bf:webdoc} by Ben Jann.}
