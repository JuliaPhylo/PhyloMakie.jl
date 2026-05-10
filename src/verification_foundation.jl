const VERIFICATION_FOUNDATION = (
    target_public_surfaces = (
        (
            id = :phyloplot,
            public_name = "phyloplot",
            implemented = false,
            direct_proof_deferred = true,
            direct_proof_owner = 5,
            docs_visibility = :target_not_yet_implemented,
            input_type = "PhyloNetworks.HybridNetwork",
            return_contract = "Makie.FigureAxisPlot",
        ),
        (
            id = :phyloplot_bang,
            public_name = "phyloplot!",
            implemented = false,
            direct_proof_deferred = true,
            direct_proof_owner = 5,
            docs_visibility = :target_not_yet_implemented,
            input_type = "PhyloNetworks.HybridNetwork",
            return_contract = "Plot object on an existing Makie axis-like owner",
        ),
        (
            id = :plot_net,
            public_name = "plot(net)",
            implemented = false,
            direct_proof_deferred = true,
            direct_proof_owner = 5,
            docs_visibility = :target_not_yet_implemented,
            input_type = "PhyloNetworks.HybridNetwork",
            return_contract = "Makie.FigureAxisPlot via Makie dispatch",
        ),
    ),
    lock_items = (
        (number = 1, title = "Entry surfaces and return contract"),
        (number = 2, title = "Public keyword-surface parity"),
        (number = 3, title = "Layout-owner parity"),
        (number = 4, title = "Style distinction and hybrid-edge rendering"),
        (number = 5, title = "Annotation and DataFrame validation parity"),
        (number = 6, title = "Composable Makie plotting"),
        (number = 7, title = "Honest verification surface"),
    ),
    keyword_owner = (
        source_files = (
            "src/keyword_contract.jl",
            "src/keyword_normalization.jl",
        ),
        supported_plot_keywords = SUPPORTED_PLOT_KEYWORDS,
        target_public_surfaces = (
            "phyloplot",
            "phyloplot!",
            "plot(net)",
        ),
        deferred_contracts = DEFERRED_PLOT_KEYWORD_CONTRACTS,
        reviewer_gate = (
            clear = "the canonical keyword owner exists, direct keyword regressions pass, malformed explicit xlim and ylim overrides are rejected structurally at the keyword-owner boundary, helper-level annotation validation and bounds-message contracts are closed in the layout and annotation owners, and the remaining direct public entry-surface proofs stay explicit in source, tests, and docs.",
            reject = "it reopens helper-level annotation or bounds ownership in the keyword layer, falsely marks tranche-5 direct public proof closed, or leaves the deferred direct-public boundary implicit.",
        ),
    ),
    layout_annotation_owner = (
        source_files = (
            "src/layout_engine.jl",
            "src/annotation_data.jl",
        ),
        supporting_types = (
            "PlotGeometry",
            "PlotBounds",
            "PlotAnnotationData",
        ),
        canonical_payload = "PlotLayout",
        regression_suites = (
            "test/test_layout_engine.jl",
            "test/test_annotation_data.jl",
        ),
        closed_helper_regressions = (
            :edgenode_coords_with_lengths_fulltree,
            :edgenode_coords_with_lengths_majortree,
            :edgenode_coords_without_lengths_majortree,
            :level2_network_with_gamma,
            :level2_network_without_gamma,
            :mixed_missing_lengths_warning,
            :all_missing_lengths_fulltree_fallback,
            :incompatible_root,
            :preorder_mutation_boundary,
            :nodelabel_validation_and_prep,
            :edgelabel_validation_and_prep,
            :major_tree_minor_edge_midpoint,
            :helper_bounds_messages,
        ),
        deferred_render_proof = (
            owner_tranche = 4,
            contracts = (
                "Render-level style distinction, hybrid-edge visibility, gamma text, and color semantics via the Makie render adapter.",
                "Render-time proof that plotted annotations consume PlotLayout without geometry or midpoint recomputation.",
            ),
        ),
        deferred_public_surface_proof = (
            owner_tranche = 5,
            contracts = (
                "Direct public proof for phyloplot.",
                "Direct public proof for phyloplot!.",
                "Direct Makie dispatch proof for plot(net).",
                "Direct public xlim and ylim error-path proof through the plotting entry surfaces.",
            ),
        ),
        reviewer_gate = (
            clear = "src/layout_engine.jl and src/annotation_data.jl remain the only helper owners, exact geometry and annotation regressions pass locally, PlotLayout remains the canonical helper payload, and render-level plus direct public-surface proof stays deferred explicitly to tranches 4 and 5.",
            reject = "it reimplements geometry, midpoint, or helper-bounds semantics in render-facing code, leaves the canonical helper payload implicit, or falsely marks render or direct public entry-surface proof closed.",
        ),
    ),
    accepted_design_scenarios = (
        simple_tree_no_hybrid = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 4,
            required_output = "Renders without error; no hybrid-edge drawing code is invoked.",
        ),
        single_reticulation_gamma = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 4,
            required_output = "Major and minor hybrid edges are visible in distinct colors, and the minor edge has an arrow tip.",
        ),
        style_distinction_fulltree_vs_majortree = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 4,
            required_output = "The full-tree style and major-tree style remain visually distinct.",
        ),
        useedgelength_scaling = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 4,
            required_output = "Node x positions follow edge lengths, and missing lengths render as 1.0.",
        ),
        dataframe_label_rendering = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 4,
            required_output = "Node and edge labels render at the correct midpoint anchors after validation.",
        ),
        showgamma_rendering = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 4,
            required_output = "Hybrid-edge gamma text renders with the correct major and minor color semantics.",
        ),
        edgecolor_dict_fallback = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 4,
            required_output = "Mapped edges use the provided colors and unmapped edges fall back to the default edge color.",
        ),
        composable_dual_axes = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 5,
            required_output = "Two networks render into separate axes without coordinate bleed-through.",
        ),
    ),
    upstream_helper_regressions = (
        edgenode_coords_with_lengths_fulltree = (
            source = "PhyloPlots.jl/test/test_phylonetworkPlots.jl",
            proof_owner = 3,
            helper_owner = "PhyloPlots.edgenode_coordinates",
        ),
        edgenode_coords_with_lengths_majortree = (
            source = "PhyloPlots.jl/test/test_phylonetworkPlots.jl",
            proof_owner = 3,
            helper_owner = "PhyloPlots.edgenode_coordinates",
        ),
        edgenode_coords_without_lengths_majortree = (
            source = "PhyloPlots.jl/test/test_phylonetworkPlots.jl",
            proof_owner = 3,
            helper_owner = "PhyloPlots.edgenode_coordinates",
        ),
        nodelabel_validation_and_prep = (
            source = "PhyloPlots.jl/test/test_phylonetworkPlots.jl",
            proof_owner = 3,
            helper_owner = "PhyloPlots.check_nodedataframe / prepare_nodedataframe",
        ),
        edgelabel_validation_and_prep = (
            source = "PhyloPlots.jl/test/test_phylonetworkPlots.jl",
            proof_owner = 3,
            helper_owner = "PhyloPlots.prepare_edgedataframe",
        ),
        level2_network_with_gamma = (
            source = "PhyloPlots.jl/test/test_phylonetworkPlots.jl",
            proof_owner = 3,
            helper_owner = "PhyloPlots.edgenode_coordinates",
        ),
        level2_network_without_gamma = (
            source = "PhyloPlots.jl/test/test_phylonetworkPlots.jl",
            proof_owner = 3,
            helper_owner = "PhyloPlots.edgenode_coordinates",
        ),
    ),
    green_state_gates = (
        (
            id = :test_project_runnable,
            artifact = "Repo-local test project resolves the direct PhyloMakie dependency and executes test/runtests.jl.",
            command = "julia --project=test test/runtests.jl",
        ),
        (
            id = :package_tests,
            artifact = "Shell-owner, keyword-owner, layout-owner, annotation-owner, and verification-owner tests pass together under the repo-local test project.",
            command = "julia --project=test test/runtests.jl",
        ),
        (
            id = :aqua,
            artifact = "Aqua remains supplemental proof inside the test suite.",
            command = "Aqua.test_all(PhyloMakie)",
        ),
        (
            id = :jet,
            artifact = "JET remains supplemental proof inside the test suite.",
            command = "JET.test_package(PhyloMakie; target_modules = (PhyloMakie,))",
        ),
        (
            id = :docs_build,
            artifact = "Documenter renders the source-backed verification-foundation page, including the tranche-3 layout and annotation owner block and the deferred proof boundary.",
            command = "julia --project=docs docs/make.jl",
        ),
    ),
    current_red_state = (
        (
            id = :partial_tranche_3_shell_owner_drift,
            status = :remediation_start_repro,
            fact = "On 2026-05-10, `test/test_PhyloMakie.jl` still expected the old three-include module shell and failed once the tranche-3 owners landed in `src/`.",
        ),
        (
            id = :partial_tranche_3_dependency_drift,
            status = :remediation_start_repro,
            fact = "On 2026-05-10, Aqua reported a missing `PhyloNetworks` compat entry and the docs build failed until the repo-local dependency state was re-resolved.",
        ),
        (
            id = :partial_tranche_3_jet_branch_gap,
            status = :remediation_start_repro,
            fact = "On 2026-05-10, JET reported that `child_y` might be undefined in the `usedirecthybridline` branch of `src/layout_engine.jl`.",
        ),
        (
            id = :partial_tranche_3_missing_helper_proof_suites,
            status = :remediation_start_repro,
            fact = "At remediation start, no local layout or annotation regression suites owned exact geometry tuples, fallback warnings, midpoint placement, or helper-level bounds messages.",
        ),
        (
            id = :partial_tranche_3_stale_truth_surface,
            status = :remediation_start_repro,
            fact = "At remediation start, `src/keyword_contract.jl`, `src/verification_foundation.jl`, `docs/src/verification-foundation.md`, and `docs/src/index.md` still described the repository as a tranche-1 or tranche-2 state instead of a tranche-3 helper-owner closeout.",
        ),
        (
            id = :target_surfaces_still_deferred,
            status = :intentional_current_state,
            fact = "The plotting entry surfaces remain intentionally unimplemented after tranche 3; render-level proof is deferred to tranche 4 and direct public entry-surface proof remains deferred to tranche 5.",
        ),
    ),
    stop_conditions = (
        (
            id = :would_require_plotting_logic,
            condition = "Stop if tranche-3 closeout would require implementing public plotting entrypoints, recipe code, or render adapter logic.",
        ),
        (
            id = :fixture_corpus_requires_r_behavior,
            condition = "Stop if the fixture corpus cannot be encoded as dependency-light Julia literals without importing out-of-scope R behavior.",
        ),
        (
            id = :target_surface_drift_from_prose_only,
            condition = "Stop if later tranches would still need to infer target public surfaces or scenario identifiers from workflow prose alone.",
        ),
        (
            id = :docs_truth_boundary_violation,
            condition = "Stop if the docs would need to claim implemented plotting behavior to stay green.",
        ),
        (
            id = :approval_gate_unrecorded,
            condition = "Stop if project-owner approval to execute the tranche-3 remediation is absent from the current run context.",
        ),
    ),
)
