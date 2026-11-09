*! wdnavbar - Open a Bootstrap 5 navbar (use with wdnavitem / wdnavbarclose)
*! 2026-11-08 (webdoc2 1.1.4): BRANDhref replaces BrandHref, which Stata never
*!   matched to brandhref() on any version (r(198)); minimum abbreviation is
*!   brand, so it does not collide with bg().
*cap program drop wdnavbar
program define wdnavbar
version 14
syntax [anything(equalok everything)] [, Color(string) Bg(string) BRANDhref(string) Id(string)]
* 1.1.6: strip outer quotes (a quoted label kept them in the HTML)
local anything `anything'
if "`color'"     == "" local color     "navbar-dark"
if "`bg'"        == "" local bg        "bg-dark"
if "`brandhref'" == "" local brandhref "#"
if "`id'"        == "" local id        "mainNavbar"
webdoc put <nav class="navbar navbar-expand-lg `color' `bg' mb-4">
webdoc put <div class="container-fluid">
webdoc put <a class="navbar-brand" href="`brandhref'">`anything'</a>
webdoc put <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#`id'" aria-controls="`id'" aria-expanded="false" aria-label="Toggle navigation"><span class="navbar-toggler-icon"></span></button>
webdoc put <div class="collapse navbar-collapse" id="`id'"><ul class="navbar-nav me-auto mb-2 mb-lg-0">
end
