using HTTP
using Serialization: serialize, deserialize

"""
    validate_remote!()

[API CLIENT] validates a file which comes from a remote location. To do so,
the list of unknown hashes contained in gdFile are requested at the endpoint
location (which should be a ReturnBases endpoint). Returns the number of
bases added to the database.
"""
function validate_remote!(s::Store, gdfile::GDFile, baseurl::String)::Int
    unknown_hashes = validate(s, gdfile)

    # record stats
    s.num_unknown_bases += length(unknown_hashes)

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
        update!(s, unknown_hashes, bases)
    end

    return length(unknown_hashes)
end


"""
    return_bases()

[API ENDPOINT] Returns the bases matching the hashes sent in the request.
"""
function return_bases(s::Store, req::HTTP.Request)
    # decode request body
    hashes = IOBuffer(req.body) |> deserialize
    
    # record stats -> since it is an endpoint, a lock is required in case
    # multiple call occurs concurrently.
    lock(s.num_requested_bases) do
        s.num_requested_bases += length(hashes)
    end
    
    # retreive the bases from the cache
    bases = get(s, hashes)

    # prepare response
    buffer = IOBuffer()
    serialize(buffer, bases)
    response = take!(buffer)
       
    return HTTP.Response(200, response)
end
