"""
Utility functions to work with `BitArray` and convert them from/to `UInt8`.
"""

import Base.convert


"""
    convert(T, bitvec)

Convert `bitvec` into a represnetation of type `T`. Therefore, `length(bitvec)`
must be `<= 8 * sizeof(T)`.
"""
function convert(::Type{T}, bitvec::BitVector)::T where T <: Unsigned
    size = length(bitvec)
    sum = T(0)
    for (i, bit) in enumerate(bitvec)
        if bit == 1
            sum += 2 ^ (size - i)
        end
    end

    return sum
end


"""
    pack(bitvec)

Packs `bitvec` into a compact array of type `T`. If `bitvec` is not divisible 
by `8 * T`, the remaining bits will be zero-padded into the last element.
"""
function pack(::Type{T}, bitvec::BitVector)::Vector{T} where T <: Unsigned
    numbits = 8 * sizeof(T)
    num_bytes = floor(length(bitvec) / numbits) |> Int
    leftover = length(bitvec) % numbits
    size = leftover > 0 ? num_bytes + 1 : num_bytes

    data = Vector{T}(undef, size)
    @inbounds Threads.@threads for i in 1:num_bytes
        data[i] = convert(T, bitvec[(i-1)*numbits+1:i*numbits])
    end

    if leftover > 0
        curr = num_bytes + 1
        data[size] = convert(T, bitvec[(curr-1)*numbits+1 : (curr-1)*numbits+leftover])
    end

    return data
end


"""
    unpack(data)

Unpacks an array of unsigned values into a `BitVector`, where each value is 
padded on `8 * sizeof(T)` bits and concatenated together.

/!/ Note that the MSB is in first position of each concatenated block.
"""
function unpack(data::Vector{T})::BitVector where T <: Unsigned
    numbits = 8 * sizeof(T)
    bit_array = BitVector(undef, numbits * length(data))
    masks = [1 << i for i in numbits-1:-1:0]

    @inbounds for i in 1:length(data)
        start = (i - 1) * numbits
        @inbounds for (j, mask) in enumerate(masks)
            bit_array[start+j] = data[i] & mask > 0
        end
    end

    return bit_array
end
