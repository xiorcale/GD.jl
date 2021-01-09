@testset "Quantization" begin

    chunksize = 256

    function zero_quantization(::Type{T}, quantizer) where T <: Unsigned
        data = zeros(T, quantizer.chunksize)
        basis, deviation = GD.Transform.transform(quantizer, data)
        @test basis == zeros(UInt8, Int(floor(quantizer.chunksize / 8 * quantizer.msbsize)))
        @test deviation == zeros(UInt8, Int(floor(quantizer.chunksize / 8 * quantizer.lsbsize)))

        res = GD.Transform.invtransform(quantizer, basis, deviation)
        @test res == data
    end

    function random_quantization(::Type{T}, quantizer) where T <: Unsigned
        data = rand(T, quantizer.chunksize)
        basis, deviation = GD.Transform.transform(quantizer, data)
        res = GD.Transform.invtransform(quantizer, basis, deviation)
        @test res == data
    end

    @testset "UInt8 quantizer" begin
        T = UInt8
        msbsize = 0x05
        lsbsize = 0x03
        quantizer = GD.Transform.Quantizer{T}(chunksize, msbsize)

        zero_quantization(T, quantizer)
        random_quantization(T, quantizer)
    end

    @testset "UInt16 quantizer" begin
        T = UInt16
        msbsize = 0x000C
        lsbsize = 0x0003
        quantizer = GD.Transform.Quantizer{T}(chunksize, msbsize)

        zero_quantization(T, quantizer)
        random_quantization(T, quantizer)
    end
end
