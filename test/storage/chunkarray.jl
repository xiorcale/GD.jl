@testset "ChunkArray" begin
    T = UInt8
    data = rand(T, 100)
    chunks = GD.Storage.ChunkArray{T}(data, 15)

    @test length(chunks) == 7
    @test chunks.padsize == 5
    @test length(chunks[1:2]) == 2
    @test length(similar(chunks)) == length(chunks)
    @test chunks[begin] == data[1:15]
    @test chunks[end] == vcat(data[91:end], zeros(T, 5))
end