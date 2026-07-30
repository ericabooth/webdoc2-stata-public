*! wditemize - Open a round-bullet list (default browser <ul> markers).
*!             Pair with wditem (items) and wdlistend (close).
*!             For dashed markers see wdlist; for numbers see wdenumerate.
*cap program drop wditemize
program define wditemize
version 14
syntax
global wdlist_tag "ul"
webdoc put <ul>
end
