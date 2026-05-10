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
        :nodelabel_validation,
        :nodelabel,
        3,
        :deferred_to_tranche_3,
        "DataFrame row validation, warning parity, and midpoint preparation remain tranche-3-owned.",
    ),
    DeferredKeywordContract(
        :edgelabel_validation,
        :edgelabel,
        3,
        :deferred_to_tranche_3,
        "DataFrame row validation, warning parity, and midpoint preparation remain tranche-3-owned.",
    ),
    DeferredKeywordContract(
        :xlim_exact_message_parity,
        :xlim,
        3,
        :deferred_to_tranche_3,
        "Exact legacy error-message parity remains tranche-3-owned because it depends on layout-derived default bounds.",
    ),
    DeferredKeywordContract(
        :ylim_exact_message_parity,
        :ylim,
        3,
        :deferred_to_tranche_3,
        "Exact legacy error-message parity remains tranche-3-owned because it depends on layout-derived default bounds.",
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
        :normalization_closed_validation_deferred,
        3,
        (:edgelabel_validation,),
    ),
    KeywordSurfaceContractEntry(
        :nodelabel,
        "Upstream keyword signature DataFrame default in PhyloPlots.plot.",
        :normalization_closed_validation_deferred,
        3,
        (:nodelabel_validation,),
    ),
    KeywordSurfaceContractEntry(
        :xlim,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :structural_validation_closed_message_parity_deferred,
        3,
        (:xlim_exact_message_parity,),
    ),
    KeywordSurfaceContractEntry(
        :ylim,
        "Upstream keyword signature literal default in PhyloPlots.plot.",
        :structural_validation_closed_message_parity_deferred,
        3,
        (:ylim_exact_message_parity,),
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
