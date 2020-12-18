import Base: axes, firstindex, getindex, lastindex, length, setindex!, similar,
             size


struct ChunkArray{T <: Unsigned} <: AbstractVector{T}
    chunks::Array{T, 2}
    chunksize::Integer
    padsize::Integer

    ChunkArray{T}(data::Vector{T}, chunksize::Int) where T <: Unsigned = begin
        # pad with 0x00 if `data` is not a multiple of `chunksize`
        extrabytes = length(data) % chunksize
        padsize = extrabytes > 0 ? chunksize - extrabytes : 0
        padding = zeros(T, padsize)

        paddata = vcat(data, padding)
        chunks = reshape(paddata, chunksize, :)
        return new(chunks, chunksize, padsize)
    end
end

firstindex(C::ChunkArray) = 1
lastindex(C::ChunkArray) = size(C)
getindex(C::ChunkArray, i::Integer) = C.chunks[:, i]
setindex!(C::ChunkArray, v, i::Integer) = C.chunks[:, i] = v

length(C::ChunkArray) = size(C)[1]
size(C::ChunkArray) = tuple(size(C.chunks)[2])
