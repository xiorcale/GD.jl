module GD

include("transform/Transform.jl")
using .Transform

include("storage/chunkarray.jl")
export ChunkArray

include("storage/gdfile.jl")
export GDFile, patch, unpatch

include("storage/compressor.jl")
export Compressor, compress, extract

include("storage/store.jl")
export Store, compress!, extract, get, update!, validate

include("storage/api.jl")
export validate_remote!, return_bases

end # module
