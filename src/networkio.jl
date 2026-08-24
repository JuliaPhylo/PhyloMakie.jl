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
subtypes are singleton structs used to dispatch [`parsenetwork`](@ref) and
[`readnetwork`](@ref) methods to the reader for that format.
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
    parsenetwork(format, io::IO) -> Vector{LineageNetwork}

Parse `format`-formatted content from the open stream `io` and return the
networks it contains. Performs no file I/O itself; `io` may be a file
handle, an `IOBuffer`, or any other `IO` source.
"""
function parsenetwork(::NewickFormat, io::IO)::Vector{LineageNetwork}
    return LineageNetwork[PhyloNetworks.readnewick(io)]
end

"""
    parsenetwork(format, text::AbstractString) -> Vector{LineageNetwork}

Parse `text` as literal `format`-formatted content and return the networks
it contains. `text` is always treated as content, never as a file path.
"""
function parsenetwork(fmt::NewickFormat, text::AbstractString)::Vector{LineageNetwork}
    return parsenetwork(fmt, IOBuffer(text))
end

export parsenetwork

"""
    readnetwork(format, path::AbstractString) -> Vector{LineageNetwork}

Read `format`-formatted content from the file at `path` and return the
networks it contains. `path` is always treated as a file path, never as
literal content.
"""
function readnetwork(fmt::AbstractPhylogenyFormat, path::AbstractString)::Vector{LineageNetwork}
    return open(io -> parsenetwork(fmt, io), path)
end

"""
    readnetwork(::NexusFormat, path::AbstractString) -> Vector{LineageNetwork}

Read the first trees block of the NEXUS file at `path`, applying its
translate table if present. Delegates directly to
`PhyloNetworks.readnexus_treeblock`.
"""
function readnetwork(::NexusFormat, path::AbstractString)::Vector{LineageNetwork}
    return PhyloNetworks.readnexus_treeblock(path)
end

"""
    parsenetwork(::NexusFormat, text::AbstractString) -> Vector{LineageNetwork}

Parse a NEXUS trees block from literal `text`. `PhyloNetworks.readnexus_treeblock`
only accepts a file path — there is no upstream entry point that reads NEXUS
content from text or an `IO` stream. Rather than duplicating its translate
table / gamma extraction logic locally, this writes `text` to a temporary
file and delegates to [`readnetwork`](@ref)(NexusFormat(), path), so there
stays exactly one implementation of NEXUS treeblock parsing. Unlike the
`NewickFormat` methods, this performs real (transient) file I/O.
"""
function parsenetwork(::NexusFormat, text::AbstractString)::Vector{LineageNetwork}
    return mktemp() do path, io
        write(io, text)
        close(io)
        readnetwork(NexusFormat(), path)
    end
end

"""
    parsenetwork(::NexusFormat, io::IO) -> Vector{LineageNetwork}

Read all of `io` and parse it as a NEXUS trees block; see the
`AbstractString` method for why this is not a pure in-memory parse for
`NexusFormat`.
"""
function parsenetwork(fmt::NexusFormat, io::IO)::Vector{LineageNetwork}
    return parsenetwork(fmt, read(io, String))
end

export readnetwork
