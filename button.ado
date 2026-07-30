*********! button

*cap program drop button
program define   button
version 14
syntax
webdoc put <div class="mb-4"> <div class="accordion" id="accordionExample"> <div class="accordion-item"> <h2 class="accordion-header"> <button class="accordion-button collapsed text-primary" type="button" data-bs-toggle="collapse" data-bs-target="#collapse${tttt1}" aria-expanded="false" aria-controls="collapse${tttt1}"> <small>Click to view code</small> </button></h2> <div id="collapse${tttt1}" class="accordion-collapse collapse" data-bs-parent="#accordionExample"><div class="accordion-body"> 
global tttt1 = ${tttt1}+1
webdoc stlog
end
