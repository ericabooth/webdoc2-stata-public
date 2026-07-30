*! wdnavbarclose - Close a navbar opened with wdnavbar
*cap program drop wdnavbarclose
program define wdnavbarclose
version 14
syntax
webdoc put </ul></div></div></nav>
end
