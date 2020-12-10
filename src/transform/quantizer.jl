using Base.Iterators: partition

"""
    Quantizer

Transformer which create a basis and deviation pair as follow:

- basis: keep only the `msbsize` MSB of each byte
- deviation: keep the remaing `lsbsize` LSB of each byte
"""
struct Quantizer <: AbstractTransformer
    lsbsize::UInt8
    msbsize::UInt8
    bpad::UInt8
    dpad::UInt8
    chhunksize::Int

    Quantizer(chunksize, msbsize) = begin
        lsbsize = 0x08 - msbsize

        bsize = chunksize * msbsize
        dsize = chunksize * lsbsize

        bpad = ceil(bsize / 8) * 8 - bsize |> UInt8
        dpad = ceil(dsize / 8) * 8 - dsize |> UInt8

        return new(lsbsize, msbsize, bpad, dpad, chunksize)
    end
end


"""
    transform(quantizer::Quantizer, data::Vector{UInt8})

Cut each byte into a basis containing the `quantizer.msbsize` MSB of the byte,
and a deviation containing the `quantizer.lsbsize` LSB of the byte.

Return the concatenation of the MSB of the bytes as the `basis`, and the 
concatenation of the LSB of the bytes as the `deviation.`
"""
function transform(q::Quantizer, data::Vector{UInt8})
    # expand bytes into bitarray
    data_bits = tobits(data)
    basis_bits = BitVector(undef, q.chhunksize * q.msbsize + q.bpad)
    dev_bits = BitVector(undef, q.chhunksize * q.lsbsize + q.dpad)
    
    # iterate over bytes
    for i in 1:q.chhunksize

        # extract msb
        for j in 1:q.msbsize
            basis_bits[(i - 1) * q.msbsize + j] = data_bits[(i - 1) * 8 + j]
        end

        # extract lsb
        for j in 1:q.lsbsize
            dev_bits[(i - 1) * q.lsbsize + j] = data_bits[(i - 1) * 8 + q.msbsize + j]
        end
    end

    # repack the bits arrays into compact bytes array. The remaining bits are
    # padded into the last byte
    deviation = tobytes(dev_bits)
    basis = tobytes(basis_bits)

    return basis, deviation
end

"""
    invtransform(quantizer, basis, deviation)

Extract each couple (MSB, LSB) from `basis` and `deviation` and 
rebuild the original data by combining them.

return the original byte array which has been transform by `transform()`.
"""
function invtransform(q::Quantizer, basis::Vector{UInt8}, deviation::Vector{UInt8})
    # expand bytes into bitarray
    basis_bits = tobits(basis)[1:end-q.bpad]
    deviation_bits = tobits(deviation)[1:end-q.dpad]

    data_bits = BitVector(undef, length(basis_bits) + length(deviation_bits))

    # glue LSB and MSB together
    stop = (length(data_bits) / 8) |> Int
    for i in 1:stop
        
        for j in 1:q.msbsize
            data_bits[(i - 1) * 8 + j] = basis_bits[(i - 1) * q.msbsize + j]
        end

        for j in 1:q.lsbsize
            data_bits[(i - 1) * 8 + q.msbsize + j] = deviation_bits[(i - 1) * q.lsbsize + j]
        end
    end

    # repack the bits into the original bytes array
    data = tobytes(data_bits)
    
    return data
end
