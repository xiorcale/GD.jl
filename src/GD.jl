module GD

# "private" includes
include("chunkarray.jl")

# submodule
include("transform/Transform.jl")
using .Transform

# module
include("compressor.jl")
export Compressor, GDFile, compress, extract

include("store.jl")
export Store, compress!, extract, get, update!, validate


end # module