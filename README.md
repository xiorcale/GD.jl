# GD.jl

`GD.jl` is an in-memory [Generalized Deduplication (GD)][1] data store which can be
used for compressing the network traffic of a distributed infrastructure. The
design of the library tries to follow these guidelines:

- **Configurable**: GD configuration can vary a lot depending on the data we are
  compressing. Adjusting the chunk size, the fingerprint, or picking a suitable
  transformation is the responsibility of the user, as the store does not assume
  these values.
- **Extensible**: The platform has been built with research in mind and writing
  custom compression transformations do not depend on the rest of the library.
  Thus, implementing experimental transformations is easy to do. In the same way,
  an extension of the library implements the inter-store communication which
  exposes a micro HTTP API. This part can be ditched, extended, or rewritten
  completely with another communication protocol without impacting the rest of
  the architecture.
- **Generic**: `GD.jl` is composed of multiple blocks mainly working at an
  abstract level. Thus, the store exposes the necessary primitives required to use
  it, while staying “transformation-agnostic”.
  

## Getting started

Setting up a local store can be done in three simple steps:

```julia
using GD: Storage, Transform
using SHA: sha1


# 1. Pick a transformation to compress data.
msbsize = 0x06
chunksize = 256
transformer = Transform.Quantizer{UInt8}(chunksize, msbsize)

# 2. Configure the compressor.
fingerprint = sha1
compressor = Storage.Compressor(chunksize, transformer, fingerprint)

# 3. Instanciate the in-memory data store.
database = Dict()
store = Storage.Store(compressor, database)
```

Once the setup in place, using the API to compress and extract data is pretty
straightforward:

```julia
# fake data
data = rand(UInt8, 1000)

# Compress data.
gdfile = Storage.compress!(store, data)

# Check file validity.
@assert Storage.validate(store, gdfile) == UInt8[]

# Extract gdfile.
@assert Storage.extract(store, gdfile) == data
```

There is no need to check the file validity as long as only one local store is
used. However, this function is coming handy when decompressing `GDFile` coming
from a remote location, as the local store may lack certain bases required for
the decompression.


## Working with distributed stores for network compression

`GD.jl` provides a tiny HTTP API which can be setup for inter-store communication.
This extension is experimental, very basic and certainly not targeting high-performance
communication. Use at your own risk.

> Okay, okay, give me the goods now!

```julia
host = "127.0.0.1"
port = "9090"
@async Storage.setup_api_endpoint(store, host, port)
```

Where `http://host:port` is the baseurl used to contact the store endpoint.

Decompressing a file coming from a remote location is then a two-step process:

```julia
# 1. Validate the `GDFile` coming from a remote location and requesting the
#    missing bases for our local store. 
Storage.validate_remote!(store, data, "http://127.0.0.1:9090")

# 2. Extract as usual now that our file is valid.
data = Storage.extract(store, data)
```

:warning: This functionality has a serious limitation: validating a `GDFile`
by requesting bases from a store which do not possess them will generate an
unhandled error.


## Architecture

Internally, the store is composed of five modules working together:

1. **Compressor**: Holds the configuration of the transformation and pretty much
   any other variables configured by the user related to the compression process.
   This module is stateless and can (de)compress without being tied to a specific
   transformer.
2. **Database**: Key-value data store (really nothing more than a simple `Dict`)
   holding the couples `(hash, deviation)`.
3. **GDFile**: Data structure used by the compressed data.
4. **Transform**: Abstraction of the transformer. This module defines the
   interface to implement for the creation of a new transformer.
5. **Store**: Acts as an orchestrator that glues the other components together and exposes an easy-to-use API for the user.


## Available Transform

The following transformations are available for now:

- **GD Quantization**: Lossless quantization which store the quantization error
  in the deviation.


## References

Generalized deduplication literature:

- [Generalized Deduplication: Lossless Compression for Large Amounts of Small IoT Data](https://pure.au.dk/portal/files/149814536/EW2019_accepted.pdf)
- [Lossless Compression of Time Series Data with Generalized Deduplication](https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=9013957)
- [A Randomly Accessible Lossless Compression Scheme for Time-Series Data](https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=9155450)
- [Hermes: Enabling Energy-efficient IoT Networks with Generalized Deduplication](https://arxiv.org/pdf/2005.11158.pdf)

[1]: https://pure.au.dk/portal/files/149814536/EW2019_accepted.pdf
