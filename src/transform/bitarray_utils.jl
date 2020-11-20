"""
Utility functions to work with BitArray and convert them from/to UInt8.
"""

using Base.Iterators: partition

"""
    biteye(size)

Return an identity matrix of size `size`.
"""
function biteye(size::Integer)::BitMatrix
    matrix = falses(size, size)
    map(i -> matrix[i,i] = 1, 1:size)
    return matrix
end

"""
    tobytes(bitarray)

Pack a bit array into a compact byte array. If the bitarray is not divisible by
8, the remaining bits will be padded into 1 byte.
"""
function tobytes(T::Type{<:Unsigned}, bitarray)
    [
        sum([2^(i - 1) for (i, b) in enumerate(byte) if b == 1]) |> T
        for byte in partition(bitarray, 8)
    ]
end

tobytes(bitarray) = tobytes(UInt8, bitarray)

"""
    tobits(data::Vector{UInt8}, [pad=8])

Unpack a byte array into an array of bitarray, where each byte is padded on 8 
bits by default.

/!/ Note that the LSB is in first position of the bitarray.
"""
function tobits(data::Vector{UInt8}; pad=8)
    reduce(vcat, @. digits(Bool, data, base=2, pad=pad) |> BitVector)
end
