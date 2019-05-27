# Mutation Testing

The [Vimes](https://github.com/MikeInnes/Vimes.jl) package provides functionality for mutation testing a Julia package.

Follow these instructions for running Vimes on ClassImbalance:

## Step 1
Delete your existing `.julia` directory:
```bash
rm -rf ~/.julia
```

## Step 2
Open a Julia REPL:
```bash
julia
```

## Step 3
Once in Julia, import Pkg:
```julia
import Pkg
```

## Step 4
Add the MikeInnes fork of CSTParser at the `location` branch:
```julia
Pkg.add(Pkg.PackageSpec(url="https://github.com/MikeInnes/CSTParser.jl", rev="location"))
```

## Step 5
Add Vimes:
```julia
Pkg.add(Pkg.PackageSpec(url="https://github.com/MikeInnes/Vimes.jl"))
```

## Step 6
Checkout ClassImbalance for development:
```julia
Pkg.develop("ClassImbalance")
```

## Step 7
Run the ClassImbalance test suite once. This allows us to install and build all of our test-only dependencies. It also lets us confirm that the test suite passes before we start running Vimes.
```julia
Pkg.test("ClassImbalance")
```

## Step 8
Exit Julia
```julia
exit()
```

## Step 9
`cd` to the ClassImbalance.jl repo:
```bash
cd ~/.julia/dev/ClassImbalance
```

## Step 10
Open a Julia REPL:
```bash
julia
```

## Step 11
Once in Julia, import Vimes:
```julia
import Vimes
```

## Step 12
Run Vimes:
```julia
Vimes.go(".")
```

## Step 13:
Exit Julia:
```julia
exit()
```

## Step 14:
`cd` into the `.vimes` folder:
```bash
cd .vimes
```

## Step 15:
List all of the files in the `.vimes` folder:
```bash
ls -la
```

## Step 16:
Take a look at the `.diff` files in the `.vimes`` folder, and write tests to cover each of the patches found by Vimes.

