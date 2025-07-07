module KWayMergesTest

using KWayMerges
using Test

imap(f) = xs -> Iterators.map(f, xs)

@testset "Construction" begin
    v = [1:3, 4:6, 9:11]

    T = KWayMerges.KWayMerger{Int, UnitRange{Int}, Base.Order.ForwardOrdering}

    @test kway_merge(Int, UnitRange{Int}, v; lt = isless) isa T
    @test kway_merge(Int, UnitRange{Int}, v; rev = false) isa T
    @test kway_merge(v) isa T
    @test kway_merge(v; by = identity, lt = isless) isa T
    @test kway_merge(v; lt = <) isa KWayMerges.KWayMerger{Int, UnitRange{Int}}
end

function manual_collect(it; lt = isless, by = identity)
    v = Iterators.map(enumerate(it)) do (i, inner_it)
        zip(Iterators.repeated(i), inner_it)
    end |> Iterators.flatten |> imap() do (i, v)
        (; from_iter = i, value = v)
    end |> collect
    return sort!(v; by = i -> by(last(i)), lt)
end

@testset "Forward sorting" begin
    v = [[3, 5, 8], [1, 1], [10, 11], [1, 2, 7], Int[]]

    @test collect(kway_merge(v)) == manual_collect(v)
end

@testset "Using a predicate" begin
    v = [["de", "abc"], [""], ["xysa", "dsakljdwe"]]

    r = manual_collect(v; by = length)

    @test collect(kway_merge(v; rev = false, by = length)) == r
end

@testset "Reverse sorting" begin
    v = [[3, 5, 8], [1, 0], [10, 11], [4, 2, 7], Int[]]
    for i in v
        sort!(i; rev = true)
    end
    r = manual_collect(v; lt = >)

    @test collect(kway_merge(v; order = Base.Order.Reverse)) == r
end

@testset "Some edge cases" begin
    it = kway_merge([])
    @test it isa (KWayMerges.KWayMerger{T, I, Base.Order.ForwardOrdering} where {T, I})
    @test collect(it) == Any[]

    it = kway_merge([1:0, 11:10])
    @test it isa KWayMerges.KWayMerger{Int, UnitRange{Int}, Base.Order.ForwardOrdering}
    @test collect(it) == Tuple{Int, Int}[]
    @test typeof(collect(it)) == Vector{@NamedTuple{from_iter::Int, value::Int}}
end

end # module KWayMergesTest
