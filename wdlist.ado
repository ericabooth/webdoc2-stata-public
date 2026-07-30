*! wdlist - Open a simple dashed-bullet list (LaTeX-style "—" markers).
*!          Pair with wditem (items) and wdlistend (close).
*!          For round bullets see wditemize; for numbers see wdenumerate.
*cap program drop wdlist
program define wdlist
version 14
syntax
global wdlist_tag "ul"
webdoc put <ul class="wd-list-dashed">
end
