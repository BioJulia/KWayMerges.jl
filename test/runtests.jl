module KWayMergesTest

using KWayMerges

using Test

@testset "Approximation" begin
    x = MyType(3, 4)
    @test isapprox(my_function(x), 5)
end

end # module KWayMergesTest
