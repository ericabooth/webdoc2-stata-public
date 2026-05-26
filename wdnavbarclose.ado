*! wdnavbarclose - Close a navbar opened with wdnavbar
*cap program drop wdnavbarclose
program define wdnavbarclose
syntax
webdoc put </ul></div></div></nav>
end
