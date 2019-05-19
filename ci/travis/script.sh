#!/bin/bash

##### Beginning of file

set -ev

export COMPILED_MODULES=$COMP_MODS
echo "COMPILED_MODULES=$COMPILED_MODULES"

export JULIA_FLAGS="--check-bounds=yes --code-coverage=all --color=yes --compiled-modules=$COMPILED_MODULES --inline=no"
echo "JULIA_FLAGS=$JULIA_FLAGS"

export JULIA_PROJECT=@.

cat Project.toml
cat Manifest.toml

julia $JULIA_FLAGS -e '
    import Pkg;
    Pkg.build("ClassImbalance");
    '

julia $JULIA_FLAGS -e '
    import ClassImbalance;
    '

julia $JULIA_FLAGS -e '
    import Pkg;
    Pkg.test("ClassImbalance"; coverage=true);
    '

julia $JULIA_FLAGS -e '
    import Pkg;
    try Pkg.add("Coverage") catch end;
    '

julia $JULIA_FLAGS -e '
    import Coverage;
    import ClassImbalance;
    cd(normpath(joinpath(pathof(ClassImbalance), "..", "..")));
    Coverage.Codecov.submit(Coverage.Codecov.process_folder());
    '

cat Project.toml
cat Manifest.toml

##### End of file
