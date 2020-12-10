module Gdstore

include("chunkarray.jl")
include("../transform/abstract_transformer.jl")

include("compressor.jl")
export Compressor, GDFile, compress, extract

include("store.jl")
export Store, compress!, extract, get, update!, validate

include("api.jl")
export validate_remote!, return_bases

end # module