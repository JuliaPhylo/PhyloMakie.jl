"""
    LineageNetwork

Alias for `PhyloNetworks.HybridNetwork`, the tree/network type used
throughout PhyloMakie.
"""
const LineageNetwork = PhyloNetworks.HybridNetwork
export LineageNetwork

"""
    AbstractPhylogenyFormat

Abstract supertype for phylogeny serialization format tags. Concrete
subtypes are singleton structs used to dispatch [`parsephylogeny`](@ref) and
[`readphylogeny`](@ref) methods to the reader for that format.
"""
abstract type AbstractPhylogenyFormat end

"""
    NewickFormat

Format tag for (extended) Newick parenthetical notation.
"""
struct NewickFormat <: AbstractPhylogenyFormat end

"""
    NexusFormat

Format tag for NEXUS-formatted files containing a trees block.
"""
struct NexusFormat <: AbstractPhylogenyFormat end

export AbstractPhylogenyFormat, NewickFormat, NexusFormat

"""
    parsephylogeny(format, io::IO) -> Vector{LineageNetwork}

Parse `format`-formatted content from the open stream `io` and return the
phylogenies it contains. Performs no file I/O itself; `io` may be a file
handle, an `IOBuffer`, or any other `IO` source.
"""
function parsephylogeny(::NewickFormat, io::IO)::Vector{LineageNetwork}
    text = strip(read(io, String))
    isempty(text) && return LineageNetwork[]
    endswith(text, ";") || throw(
        ArgumentError(
            "Every Newick topology must end with `;`.",
        )
    )

    topologies = strip.(split(chop(text), ';'))
    any(isempty, topologies) && throw(
        ArgumentError(
            "Newick content must not contain empty topologies.",
        )
    )
    return LineageNetwork[
        PhyloNetworks.readnewick(IOBuffer(string(topology, ';')))
            for topology in topologies
    ]
end

"""
    parsephylogeny(format, text::AbstractString) -> Vector{LineageNetwork}

Parse `text` as literal `format`-formatted content and return the phylogenies
it contains. `text` is always treated as content, never as a file path.
"""
function parsephylogeny(fmt::NewickFormat, text::AbstractString)::Vector{LineageNetwork}
    return parsephylogeny(fmt, IOBuffer(text))
end

export parsephylogeny

"""
    readphylogeny(format, path::AbstractString) -> Vector{LineageNetwork}

Read `format`-formatted content from the file at `path` and return the
phylogenies it contains. `path` is always treated as a file path, never as
literal content.
"""
function readphylogeny(fmt::AbstractPhylogenyFormat, path::AbstractString)::Vector{LineageNetwork}
    return open(io -> parsephylogeny(fmt, io), path)
end

"""
    readphylogeny(::NexusFormat, path::AbstractString) -> Vector{LineageNetwork}

Read the first trees block of the NEXUS file at `path`, applying its
translate table if present. Delegates directly to
`PhyloNetworks.readnexus_treeblock`.
"""
function readphylogeny(::NexusFormat, path::AbstractString)::Vector{LineageNetwork}
    return PhyloNetworks.readnexus_treeblock(path)
end

"""
    parsephylogeny(::NexusFormat, text::AbstractString) -> Vector{LineageNetwork}

Parse a NEXUS trees block from literal `text`. `PhyloNetworks.readnexus_treeblock`
only accepts a file path — there is no upstream entry point that reads NEXUS
content from text or an `IO` stream. Rather than duplicating its translate
table / gamma extraction logic locally, this writes `text` to a temporary
file and delegates to [`readphylogeny`](@ref)(NexusFormat(), path), so there
stays exactly one implementation of NEXUS treeblock parsing. Unlike the
`NewickFormat` methods, this performs real (transient) file I/O.
"""
function parsephylogeny(::NexusFormat, text::AbstractString)::Vector{LineageNetwork}
    return mktemp() do path, io
        write(io, text)
        close(io)
        readphylogeny(NexusFormat(), path)
    end
end

"""
    parsephylogeny(::NexusFormat, io::IO) -> Vector{LineageNetwork}

Read all of `io` and parse it as a NEXUS trees block; see the
`AbstractString` method for why this is not a pure in-memory parse for
`NexusFormat`.
"""
function parsephylogeny(fmt::NexusFormat, io::IO)::Vector{LineageNetwork}
    return parsephylogeny(fmt, read(io, String))
end

export readphylogeny

function _parse_single_phylogeny(
        format::AbstractPhylogenyFormat,
        text::AbstractString,
    )::LineageNetwork
    phylogenies = parsephylogeny(format, text)
    length(phylogenies) == 1 || throw(
        ArgumentError(
            "Expected exactly one phylogeny in $(nameof(typeof(format))) content, " *
                "but parsed $(length(phylogenies)). Use `parsephylogeny($(nameof(typeof(format)))(), text)` " *
                "when the input may contain multiple phylogenies.",
        )
    )
    return only(phylogenies)
end

"""
    newick"..." -> LineageNetwork

Parse exactly one extended Newick topology from literal content. The literal
returns a fresh `PhyloNetworks.HybridNetwork` each time it is evaluated. Use
[`parsephylogeny`](@ref) with [`NewickFormat`](@ref) when the content may contain
multiple topologies.
"""
macro newick_str(text)
    return :(_parse_single_phylogeny(NewickFormat(), $text))
end

"""
    nexustreeblock"..." -> LineageNetwork

Parse exactly one phylogeny from the first trees block in literal NEXUS content.
The literal returns a fresh `PhyloNetworks.HybridNetwork` each time it is
evaluated. Use [`parsephylogeny`](@ref) with [`NexusFormat`](@ref) when the trees
block may contain multiple phylogenies.
"""
macro nexustreeblock_str(text)
    return :(_parse_single_phylogeny(NexusFormat(), $text))
end

export @newick_str, @nexustreeblock_str
