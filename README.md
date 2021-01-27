# GD.jl

`GD.jl` is an in-memory Generalized Deduplication (GD) [1] data store which can be
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

- [\[1\] Generalized Deduplication: Lossless Compression for Large Amounts of Small IoT Data](https://pure.au.dk/portal/files/149814536/EW2019_accepted.pdf)
