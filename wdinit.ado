*! wdinit - webdoc init with Bootstrap 5 header injection
*!          Default: finds header.html in adopath / working directory.
*!          Custom:  wdinit myfile, replace headerfile("mytheme.html")
*cap program drop wdinit
program define wdinit
version 14
syntax [anything(id="document name")] [, HeaderFile(string) *]

* Determine which header file to inject
if `"`headerfile'"' == "" {
    * Default: locate header.html in adopath / working directory
    cap findfile "header.html"
    if _rc != 0 {
        di as err "wdinit: header.html not found in adopath or working directory."
        di as err "       Ensure the webdoc2 package directory is in your adopath,"
        di as err "       or specify a custom file with the headerfile() option."
        exit 601
    }
    local hpath `"`r(fn)'"'
}
else {
    * User-specified header file
    cap findfile `"`headerfile'"'
    if _rc != 0 {
        di as err `"wdinit: header file not found: `headerfile'"'
        exit 601
    }
    local hpath `"`r(fn)'"'
}

* Compute and expose the absolute HTML path for webdoc2findreplace.
* webdoc init appends .html if not already present; we mirror that logic.
local htmlfn `anything'
if lower(substr(`"`htmlfn'"',-5,.)) != ".html" {
    local htmlfn `"`htmlfn'.html"'
}
* Prepend CWD if the path is relative (no leading / or \)
if strpos(`"`htmlfn'"', "/") == 0 & strpos(`"`htmlfn'"', "\") == 0 {
    global webdoc2htmlpath `"`c(pwd)'/`htmlfn'"'
}
else {
    global webdoc2htmlpath `"`htmlfn'"'
}

* Call webdoc init, injecting the header file into <head> via include()
* All other options (replace, logall, grdir, etc.) pass through via `options'
webdoc init `"`anything'"', `macval(options)' header2(include(`"`hpath'"'))
end
