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
function transform(transformer::AbstractTransformer, data::Vector{UInt8}) end

"""
    invtransform(transformer, basis, deviation)

Reverse the transformation apply by `transformer` and return the original `data`.
"""
function invtransform(transformer::AbstractTransformer, basis::Vector{UInt8}, deviation::Vector{UInt8}) end


