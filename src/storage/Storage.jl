module Storage

# --------------------------------
# Include
# --------------------------------
include("chunkarray.jl")
include("gdfile.jl")
include("compressor.jl")
include("store.jl")
include("api.jl")

# --------------------------------
# Export
# --------------------------------
export
    # gdfile
    GDFile, patch, unpatch,

    # compressor
    Compressor, compress,

    # store
    Store, compress!, extract, get, update!, validate

end # module