"""
    AbstractPhylogenyFormat

Abstract supertype for phylogeny serialization format tags. Concrete
subtypes are singleton structs used to dispatch [`parsephylogenies`](@ref) and
[`readphylogenies`](@ref) methods to the reader for that format.
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
    parsephylogenies(format, io::IO) -> Vector{<:LineageNetwork}

Parse `format`-formatted content from the open stream `io` and return the
phylogenies it contains. Performs no file I/O itself; `io` may be a file
handle, an `IOBuffer`, or any other `IO` source.
"""
function parsephylogenies(
        ::NewickFormat,
        io::IO,
    )::Vector{LineageNetwork{Nothing, Nothing, Nothing}}
    text = strip(read(io, String))
    isempty(text) && return LineageNetwork{Nothing, Nothing, Nothing}[]
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
    return [
        from_hybridnetwork(PhyloNetworks.readnewick(IOBuffer(string(topology, ';'))))
            for topology in topologies
    ]
end

"""
    parsephylogenies(format, text::AbstractString) -> Vector{<:LineageNetwork}

Parse `text` as literal `format`-formatted content and return the phylogenies
it contains. `text` is always treated as content, never as a file path.
"""
function parsephylogenies(
        fmt::NewickFormat,
        text::AbstractString,
    )::Vector{LineageNetwork{Nothing, Nothing, Nothing}}
    return parsephylogenies(fmt, IOBuffer(text))
end

export parsephylogenies

"""
    readphylogenies(format, path::AbstractString) -> Vector{<:LineageNetwork}

Read `format`-formatted content from the file at `path` and return the
phylogenies it contains. `path` is always treated as a file path, never as
literal content.
"""
function readphylogenies(
        fmt::AbstractPhylogenyFormat,
        path::AbstractString,
    )::Vector{LineageNetwork{Nothing, Nothing, Nothing}}
    return open(io -> parsephylogenies(fmt, io), path)
end

"""
    readphylogenies(::NexusFormat, path::AbstractString) -> Vector{<:LineageNetwork}

Read the first trees block of the NEXUS file at `path`, applying its
translate table if present. Delegates directly to
`PhyloNetworks.readnexus_treeblock`.
"""
function readphylogenies(
        ::NexusFormat,
        path::AbstractString,
    )::Vector{LineageNetwork{Nothing, Nothing, Nothing}}
    return from_hybridnetwork.(PhyloNetworks.readnexus_treeblock(path))
end

"""
    parsephylogenies(::NexusFormat, text::AbstractString) -> Vector{<:LineageNetwork}

Parse a NEXUS trees block from literal `text`. `PhyloNetworks.readnexus_treeblock`
only accepts a file path — there is no upstream entry point that reads NEXUS
content from text or an `IO` stream. Rather than duplicating its translate
table / gamma extraction logic locally, this writes `text` to a temporary
file and delegates to [`readphylogenies`](@ref)(NexusFormat(), path), so there
stays exactly one implementation of NEXUS treeblock parsing. Unlike the
`NewickFormat` methods, this performs real (transient) file I/O.
"""
function parsephylogenies(
        ::NexusFormat,
        text::AbstractString,
    )::Vector{LineageNetwork{Nothing, Nothing, Nothing}}
    return mktemp() do path, io
        write(io, text)
        close(io)
        readphylogenies(NexusFormat(), path)
    end
end

"""
    parsephylogenies(::NexusFormat, io::IO) -> Vector{<:LineageNetwork}

Read all of `io` and parse it as a NEXUS trees block; see the
`AbstractString` method for why this is not a pure in-memory parse for
`NexusFormat`.
"""
function parsephylogenies(
        fmt::NexusFormat,
        io::IO,
    )::Vector{LineageNetwork{Nothing, Nothing, Nothing}}
    return parsephylogenies(fmt, read(io, String))
end

export readphylogenies

"""
    parsephylogeny(format, source) -> LineageNetwork

Parse exactly one phylogeny from literal `format`-formatted content in `source`.
`source` may be a string or an `IO` stream. Use [`parsephylogenies`](@ref) when
the content may contain zero or multiple phylogenies.
"""
function parsephylogeny(
        format::AbstractPhylogenyFormat,
        source::Union{IO, AbstractString},
    )::LineageNetwork{Nothing, Nothing, Nothing}
    return only(parsephylogenies(format, source))
end

"""
    readphylogeny(format, path::AbstractString) -> LineageNetwork

Read exactly one phylogeny from the `format`-formatted file at `path`. Use
[`readphylogenies`](@ref) when the file may contain zero or multiple
phylogenies.
"""
function readphylogeny(
        format::AbstractPhylogenyFormat,
        path::AbstractString,
    )::LineageNetwork{Nothing, Nothing, Nothing}
    return only(readphylogenies(format, path))
end

export parsephylogeny, readphylogeny

"""
    newick"..." -> LineageNetwork

Parse exactly one extended Newick topology from literal content. The literal
returns a fresh [`LineageNetwork`](@ref) each time it is evaluated. Use
[`parsephylogenies`](@ref) with [`NewickFormat`](@ref) when the content may
contain multiple topologies.
"""
macro newick_str(text)
    return :(parsephylogeny(NewickFormat(), $text))
end

"""
    nexustreeblock"..." -> LineageNetwork

Parse exactly one phylogeny from the first trees block in literal NEXUS content.
The literal returns a fresh [`LineageNetwork`](@ref) each time it is
evaluated. Use [`parsephylogenies`](@ref) with [`NexusFormat`](@ref) when the
trees block may contain multiple phylogenies.
"""
macro nexustreeblock_str(text)
    return :(parsephylogeny(NexusFormat(), $text))
end

export @newick_str, @nexustreeblock_str
