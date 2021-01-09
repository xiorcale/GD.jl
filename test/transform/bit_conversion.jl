@testset "Binary utils" begin

    function convertion(::Type{T}) where T <: Unsigned
        chunksize = 256
        zero_data = zeros(T, chunksize)
        unpacked_data = GD.Transform.unpack(zero_data)
        packed_data = GD.Transform.pack(T, unpacked_data)
        
        @test unpacked_data == falses(chunksize * 8 * sizeof(T))
        @test packed_data == zero_data
    end

    function convertion_with_padding(::Type{T}) where T <: Unsigned
        data = BitVector([0,1,0,0,0])
        converted_data = GD.Transform.convert(T, data)
        @test converted_data == T(8)
    end


    @testset "UInt8" begin
        convertion(UInt8)
        convertion_with_padding(UInt8)
    end

    @testset "UInt16" begin
        convertion(UInt16)
        convertion_with_padding(UInt16)
    end
end
