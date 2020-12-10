module Transform

include("bitarray_utils.jl")

include("abstract_transformer.jl")
export AbstractTransformer, transform, invtransform

include("hamming.jl")
export Hamming

include("quantizer.jl")
export Quantizer

end # module
