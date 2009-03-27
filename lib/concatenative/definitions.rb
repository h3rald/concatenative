#!usr/bin/env ruby

:REP.define :I, :DUP
:SWONS.define :SWAP, :CONS
:POPD.define [:POP], :DIP
:DUPD.define [:DUP], :DIP
:SWAPD.define [:SWAP], :DIP
:SIP.define :DUPD, :SWAP, [:I], :DIP
:ROLLUP.define :SWAP, [:SWAP], :DIP
:ROLLDOWN.define [:SWAP], :DIP, :SWAP
:ROTATE.define :SWAP, [:SWAP], :DIP, :SWAP
