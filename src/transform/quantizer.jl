using Base.Iterators: partition

"""
    Quantizer

Transformer which creates a basis and deviation pair as follow:

- basis: keeps only the `msbsize` MSB of each byte
- deviation: keeps the remaing `lsbsize` LSB of each byte
"""
struct Quantizer{T <: Unsigned} <: AbstractTransformer
    numbits::Int
    lsbsize::T
    msbsize::T
    bpad::UInt8
    dpad::UInt8
    chunksize::Int

    Quantizer{T}(chunksize, msbsize) where T <: Unsigned = begin
        numbits = 8 * sizeof(T)
        lsbsize = numbits - msbsize

        bsize = chunksize * msbsize
        dsize = chunksize * lsbsize

        bpad = ceil(bsize / numbits) * numbits - bsize |> UInt8
        dpad = ceil(dsize / numbits) * numbits - dsize |> UInt8

        return new(numbits, lsbsize, msbsize, bpad, dpad, chunksize)
    end
end


"""
    transform(quantizer, data)

Cuts each element from `data` into a basis containing the `quantizer.msbsize` MSB 
of the element, and a deviation containing the `quantizer.lsbsize` LSB of the
element.

Returns the concatenation of the MSB of the bytes as the `basis`, and the 
concatenation of the LSB of the bytes as the `deviation.`
"""
function transform(
    q::Quantizer{T},
    data::Vector{T}
)::Tuple{Vector{UInt8}, Vector{UInt8}} where T <: Unsigned
    # expand bytes into bitarray
    data_bits = unpack(data)
    basis_bits = BitVector(undef, q.chunksize * q.msbsize + q.bpad)
    dev_bits = BitVector(undef, q.chunksize * q.lsbsize + q.dpad)
    
    # iterate over data elements
    for i in 1:q.chunksize

        start = (i - 1) * q.numbits

        # extract msb
        @inbounds for j in 1:q.msbsize
            basis_bits[(i - 1) * q.msbsize + j] = data_bits[start + j]
        end

        # extract lsb
        @inbounds for j in 1:q.lsbsize
            dev_bits[(i - 1) * q.lsbsize + j] = data_bits[start + q.msbsize + j]
        end
    end

    # repack the bits arrays into compact bytes array. The remaining bits are
    # zero-padded into the last byte
    deviation = pack(UInt8, dev_bits)
    basis = pack(UInt8, basis_bits)

    return basis, deviation
end


"""
    invtransform(quantizer, basis, deviation)

Extracts each couple (MSB, LSB) from `basis` and `deviation` and rebuilds the 
original data by combining them.

Returns the original byte array which has been transformed by `transform()`.
"""
function invtransform(
    q::Quantizer{T},
    basis::Vector{UInt8},
    deviation::Vector{UInt8}
)::Vector{T} where T <: Unsigned
    # expand bytes into bitarray and remove the eventual padding
    basis_bits = unpack(basis)[1:end-q.bpad]
    deviation_bits = unpack(deviation)[1:end-q.dpad]

    # pre-allocate the array containing the rearranged bits
    data_bits = BitVector(undef, length(basis_bits) + length(deviation_bits))

    # glue LSB and MSB together
    stop = (length(data_bits) / q.numbits) |> Int
    for i in 1:stop
        
        start = (i - 1) * q.numbits
        @inbounds for j in 1:q.msbsize
            data_bits[start + j] = basis_bits[(i - 1) * q.msbsize + j]
        end

        @inbounds for j in 1:q.lsbsize
            data_bits[start + q.msbsize + j] = deviation_bits[(i - 1) * q.lsbsize + j]
        end
    end

    return pack(T, data_bits)
end
