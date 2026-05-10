struct DeferredKeywordContract
    id::Symbol
    keyword::Symbol
    owner_tranche::Int
    closure_status::Symbol
    description::String
end

struct KeywordSurfaceContractEntry
    keyword::Symbol
    default_source::String
    closure_status::Symbol
    deferred_owner::Union{Nothing, Int}
    deferred_contract_ids::Tuple{Vararg{Symbol}}
end

const SUPPORTED_PLOT_KEYWORDS = (
    :useedgelength,
    :showtiplabel,
    :shownodenumber,
    :showedgelength,
    :showgamma,
    :edgecolor,
    :majorhybridedgecolor,
    :minorhybridedgecolor,
    :defaultedgecolor,
    :showedgenumber,
    :shownodelabel,
    :edgelabel,
    :nodelabel,
    :xlim,
    :ylim,
    :tipoffset,
    :tipcex,
    :nodecex,
    :edgecex,
    :style,
    :arrowlen,
    :minorlinetype,
    :edgewidth,
    :edgenumbercolor,
    :edgelabelcolor,
    :nodelabelcolor,
    :edgelabeladj,
    :nodelabeladj,
    :preorder,
)

const DEFERRED_PLOT_KEYWORD_CONTRACTS = (
    DeferredKeywordContract(
        :edgelabel_public_surface_proof,
        :edgelabel,
        5,
        :deferred_to_tranche_5,
        "Helper-level edge-label validation, warning parity, and midpoint placement closed in tranche 3; direct public entry-surface proof remains tranche-5-owned.",
    ),
    DeferredKeywordContract(
        :nodelabel_public_surface_proof,
        :nodelabel,
        5,
        :deferred_to_tranche_5,
        "Helper-level node-label validation and warning parity closed in tranche 3; direct public entry-surface proof remains tranche-5-owned.",
    ),
    DeferredKeywordContract(
        :xlim_public_surface_proof,
        :xlim,
        5,
        :deferred_to_tranche_5,
        "Structural override validation and helper-level default-bounds message parity closed in tranche 3; direct public entry-surface proof remains tranche-5-owned.",
    ),
    DeferredKeywordContract(
        :ylim_public_surface_proof,
        :ylim,
        5,
        :deferred_to_tranche_5,
        "Structural override validation and helper-level default-bounds message parity closed in tranche 3; direct public entry-surface proof remains tranche-5-owned.",
    ),
)

const KEYWORD_SURFACE_CONTRACT = (
    KeywordSurfaceContractEntry(
        :useedgelength,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :showtiplabel,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :shownodenumber,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :showedgelength,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :showgamma,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :edgecolor,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :majorhybridedgecolor,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :minorhybridedgecolor,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :defaultedgecolor,
        "Upstream runtime fallback policy in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :showedgenumber,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :shownodelabel,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :edgelabel,
        "Upstream keyword signature DataFrame default in PhyloPlots.plot.",
        :helper_validation_closed_public_surface_proof_deferred,
        5,
        (:edgelabel_public_surface_proof,),
    ),
    KeywordSurfaceContractEntry(
        :nodelabel,
        "Upstream keyword signature DataFrame default in PhyloPlots.plot.",
        :helper_validation_closed_public_surface_proof_deferred,
        5,
        (:nodelabel_public_surface_proof,),
    ),
    KeywordSurfaceContractEntry(
        :xlim,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :structural_validation_closed_helper_message_closed_public_surface_proof_deferred,
        5,
        (:xlim_public_surface_proof,),
    ),
    KeywordSurfaceContractEntry(
        :ylim,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :structural_validation_closed_helper_message_closed_public_surface_proof_deferred,
        5,
        (:ylim_public_surface_proof,),
    ),
    KeywordSurfaceContractEntry(
        :tipoffset,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :tipcex,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :nodecex,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :edgecex,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :style,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :arrowlen,
        "Upstream style-dependent keyword default expression in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :minorlinetype,
        "Upstream style-dependent runtime fallback policy in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :edgewidth,
        "Upstream scalar-versus-dict runtime policy in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :edgenumbercolor,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :edgelabelcolor,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :nodelabelcolor,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :edgelabeladj,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :nodelabeladj,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
    KeywordSurfaceContractEntry(
        :preorder,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :closed_in_tranche_2,
        nothing,
        (),
    ),
)
