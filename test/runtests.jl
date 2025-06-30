module KWayMergesTest

using KWayMerges
using Test

@testset "Construction" begin
    v = [1:3, 4:6, 9:11]

    T = KWayMerger{Int, UnitRange{Int}, typeof(isless), Int}

    @test KWayMerger{Int, UnitRange{Int}, typeof(isless)}(isless, v) isa T
    @test KWayMerger{Int, UnitRange{Int}}(v) isa T
    @test KWayMerger(v) isa T
    @test KWayMerger(isless, v) isa T
    @test KWayMerger(<, v) isa KWayMerger{Int, UnitRange{Int}, typeof(<)}
end

function manual_collect(it; lt=isless, by=identity)
    v = Iterators.map(enumerate(it)) do (i, inner_it)
        zip(Iterators.repeated(i), inner_it)
    end |> Iterators.flatten |> collect
    sort!(v; by = i -> by(last(i)), lt)
end

@testset "Forward sorting" begin
    v = [[3, 5, 8], [1, 1], [10, 11], [1, 2, 7], Int[]]

    @test collect(KWayMerger(v)) == manual_collect(v)
end

@testset "Using a predicate" begin
    v = [["de", "abc"], [""], ["xysa", "dsakljdwe"]]

    r = manual_collect(v; by=length)

    @test collect(KWayMerger((i, j) -> isless(length(i), length(j)), v)) == r
end

@testset "Reverse sorting" begin
    v = [[3, 5, 8], [1, 0], [10, 11], [4, 2, 7], Int[]]
    for i in v
        sort!(i; rev = true)
    end
    r = manual_collect(v; lt = >)

    @test collect(KWayMerger((i, j) -> isless(j, i), v)) == r
end

@testset "Some edge cases" begin
    it = KWayMerger([])
    @test it isa (KWayMerger{T, I, typeof(isless)} where {T, I})
    @test collect(it) == Any[]

    it = KWayMerger([1:0, 11:10])
    @test it isa KWayMerger{Int, UnitRange{Int}, typeof(isless)}
    @test collect(it) == Tuple{Int, Int}[]
    @test typeof(collect(it)) == Vector{Tuple{Int, Int}}
end

end # module KWayMergesTest
