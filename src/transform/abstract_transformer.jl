"""
    AbstractTransformer

Interface for creating a transformer.
"""
abstract type AbstractTransformer end

"""
    transform(transformer, data)

Apply the `transformer` transformation to `data` and return a split 
representation under the form (`basis`, `deviation`).
"""
function transform(transformer::AbstractTransformer, data::Vector{T}) where T <: Unsigned 
    transform(transformer, data)
end

"""
    invtransform(transformer, basis, deviation)

Reverse the transformation applied by `transformer` and return the original
`data`.
"""
function invtransform(transformer::AbstractTransformer, basis::Vector{UInt8}, deviation::Vector{UInt8})
    invtransform(transformer, basis, deviation)
end
