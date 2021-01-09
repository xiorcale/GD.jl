module Transform


# --------------------------------
# Include
# --------------------------------
include("binary_utils.jl")
include("abstract_transformer.jl")
include("quantizer.jl")


# --------------------------------
# Export
# --------------------------------
export 
    # interface
    AbstractTransformer, transform, invtransform,

    # transformer implementations
    Quantizer


end # module
