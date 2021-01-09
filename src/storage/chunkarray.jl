import Base: eltype, firstindex, getindex, lastindex, length, setindex!, 
    similar, size


"""
    ChunkArray

Implementation of `AbstractVector` which iterate over data chunks. The last
chunk is zero-padded if the size of `data` is not a multiple of `chunksize`.
"""
struct ChunkArray{T <: Unsigned} <: AbstractVector{T}
    chunks::Array{T, 2}
    chunksize::Integer
    padsize::Integer

    ChunkArray{T}(data::Vector{T}, chunksize::Int) where T <: Unsigned = begin
        # zero-padding if `data` is not a multiple of `chunksize`
        extrabytes = length(data) % chunksize
        padsize = extrabytes > 0 ? chunksize - extrabytes : 0
        padding = zeros(T, padsize)

        chunks = vcat(data, padding)
        chunks = reshape(chunks, chunksize, :)
        return new(chunks, chunksize, padsize)
    end
end

eltype(::ChunkArray{T}) where T <: Unsigned =  Vector{T}
firstindex(::ChunkArray) = 1
lastindex(C::ChunkArray) = size(C)[1]
getindex(C::ChunkArray, i::Integer) = C.chunks[:, i]
setindex!(C::ChunkArray, v, i::Integer) = C.chunks[:, i] = v
length(C::ChunkArray) = size(C)[1]
similar(C::ChunkArray{T}) where T <: Unsigned = ChunkArray{T}(Vector{T}(undef, length(C.chunks[:])), C.chunksize)
similar(C::ChunkArray{T}, ::Type{T}, dims::Dims) where T <: Unsigned = ChunkArray{T}(Vector{T}(undef, C.chunksize * dims[1]), C.chunksize)
size(C::ChunkArray) = tuple(size(C.chunks)[2])
