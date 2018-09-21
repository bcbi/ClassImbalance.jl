import Conda
import Pkg

Conda.add_channel("r")
Conda.add("r-base")

if Base.Sys.iswindows()
    separator = ";"
else
    separator = ":"
end
original_path = ENV["PATH"]
new_path = string(
    Conda.BINDIR,
    separator,
    original_path,
    )
ENV["PATH"] = new_path

ENV["R_HOME"] = "*"
Pkg.add("RCall")
Pkg.build("RCall")

import RCall
