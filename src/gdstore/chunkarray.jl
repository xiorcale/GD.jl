import Base: axes, firstindex, getindex, lastindex, length, setindex!, similar,
             size, xor


struct ChunkArray <: AbstractVector{UInt8}
    chunks::Array{UInt8, 2}
    chunksize::Integer
    padsize::Integer
    ChunkArray(chunks, chunksize, padsize) = new(chunks, chunksize, padsize)
    ChunkArray(data::Vector{UInt8}, chunksize::Int) = 
        initialize_chunkarray(data, chunksize)
end

"""
    initialize_chunkarray(data::Vector{UInt8}, chunksize::Int)

ChunkArray constructor which automatically pad `data` with 0x00 
according to `chunksize`, so that all the chunks have the same size.
"""
function initialize_chunkarray(data::Vector{UInt8}, chunksize::Integer)
    # pad with 0x00 if `data` is not a multiple of `chunksize`
    extrabytes = length(data) % chunksize
    padsize = extrabytes > 0 ? chunksize - extrabytes : 0
    padding = zeros(UInt8, padsize)

    paddata = vcat(data, padding)
    chunks = reshape(paddata, chunksize, :)
    return ChunkArray(chunks, chunksize, padsize)
end

firstindex(C::ChunkArray) = 1
lastindex(C::ChunkArray) = size(C)
getindex(C::ChunkArray, i::Integer) = C.chunks[:, i]
setindex!(C::ChunkArray, v, i::Integer) = C.chunks[:, i] = v

length(C::ChunkArray) = size(C)[1]
size(C::ChunkArray) = tuple(size(C.chunks)[2])


"""
    chunks2bytes(x::ChunkArray)::Vector{UInt8}

Convert an array `C` of chunks to its original 1D array of bytes representation,
without any padding.
"""
chunks2bytes(C::ChunkArray)::Vector{UInt8} = C.chunks[:][1:end-C.padsize]

"""
    xor(x::Vector{UInt8}, y::Vector{UInt8}

Perform a chunk-wise xor
"""
function xor(x::Vector{UInt8}, y::Vector{UInt8})
    @assert size(x) == size(y)
    return x != y
end