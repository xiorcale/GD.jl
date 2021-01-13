using BenchmarkTools
using GD
using SHA

const suite = BenchmarkGroup()

suite["transform"] = BenchmarkGroup(["quantizer"])
suite["storage"] = BenchmarkGroup(["compressor", "gdfile", "store"])

datachunk = rand(UInt8, 256) 
data = rand(UInt8, 1024 * 1024) # 1Mb

chunksize = 256
T = UInt8

msbsize = 0x05
lsbsize = 0x03
quantizer = GD.Transform.Quantizer{T}(chunksize, msbsize)
compressor = GD.Storage.Compressor(chunksize, quantizer, sha1)
store = GD.Storage.Store(compressor, Dict(), 0, 0)

suite["transform"]["quantize"] = @benchmarkable [
    GD.Transform.transform(quantizer, datachunk)
    for i in 1:4*1024
]

b, d = GD.Transform.transform(quantizer, datachunk)
suite["transform"]["dequantize"] = @benchmarkable [
        GD.Transform.invtransform(quantizer, b, d)
        for i in 1:4*1024
]


suite["storage"]["compress"] = @benchmarkable GD.Storage.compress(compressor, data)
gdfile, bases = GD.Storage.compress(compressor, data)
suite["storage"]["extract"] = @benchmarkable GD.Storage.extract(compressor, gdfile, bases)


suite["storage"]["patch"] = @benchmarkable GD.Storage.patch(gdfile, gdfile)
patch = GD.Storage.patch(gdfile, gdfile)
suite["storage"]["unpatch"] = @benchmarkable GD.Storage.unpatch(gdfile, patch)


suite["storage"]["compress!"] = @benchmarkable GD.Storage.compress!(store, data)
gdfile = GD.Storage.compress!(store, data)
suite["storage"]["extract_storage"] = @benchmarkable GD.Storage.extract(store, gdfile)


paramspath = joinpath(dirname(@__FILE__), "params.json")

if isfile(paramspath)
    loadparams!(suite, BenchmarkTools.load(paramspath)[1], :evals);
else
    tune!(suite)
    BenchmarkTools.save(paramspath, params(suite));
end