@testset "GDFile" begin

    hashes = [rand(UInt8, 20) for i in 1:160]
    deviations = [rand(UInt8, 96) for i in 1:160]
    gdfile = GD.Storage.GDFile(hashes, deviations, 0)
    
    # copy GDFile and modify the first 10 hashes/deviations
    gdfile2 = deepcopy(gdfile)
    gdfile2.hashes[1:10] = [rand(UInt8, 20) for i in 1:10]
    gdfile2.deviations[1:10] = [rand(UInt8, 96) for i in 1:10]

    # patch gdfile by replacing all the similar values by [0x00]
    patched_gdfile = GD.Storage.patch(gdfile, gdfile2)
    @test sum(patched_gdfile.hashes[11:end]) == [0x00]
    @test sum(patched_gdfile.deviations[11:end]) == [0x00]

    # unpatch the file and make sure it is the same as the original one
    unpatched_gdfile = GD.Storage.unpatch(patched_gdfile, gdfile2)
    @test unpatched_gdfile.hashes == gdfile.hashes
    @test unpatched_gdfile.deviations == gdfile.deviations
end