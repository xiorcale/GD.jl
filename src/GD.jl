module GD

# "private" includes
include("chunkarray.jl")


# submodule
include("transform/Transform.jl")
using .Transform


# module

include("compressor.jl")
include("store.jl")

export Compressor, load, dump, compress, compress!, extract, validate, get, GDFile, Store

end # module
