*! wdinit - webdoc init with Bootstrap 5 header injection
*!          Default: finds header.html in adopath / working directory.
*!          Custom:  wdinit myfile, replace headerfile("mytheme.html")
*cap program drop wdinit
program define wdinit
version 14
* HEADERFile, not HeaderFile: syntax option capitals must be an initial
* substring, and the malformed form made a typed headerfile() fall through
* to the * catch-all silently -- the option never worked as documented.
syntax [anything(id="document name")] [, HEADERFile(string) *]

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

* -webdoc do- prepends its own optionless `webdoc init "<dofile basename>"'
* when the do-file has no literal -webdoc init- line: wdinit is invisible to
* webdoc's textual scan for init commands. That injected init creates a stray
* <basename>.html, and on the next -webdoc do- pass over the same directory
* it fails with r(602) "file already exists" before wdinit ever executes, so
* no option passed to wdinit can prevent it. When taking over from that stray
* document, close its file handle and remove the file so reruns start clean.
* Only the exact auto-init file is removed, and only while still empty.
if `"${WebDoc_dofile}"' != "" & `"${WebDoc_docname}"' != "" {
    mata: st_local("straydoc", pathrmsuffix(st_global("WebDoc_dofile")) + ".html")
    mata: st_local("wdtarget", pathisabs(st_local("htmlfn")) ? st_local("htmlfn") : pathjoin(pwd(), st_local("htmlfn")))
    if `"${WebDoc_docname}"' == `"`straydoc'"' {
        if `"`wdtarget'"' == `"`straydoc'"' {
            * Same name for document and do-file: the stray IS the target, so
            * it cannot be removed here. The rerun still breaks unless webdoc
            * do itself gets the replace option; warn instead of failing later.
            di as txt "note: wdinit document name matches the do-file name;" ///
                " rerunning -webdoc do- in this directory will fail with" ///
                " r(602) unless replace is passed to -webdoc do- itself."
        }
        else {
            capture mata: webdoc_closeout_fh(${WebDoc_docname_FH})
            capture quietly checksum `"`straydoc'"'
            if _rc == 0 & r(filelen) == 0 {
                capture erase `"`straydoc'"'
            }
        }
    }
}

* Call webdoc init, injecting the header file into <head> via include()
* All other options (replace, logall, grdir, etc.) pass through via `options'
webdoc init `"`anything'"', `macval(options)' header2(include(`"`hpath'"'))
end
