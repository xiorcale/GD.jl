using SHA

@testset "Store" begin
    
    chunksize = 256

    function gd_compress_extract(::Type{T}, store) where T <: Unsigned
        data = rand(T, 1000)
        gdfile = GD.Storage.compress!(store, data)
        res = GD.Storage.extract(store, gdfile)
        @test res == data
    end


    @testset "UInt8 GD" begin
        quantizer = GD.Transform.Quantizer{UInt8}(chunksize, 0x05)
        compressor = GD.Storage.Compressor(chunksize, quantizer, sha1)
        store = GD.Storage.Store(compressor, Dict(), 0, 0)
        gd_compress_extract(UInt8, store)
    end

    @testset "UInt16 GD" begin
        quantizer = GD.Transform.Quantizer{UInt16}(chunksize, 0x000C)
        compressor = GD.Storage.Compressor(chunksize, quantizer, sha1)
        store = GD.Storage.Store(compressor, Dict(), 0, 0)
        gd_compress_extract(UInt16, store)
    end
end