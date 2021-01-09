using SHA


@testset "Compressor" begin
    
    chunksize = 256
    
    function compress_extract(::Type{T}, compressor) where T <: Unsigned
        data = rand(T, 1000)
        gdfile, bases = GD.Storage.compress(compressor, data)
        res = GD.Storage.extract(compressor, gdfile, bases)
        @test res == data
    end

    @testset "UInt8 compressor" begin
        quantizer = GD.Transform.Quantizer{UInt8}(chunksize, 0x05)
        compressor = GD.Storage.Compressor(chunksize, quantizer, sha1)
        compress_extract(UInt8, compressor)
    end
    
    @testset "UInt16 compressor" begin
        quantizer = GD.Transform.Quantizer{UInt16}(chunksize, 0x000C)
        compressor = GD.Storage.Compressor(chunksize, quantizer, sha1)
        compress_extract(UInt16, compressor)
    end
    
end