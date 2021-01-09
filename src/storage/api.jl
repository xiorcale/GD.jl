using HTTP
using Serialization: serialize, deserialize


"""
    validate_remote!(store, gdfile, baseurl)

[API CLIENT] Validates a file which comes from a remote location. To do so,
the list of unknown hashes contained in gdfile are requested at the endpoint
location (which should be a `return_bases` endpoint). Returns the number of
bases added to the database.
"""
function validate_remote!(store::Store, gdfile::GDFile, baseurl::String)::Int
    unknown_hashes = validate(store, gdfile)

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
        bases = IOBuffer(response.body) |> deserialize
        update!(store, unknown_hashes, bases)
    end

    return length(unknown_hashes)
end


"""
    return_bases(store, request)

[API ENDPOINT] Returns the bases matching the hashes sent in the request.
"""
function return_bases(store::Store, request::HTTP.Request)
    # decode request body
    hashes = IOBuffer(request.body) |> deserialize
    
    # record stats -> since it is an endpoint, a lock is required in case
    # multiple call occurs concurrently.
    lock(store.l) do
        store.num_requested_bases += length(hashes)
    end
    
    # retreive the bases from the cache
    bases = get(store, hashes)

    # prepare response
    buffer = IOBuffer()
    serialize(buffer, bases)
    response = take!(buffer)
       
    return HTTP.Response(200, response)
end
