#!/bin/bash

##### Beginning of file

set -ev

cat Project.toml || echo "Project.toml: No such file or directory"
cat Manifest.toml || echo "Manifest.toml: No such file or directory"

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

cat Project.toml
cat Manifest.toml

##### End of file
