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

    Quantizer(chunksize, msbsize) = begin
        lsbsize = 0x08 - msbsize

        bsize = chunksize * msbsize
        dsize = chunksize * lsbsize

        bpad = ceil(bsize / 8) * 8 - bsize |> Int
        dpad = ceil(dsize / 8) * 8 - dsize |> Int

        return new(lsbsize, msbsize, bpad, dpad)
    end
end


"""
    transform(quantizer::Quantizer, data::Vector{UInt8})

Cut each byte into a basis containing the `quantizer.msbsize` MSB of the byte,
and a deviation containing the `quantizer.lsbsize` LSB of the byte.

Return the concatenation of the MSB of the bytes as the `basis`, and the 
concatenation of the LSB of the bytes as the `deviation.`
"""
function transform(quantizer::Quantizer, data::Vector{UInt8})
    # expand bytes into bitarray
    databits = tobits(data)

    # throw the LSB into the deviation and the MSB into the basis
    devbits = reduce(vcat, [d[1:quantizer.lsbsize] for d in partition(databits, 8)])
    basisbits = reduce(vcat, [d[quantizer.lsbsize+1:end] for d in partition(databits, 8)])

    # repack the bits arrays into compact bytes array. The remaining bits are
    # padded into the last byte
    deviation = tobytes(devbits)
    basis = tobytes(basisbits)

    return basis, deviation
end

"""
    invtransform(quantizer, basis, deviation)

Extract each couple (MSB, LSB) from `basis` and `deviation` and 
rebuild the original data by combining them.

return the original byte array which has been transform by `transform()`.
"""
function invtransform(quantizer::Quantizer, basis::Vector{UInt8}, deviation::Vector{UInt8})
    # expand bytes into bitarray
    basis = tobits(basis)[1:end-quantizer.bpad]
    deviation = tobits(deviation)[1:end-quantizer.dpad]

    # "glue" the LSB and MSB together 
    databits = reduce(vcat, [
        vcat(lsb, msb) 
        for (lsb, msb) in zip(
            partition(deviation, quantizer.lsbsize),
            partition(basis, quantizer.msbsize)
        )
    ])

    # repack the bits into the original bytes array
    data = tobytes(databits)
    
    return data
end
