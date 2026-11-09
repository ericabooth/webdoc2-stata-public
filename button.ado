*********! button

*cap program drop button
program define   button
version 14
syntax
* 1.1.6: one id per accordion (wdAcc1, wdAcc2, ...) instead of a repeated
* id="accordionExample"; the counter starts at 1 (the first id was "collapse").
if `"${tttt1}"' == "" global tttt1 1
local n = ${tttt1}
webdoc put <div class="mb-4"> <div class="accordion" id="wdAcc`n'"> <div class="accordion-item"> <h2 class="accordion-header"> <button class="accordion-button collapsed text-primary" type="button" data-bs-toggle="collapse" data-bs-target="#collapse`n'" aria-expanded="false" aria-controls="collapse`n'"> <small>Click to view code</small> </button></h2> <div id="collapse`n'" class="accordion-collapse collapse" data-bs-parent="#wdAcc`n'"><div class="accordion-body"> 
global tttt1 = `n' + 1
webdoc stlog
end
