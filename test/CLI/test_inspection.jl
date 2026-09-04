@testset "Metadata inspection" begin
    records = [
        PhyloMakieCLI.SourceRecord(
            parsephylogeny(NewickFormat(), "(A:1,(B:2,C:3):4);"),
            "first.nwk",
            1,
        ),
        PhyloMakieCLI.SourceRecord(
            parsephylogeny(NewickFormat(), "(D,E);"),
            "second.nwk",
            1,
        ),
    ]
    statistics = PhyloMakieCLI.collection_statistics(records)
    @test statistics.taxa == ["A", "B", "C", "D", "E"]
    @test statistics.records[1].branch_length_coverage === :complete
    @test statistics.records[1].branch_length_sum == 10.0
    @test statistics.records[2].branch_length_coverage === :none

    summary_io = IOBuffer()
    PhyloMakieCLI.write_inspection(summary_io, statistics)
    summary = String(take!(summary_io))
    @test occursin("Phylogenies: 2", summary)
    @test occursin("Tips per phylogeny: min 2, mean 2.5, max 3", summary)
    @test occursin("Complete tree length: min 10, mean 10, max 10", summary)

    detail_io = IOBuffer()
    PhyloMakieCLI.write_inspection(detail_io, statistics; verbosity = 2)
    detail = String(take!(detail_io))
    @test occursin("first.nwk [record 1]", detail)
    @test occursin("Observed edge lengths: min 1, mean 2.5, max 4", detail)
    @test occursin("Taxa: A, B, C", detail)

    taxa_io = IOBuffer()
    PhyloMakieCLI.write_inspection(taxa_io, statistics; taxa_only = true)
    @test String(take!(taxa_io)) == "A\nB\nC\nD\nE\n"
end
