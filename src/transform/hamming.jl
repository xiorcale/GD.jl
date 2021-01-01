using LinearAlgebra: dot

"""
    Hamming

Transformer which create a basis and a deviation as follow:

- basis: The message decoded by a Hamming code
- deviation: the error index 
"""
struct Hamming <: AbstractTransformer
    codeword_size::Int
    num_paritybits::Int
    p_sub_matrix::BitMatrix
    syndrome_table::Dict{UInt64, Int64}

    Hamming(codeword_size) = begin
        codeword_size *= 8
        num_paritybits = calculate_num_parity_bits(codeword_size)
        p_sub_matrix = create_P_sub_matrix(codeword_size, num_paritybits)
        syndrome_table = create_syndrome_table(codeword_size, num_paritybits, p_sub_matrix)
    
        return new(
            codeword_size,
            num_paritybits,
            p_sub_matrix,
            syndrome_table
        )
    end
end

"""
    calculate_num_parity_bits(codeword_size)

Calculate the number of parity bits used for a codeword of size `codeword_size`.
"""
function calculate_num_parity_bits(codeword_size)
    for num_paritybits in 1:codeword_size
        2^num_paritybits >= codeword_size + 1 && return num_paritybits
    end
end

"""
    create_P_sub_matrix(codeword_size, num_paritybits)

Create the sub matrix used for computing the parity bits values.
"""
function create_P_sub_matrix(codeword_size, num_paritybits)
    p_sub_matrix = trues(codeword_size - num_paritybits, num_paritybits)
    curr = 1
    for i in 3:codeword_size # 1 and 2 have only 1 bit set, we can skip them
        row = digits(Bool, i; base=2, pad=num_paritybits)
        if count(row) > 1
            p_sub_matrix[curr, :] = row
            curr += 1
        end
    end
    return p_sub_matrix
end

"""
    create_syndrome_table(codeword_size, num_paritybits, p_sub_matrix)

Create the syndrom table used to find the potential error index in the codeword.
"""
function create_syndrome_table(codeword_size, num_paritybits, p_sub_matrix)
    mateye = biteye(num_paritybits)
    pt_sub_matrix = BitArray(transpose(p_sub_matrix))
    parity_check_matrix_T = transpose(hcat(mateye, pt_sub_matrix))
    syndrome_table = Dict{UInt64, Int64}(0 => -1)

    for error_index in 1:codeword_size
        # extract the row instead of performing a dot product full of 0
        binary_error = parity_check_matrix_T[error_index, :]
        syndrome = bits2uint(UInt64, binary_error)
        syndrome_table[syndrome] = error_index
    end

    return syndrome_table
end

"""
    transform(hamming, data)

Decode `data` by removing the parity bits.

Return the decoded message as the `basis` and the error index as the
`deviation`.
"""
function transform(hamming::Hamming, data::Vector{T}) where T <: Unsigned
    # codeword = tobits(data)
    codeword = reduce(vcat, digits.(Bool, data, base=2, pad=8))
    parity_bits = @view codeword[begin:hamming.num_paritybits]
    data = @view codeword[hamming.num_paritybits + 1:end]
    
    syndrome = map(col -> dot(data, col), eachcol(hamming.p_sub_matrix)) + parity_bits
    syndrome = BitArray(syndrome .& 1)
    syndrome = bits2uint(UInt64, syndrome)
    
    error_index = hamming.syndrome_table[syndrome]
    
    error_pattern = falses(hamming.codeword_size)
    error_pattern[error_index] = syndrome != 0 ? 1 : 0
    data_pattern = error_pattern[hamming.num_paritybits + 1:end]
    
    decoded_msg = BitVector(data .⊻ data_pattern)
    
    basis = tobytes_lsb(decoded_msg)
    
    return basis, error_index
end

"""
    invtransform(hamming, basis, deviation)

Compute the parity bit values for `basis` and correct the error (if any) at
index `deviation`.

return the original byte array to which `transform()` has been applied.
"""
function invtransform(hamming::Hamming, basis::Vector{UInt8}, deviation::Int64)
    # transforming the bitarray into bytes, add some padding on the last byte
    padding = hamming.num_paritybits % 8
    # message = tobits(basis)
    # message = vcat(message[1:length(message)-8], message[length(message)-7:end][padding+1:end])

    message = reduce(vcat, digits.(Bool, basis, base=2, pad=8))
    message = message[1:length(message) - padding]

    parity_bits = BitVector(map(col -> dot(message, col) & 1, eachcol(hamming.p_sub_matrix)))
    data = vcat(parity_bits, message)

    if deviation != -1
        data[deviation] ⊻= 1
    end

    return tobytes_lsb(data)
end
