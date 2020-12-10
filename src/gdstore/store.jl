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
function update!(store::Store, hashes::Vector{Vector{UInt8}}, bases::Vector{Vector{UInt8}})
    for (h, b) ∈ zip(hashes, bases)
        store.database[h] = b
    end
end

"""
    compress!(store::Store, bytes::Vector{UInt8})

Store the `bytes` bases into `store` and return a compressed version of `bytes`.
"""
function compress!(store::Store, bytes::Vector{UInt8})::GDFile
    file, bases = compress(store.compressor, bytes)
    update!(store, file.hashes, bases)
    return file
end

"""
    extract(store::Store, file::GDFile)

Decompress `file` into its original representation.
"""
function extract(store::Store, file::GDFile)::Vector{UInt8}
    bases = get(store, file.hashes)
    return extract(store.compressor, bases, file)
end

"""
    validate(store::Store, file::GDFile)

Check wether `file` can be extracted by `store` or not by returning the list of
unknown hashes used by `file`.
"""
function validate(store::Store, file::GDFile)::Vector{Vector{UInt8}}
    return setdiff(file.hashes, keys(store.database))
end

"""
    get(store, hashes)

return the values mapped to `hashes` in `store`.
"""
function get(store::Store, hashes::Vector{Vector{UInt8}})::Vector{Vector{UInt8}}
    return [store.database[hash] for hash in hashes]
end
