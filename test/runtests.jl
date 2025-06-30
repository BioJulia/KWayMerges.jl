module KWayMergesTest

using KWayMerges
using Test

@testset "Construction" begin
    v = [1:3, 4:6, 9:11]

    T = KWayMerger{typeof(isless), Int, UnitRange{Int}, Int}

    @test KWayMerger{typeof(isless), Int, UnitRange{Int}}(isless, v) isa T
    @test KWayMerger{Int, UnitRange{Int}}(v) isa T
    @test KWayMerger(v) isa T
    @test KWayMerger(isless, v) isa T
    @test KWayMerger(<, v) isa KWayMerger{typeof(<), Int, UnitRange{Int}}
end

@testset "Forward sorting" begin
    v = [[3, 5, 8], [1, 1], [10, 11], [1, 2, 7], Int[]]
    r = sort(collect(Iterators.flatten(v)))

    @test collect(KWayMerger(v)) == r
end

@testset "Using a predicate" begin
    v = [["de", "abc"], [""], ["xysa", "dsakljdwe"]]
    r = sort(collect(Iterators.flatten(v)); by = length)

    @test collect(KWayMerger((i, j) -> isless(length(i), length(j)), v)) == r
end

@testset "Reverse sorting" begin
    v = [[3, 5, 8], [1, 1], [10, 11], [1, 2, 7], Int[]]
    for i in v
        sort!(i; rev = true)
    end
    r = sort(collect(Iterators.flatten(v)); rev = true)

    @test collect(KWayMerger((i, j) -> isless(j, i), v)) == r
end

@testset "Some edge cases" begin
    it = KWayMerger([])
    @test it isa KWayMerger{typeof(isless)}
    @test collect(it) == Any[]

    it = KWayMerger([1:0, 11:10])
    @test it isa KWayMerger{typeof(isless), Int}
    @test collect(it) == Int[]
    @test typeof(collect(it)) == Vector{Int}
end

end # module KWayMergesTest
