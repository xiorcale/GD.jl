"""
    Compressor(chunksize, transformer, fingerprint)

Compress/Extract data according to the loaded configuration. A `Compressor` is
stateless. It is focused on data compression/extraction but does not store any
value for deduplication.
"""
mutable struct Compressor
    chunksize::Int
    transformer::AbstractTransformer
    fingerprint::Function
end


"""
    hash(compressor::Compressor, data::Vector{Vector{UInt8}})

Hash each element in `data` with the `compressor.fingerprint` and return an
array of hashes.
"""
function hash(c::Compressor, data::Vector{Vector{UInt8}})::Vector{Vector{UInt8}}
    return c.fingerprint.(data)
end

"""
    compress(compressor::Compressor, data::Vector{T})

Return a compressed version of `data`, as well as the bases which need to be
sotred by `compressor` for reconstructing `data`. 
"""
function compress(c::Compressor, data::Vector{T}) where T <: Unsigned
    chunkarray = ChunkArray{T}(data, c.chunksize)
    bases = similar(chunkarray, Vector{UInt8})
    deviations = similar(chunkarray, Vector{UInt8})
    
    @inbounds for (i, chunk) ∈ enumerate(chunkarray)
        bases[i], deviations[i] = transform(c.transformer, chunk)
    end

    return GDFile(hash(c, bases), deviations, chunkarray.padsize), bases
end

"""
    extract(compressor::Compressor, bases::Vector{UInt8}, gdfile::GDFile)

Decompress `gdfile` into its original representation.
"""
function extract(c::Compressor, bases::Vector{Vector{UInt8}}, gdfile::GDFile)
    data = reduce(
        vcat,
        [
            invtransform(c.transformer, b, d)
            for (b, d) in zip(bases, gdfile.deviations)
        ],
    )
    return data[1:end-gdfile.padsize]
end