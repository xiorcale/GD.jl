module Transform

include("bitarray_utils.jl")
include("abstracttransformer.jl")
include("quantizer.jl")

export AbstractTransformer, Quantizer, transform, invtransform

end # module
