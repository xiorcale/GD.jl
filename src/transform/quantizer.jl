"""
    Quantizer

Transformer which create a basis and deviation pair as follow:

- basis: keep only the `bsize` MSB of each byte
- deviation: keep the remaing `dsize` LSB of each byte
"""
struct Quantizer <: AbstractTransformer
    bsize::UInt8
    dsize::UInt8
    factor::UInt8

    Quantizer(bsize) = begin
        dsize = 0x08 - bsize
        factor = 0x02 ^ dsize
        return new(bsize, dsize, factor)
    end
end

"""
    transform(quantizer::Quantizer, data::Vector{UInt8})

Split each byte into a smaller representation of `quantizer.bsize` bits and an
error of `quantizer.dsize` bits (generated by the lossy transformation). 

Return the concatenation of the quantized bytes as the `basis`, and the 
concatenation of the errors as the `deviation.`

/!/ `quantizer` is operating at the bit level and requires `length(data)` data
    to be a power of 2.
"""
function transform(quantizer::Quantizer, data::Vector{UInt8})
    datastr = [bitstring(d) for d in data]
    
    # extract MSB and pack them in bytes
    basis_str = mapreduce(d -> d[1:quantizer.bsize], *, datastr)
    packed_basis_str = [basis_str[i:i+7] for i in 1:8:length(basis_str)]
    basis = [bits2uint(b) for b in packed_basis_str]

    # extract LSB and pack them in bytes
    dev_str = mapreduce(d ->d[quantizer.bsize+1:end], *, datastr)
    packed_dev_str = [dev_str[i:i+7] for i in 1:8:length(dev_str)]
    deviation = [bits2uint(b) for b in packed_dev_str]
    
    return basis, deviation
end

"""
    invtransform(quantizer, basis, deviation)

Extract each couple (quantized value, error) from `basis` and `deviation` and 
rebuild the original data by combining the quantized represenation with the error.

return the original byte array to which `transform()` has been applied.
"""
function invtransform(quantizer::Quantizer, basis::Vector{UInt8}, deviation::Vector{UInt8})
    basis_str = mapreduce(b -> bitstring(b), *, basis)
    dev_str = mapreduce(d -> bitstring(d), *, deviation)

    return [
        bits2uint(basis_str[i:i+quantizer.bsize-1] * dev_str[j:j+quantizer.dsize-1])
        for (i, j) in zip(1:quantizer.bsize:length(basis_str), 1:quantizer.dsize:length(dev_str))
    ]
end
