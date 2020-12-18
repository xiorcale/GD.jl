"""
Utility functions to work with BitArray and convert them from/to UInt8.
"""

using Base.Iterators: partition

"""
    biteye(size)

Return an identity matrix of dim (`size`, `size`).
"""
function biteye(size::Integer)::BitMatrix
    matrix = falses(size, size)
    map(i -> matrix[i,i] = 1, 1:size)
    return matrix
end


"""
    to_T(dtype, bitvec)

Convert `bitvec` into a representation of type `T`. Therefore, `length(bitvec)`
must be `<= 8 * sizeof(T)`.
"""
function to_T(dtype::Type{T}, bitvec::BitVector)::T where T <: Unsigned
    size = length(bitvec)
    sum = 0
    for (i, bit) in enumerate(bitvec)
        if bit == 1
            sum += 2 ^ (size - i)
        end
    end

    return sum |> dtype
end

"""
    tobytes(bitvec)

Pack `bitvec` into a compact array of byte. If `bitvec` is not divisible by 8,
the remaining bits will be "padded" into one byte.
"""
function tobytes(bitvec::BitVector)::Vector{UInt8}
    num_bytes = floor(length(bitvec) / 8) |> Int
    leftover = length(bitvec) % 8
    size = leftover > 0 ? num_bytes + 1 : num_bytes

    bytes = Vector{UInt8}(undef, size)
    i = 1
    @inbounds for i in 1:num_bytes
        bytes[i] = to_T(UInt8, bitvec[(i-1)*8+1:i*8])
    end

    if leftover > 0
        bytes[size] = to_T(UInt8, bitvec[(i-1)*8+1 : (i-1)*8+leftover])
    end

    return bytes
end


"""
    tobits(data::Vector{T})

Unpack an array into a bitarray, where each valze is padded on `8 * sizeof(T)`
bits.

/!/ Note that the MSB is in first position of the bitarray.
"""
function tobits(data::Vector{T}) where T <: Unsigned
    numbits = 8 * sizeof(T)
    bit_array = BitVector(undef, numbits * length(data))
    masks = [1 << i for i in numbits-1:-1:0]

    for (i, elem) in enumerate(data)
        start = (i - 1) * numbits
        @inbounds for (j, mask) in enumerate(masks)
            bit_array[start+j] = elem & mask > 0
        end
    end

    return bit_array
end




"""
    bits2uint([T<:Integer], bitarray)

Convert `bitarray` to an unsigned integer representation of type `T`.
"""
function bits2uint(T::Type{<:Unsigned}, bitarray::BitVector)
    size = length(bitarray)
    return mapreduce(+, 1:size) do i
        bitarray[i] ? 2 ^ (size-i) : 0
    end |> T
end
