using ..Transform: AbstractTransformer, transform, invtransform


"""
    Compressor(chunksize, transformer, fingerprint)

Compresses/Extracts data according to the loaded configuration. A `Compressor` 
is stateless. It is focused on data compression/extraction but does not store 
any value for deduplication.

fingerprint is a hashing function with the following signature:
    
    `fingerprint(data::Vector{Vector{UInt8}})::Vector{Vector{UInt8}}`
"""
mutable struct Compressor
    chunksize::Int
    transformer::AbstractTransformer
    fingerprint::Function
end


"""
    hashes(compressor, data)

Hashes each element in `data` with the `compressor.fingerprint` and return an
array of hashes.
"""
function hashes(c::Compressor, data::Vector{Vector{UInt8}})::Vector{Vector{UInt8}}
    return c.fingerprint.(data)
end


"""
    compress(compressor, data)

Returns a compressed version of `data`, as well as the bases which need to be
used by `compressor` for reconstructing `data`. 
"""
function compress(
    c::Compressor,
    data::Vector{T}
)::Tuple{GDFile, Vector{Vector{UInt8}}} where T <: Unsigned
    chunkarray = ChunkArray{T}(data, c.chunksize)
    bases = Vector{Vector{UInt8}}(undef, length(chunkarray))
    deviations = Vector{Vector{UInt8}}(undef, length(chunkarray))
    
    @inbounds for (i, chunk) ∈ enumerate(chunkarray)
        bases[i], deviations[i] = transform(c.transformer, chunk)
    end

    return GDFile(hashes(c, bases), deviations, chunkarray.padsize), bases
end


"""
    extract(compressor, gdfile, bases)

Decompresses `gdfile` into its original representation.
"""
function extract(c::Compressor, gdfile::GDFile, bases::Vector{Vector{UInt8}})
    data = reduce(
        vcat,
        [
            invtransform(c.transformer, b, d)
            for (b, d) in zip(bases, gdfile.deviations)
        ],
    )
    return data[1:end-gdfile.padsize]
end
