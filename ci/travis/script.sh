#!/bin/bash

##### Beginning of file

set -ev

# TODO: Remove the following line after we add the Project.toml file
julia --check-bounds=yes --color=yes -e 'import Pkg; Pkg.clone(pwd());'

julia --check-bounds=yes --color=yes -e '
    import Pkg;
    Pkg.build("ClassImbalance");
    '

julia --check-bounds=yes --color=yes -e '
    import ClassImbalance;
    '

julia --check-bounds=yes --color=yes -e '
    import Pkg;
    Pkg.test("ClassImbalance"; coverage=true);
    '

julia --check-bounds=yes --color=yes -e '
    import Pkg;
    try Pkg.add("Coverage") catch end;
    '

julia --check-bounds=yes --color=yes -e '
    import Coverage;
    import ClassImbalance;
    cd(normpath(joinpath(pathof(ClassImbalance), "..", "..")));
    Coverage.Codecov.submit(Coverage.Codecov.process_folder());
    '

##### End of file
