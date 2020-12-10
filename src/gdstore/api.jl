using HTTP
using Serialization: serialize, deserialize

"""
    validate_remote!()

validates a file which comes from a remote location. To do so,
the list of unknown hashes contained in gdFile are requested at the endpoint
location (which should be a ReturnBases endpoint). Returns the number of
bases added to the database.
"""
function validate_remote!(store::Store, gd_file::GDFile, baseurl::String)::Int
    unknown_hashes = validate(store, gd_file)

    # record stats
    store.num_unknown_bases += length(unknown_hashes)

    # request the missing bases if needed
    if length(unknown_hashes) > 0
        # prepare the request
        endpoint = baseurl * "/bases"
        buffer = IOBuffer()
        serialize(buffer, unknown_hashes)
        body = take!(buffer)

        # decode the response and update the store
        response = HTTP.request("GET", endpoint, [], body)
        bases = IOBuffer(response) |> deserialize
        update!(store, unknown_hashes, bases)
    end

    return length(unknown_hashes)
end


"""
    return_bases()

Returns the bases matching the hashes sent in the request.
"""
function return_bases(store::Store, req::HTTP.Request)
    # decode request body
    hashes = IOBuffer(req.body) |> deserialize
    
    # record stats
    store.num_requested_bases += length(hashes)
    
    # retreive the bases from the cache
    bases = get(store, hashes)

    # prepare response
    buffer = IOBuffer()
    serialize(buffer, bases)
    response = take!(buffer)
       
    return HTTP.Response(200, response)
end
