"""
    Store(database)
"""
struct Store
    compressor::Compressor
    database::Dict{Vector{UInt8}, Vector{UInt8}}
    num_unknown_bases::Int
    num_requested_bases::Int
end

"""
    update!(store::Store, hashes::Vector{Vector{UInt8}}, bases::Vector{Vector{UInt8}})

Update `store.database` by mapping `hashes` to `bases`.
"""
function update!(s::Store, hashes::Vector{Vector{UInt8}}, bases::Vector{Vector{UInt8}})
    for (h, b) ∈ zip(hashes, bases)
        s.database[h] = b
    end
end

"""
    compress!(store::Store, bytes::Vector{UInt8})

Store the `bytes` bases into `store` and return a compressed version of `bytes`.
"""
function compress!(s::Store, bytes::Vector{UInt8})::GDFile
    file, bases = compress(s.compressor, bytes)
    update!(s, file.hashes, bases)
    return file
end

"""
    extract(store::Store, file::GDFile)

Decompress `file` into its original representation.
"""
function extract(s::Store, gdfile::GDFile)::Vector{UInt8}
    bases = get(s, gdfile.hashes)
    return extract(s.compressor, bases, gdfile)
end

"""
    validate(store::Store, file::GDFile)

Check wether `file` can be extracted by `store` or not by returning the list of
unknown hashes used by `file`.
"""
function validate(s::Store, gdfile::GDFile)::Vector{Vector{UInt8}}
    return setdiff(gdfile.hashes, keys(s.database))
end

"""
    get(store, hashes)

return the values mapped to `hashes` in `store`.
"""
function get(s::Store, hashes::Vector{Vector{UInt8}})::Vector{Vector{UInt8}}
    return [s.database[hash] for hash in hashes]
end
