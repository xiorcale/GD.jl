"""
    AbstractTransformer

Interface to implement for creating a new transformer.
"""
abstract type AbstractTransformer end

"""
    transform(transformer, data)

Apply the `transformer` transformation to `data` and return a split 
representation under the form (`basis`, `deviation`).
"""
function transform(
    ::AbstractTransformer,
    ::Vector{T}
)::Tuple{Vector{UInt8}, Vector{UInt8}} where T <: Unsigned 
    # Nothing - this is an interface to implement...
end

"""
    invtransform(transformer, basis, deviation)

Reverse the transformation applied by `transformer` and return the original
`data`.
"""
function invtransform(
    ::AbstractTransformer,
    ::Vector{UInt8},
    ::Vector{UInt8}
)::Vector{T} where T <: Unsigned
    # Nothing - this is an interface to implement...
end
