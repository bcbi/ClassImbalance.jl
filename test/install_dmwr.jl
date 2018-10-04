import RCall

try
    RCall.R"""
        dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)
        .libPaths(Sys.getenv("R_LIBS_USER"))
        if ( !require("DMwR") ) {
            install.packages(
                "DMwR",
                lib = Sys.getenv("R_LIBS_USER"),
                repos = "http://cran.r-project.org/",
                type="binary",
                )
        }
    """
catch e
    @warn(string("ignoring error: "), e)
    RCall.R"""
        dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)
        .libPaths(Sys.getenv("R_LIBS_USER"))
        if ( !require("DMwR") ) {
            install.packages(
                "DMwR",
                lib = Sys.getenv("R_LIBS_USER"),
                repos = "http://cran.r-project.org/",
                type="source",
                )
        }
    """
end

result_rcall_library_DMwR = RCall.R"""
    library("DMwR")
"""

@info(
    string("Result of calling library(\"DMwR\"): "),
    result_rcall_library_DMwR,
    )
