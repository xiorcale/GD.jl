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
    tobyte(bitvec)

Convert `bitvec` into ONE byte. Therfore, `length(bitvec)` must be `<= 8`.
"""
function tobyte(bitvec::BitVector)::UInt8
    size = length(bitvec)
    sum = 0
    for (i, bit) in enumerate(bitvec)
        if bit == 1
            sum += 2 ^ (size - i)
        end
    end

    return sum
end

"""
    tobytes(bitvec)

Pack `bitvec` into a compact array of byte. If `bitvec` is not divisible by 8,
the remaining bits will be "padded" into one byte.
"""
function tobytes(bitvec::BitVector)::Vector{UInt8}
    num_bytes = length(bitvec) / 8 |> Int
    leftover = length(bitvec) % 8
    size = leftover > 0 ? num_bytes + 1 : num_bytes

    bytes = Vector{UInt8}(undef, size)
    for i in 1:num_bytes
        bytes[i] = tobyte(bitvec[(i-1)*8+1:i*8])
    end

    if leftover > 0
        bytes[size] = tobyte[(i-1)*8+1 : (i-1)*8+leftover]
    end

    return bytes
end


"""
    tobits(data::Vector{UInt8}, [pad=8])

Unpack a byte array into an array of bitarray, where each byte is padded on 8 
bits by default.

/!/ Note that the MSB is in first position of the bitarray.
"""
function tobits(data::Vector{UInt8})
    bitArray = BitVector(undef, 8 * length(data))
    masks = [1 << i for i in 7:-1:0]

    for (i, byte) in enumerate(data)
        for (j, mask) in enumerate(masks)
            bitArray[(i-1)*8+j] = byte & mask > 0
        end
    end

    return bitArray
end
