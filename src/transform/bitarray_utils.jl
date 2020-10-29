"""
    eye(size)

Return an identity matrix of size `size`.
"""
function eye(size::Integer)::BitMatrix
    matrix = falses(size, size)
    map(i -> matrix[i,i] = 1, 1:size)
    return matrix
end

"""
    bits2uint([T<:Integer], bitarray)

Convert `bitarray` to an unsigned integer representation of type `T` (default
`UInt8`).
"""
function bits2uint end

function bits2uint(T::Type{<:Unsigned}, bitarray::BitVector)
    size = length(bitarray)
    return mapreduce(+, 1:size) do i
        bitarray[i] ? 2 ^ (size-i) : 0
    end |> T
end

function bits2uint(T::Type{<:Unsigned}, bitarray::String)
    size = length(bitarray)
    return mapreduce(+, 1:size) do i
        bitarray[i] == '1' ? 2 ^ (size-i) : 0
    end |> T
end

bits2uint(bitvector::BitVector) = bits2uint(UInt8, bitvector)
bits2uint(bitstr::String) = bits2uint(UInt8, bitstr)

"""
    uint2bits(uint::Unsigned, [pad::Integer])

Convert `uint` to a bitvector representation with an optional padding (default
`sizeof(typeof(uint))`)
"""
function uint2bits(uint::Unsigned, pad::Integer)
    reduce(vcat, digits(Bool, uint, base=2, pad=pad)) |> BitVector
end

uint2bits(uint::Unsigned) = uint2bits(uint, sizeof(typeof(uint)) * 8)
