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
    accepted_design_scenarios = (
        simple_tree_no_hybrid = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 6,
            required_output = "Renders without error; no hybrid-edge drawing code is invoked.",
        ),
        single_reticulation_gamma = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 6,
            required_output = "Major and minor hybrid edges are visible in distinct colors, and the minor edge has an arrow tip.",
        ),
        style_distinction_fulltree_vs_majortree = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 4,
            required_output = "The full-tree style and major-tree style remain visually distinct.",
        ),
        useedgelength_scaling = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 3,
            required_output = "Node x positions follow edge lengths, and missing lengths render as 1.0.",
        ),
        dataframe_label_rendering = (
            source = "design/prod01-vision-supplement.md",
            direct_proof_owner = 3,
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
            artifact = "Tranche-1 shell-owner, verification-owner, and fixture-corpus tests pass.",
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
            artifact = "Documenter renders the source-backed verification-foundation page.",
            command = "julia --project=docs docs/make.jl",
        ),
    ),
    current_red_state = (
        (
            id = :test_project_manifest_repro,
            status = :tranche_start_repro,
            fact = "At tranche start, `julia --project=test test/runtests.jl` failed before running tests because the repo-local PhyloMakie dependency was missing from `test/Manifest.toml`.",
        ),
        (
            id = :empty_module_shell,
            status = :tranche_start_repro,
            fact = "`src/PhyloMakie.jl` was an empty placeholder shell with no includes and no source-side verification owner.",
        ),
        (
            id = :missing_fixture_owner,
            status = :tranche_start_repro,
            fact = "The repository had no canonical fixture corpus for design scenarios or upstream helper regressions.",
        ),
        (
            id = :missing_target_surface_matrix,
            status = :tranche_start_repro,
            fact = "No source-owned matrix recorded `phyloplot`, `phyloplot!`, and `plot(net)` as deferred target public surfaces.",
        ),
        (
            id = :boilerplate_only_tests,
            status = :tranche_start_repro,
            fact = "Aqua and JET were the only automated proof surfaces for plotting work.",
        ),
        (
            id = :boilerplate_only_docs,
            status = :tranche_start_repro,
            fact = "The docs home page was still the Documenter boilerplate landing page with no verification-foundation page.",
        ),
        (
            id = :target_surfaces_still_deferred,
            status = :intentional_tranche_1_state,
            fact = "The plotting entry surfaces remain intentionally unimplemented in tranche 1 and stay recorded as deferred proof obligations.",
        ),
    ),
    stop_conditions = (
        (
            id = :would_require_plotting_logic,
            condition = "Stop if keeping the verification owner green would require recipe, keyword, layout, annotation, or render implementation.",
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
            condition = "Stop if project-owner approval to execute tranche 1 is absent from the current run context.",
        ),
    ),
)
