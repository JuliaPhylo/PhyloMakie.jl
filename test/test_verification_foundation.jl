@testset "Verification foundation" begin
    foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)

    @test foundation isa NamedTuple
    @test isimmutable(foundation)
    @test propertynames(foundation) == (
        :target_public_surfaces,
        :lock_items,
        :keyword_owner,
        :layout_annotation_owner,
        :accepted_design_scenarios,
        :upstream_helper_regressions,
        :green_state_gates,
        :current_red_state,
        :stop_conditions,
    )

    @testset "Target public surfaces" begin
        @test length(foundation.target_public_surfaces) == 3
        @test [surface.public_name for surface in foundation.target_public_surfaces] == [
            "phyloplot",
            "phyloplot!",
            "plot(net)",
        ]

        for surface in foundation.target_public_surfaces
            @test surface.implemented === false
            @test surface.direct_proof_deferred === true
            @test surface.direct_proof_owner == 5
            @test surface.docs_visibility == :target_not_yet_implemented
        end
    end

    @testset "Lock items" begin
        @test length(foundation.lock_items) == 7
        @test [item.number for item in foundation.lock_items] == collect(1:7)
        @test [item.title for item in foundation.lock_items] == [
            "Entry surfaces and return contract",
            "Public keyword-surface parity",
            "Layout-owner parity",
            "Style distinction and hybrid-edge rendering",
            "Annotation and DataFrame validation parity",
            "Composable Makie plotting",
            "Honest verification surface",
        ]
    end

    @testset "Keyword owner" begin
        owner = foundation.keyword_owner

        @test owner.source_files == (
            "src/keyword_contract.jl",
            "src/keyword_normalization.jl",
        )
        @test owner.supported_plot_keywords == EXPECTED_SUPPORTED_PLOT_KEYWORDS
        @test owner.target_public_surfaces == (
            "phyloplot",
            "phyloplot!",
            "plot(net)",
        )
        @test [contract.id for contract in owner.deferred_contracts] ==
            collect(EXPECTED_DEFERRED_PLOT_CONTRACT_IDS)
        @test owner.reviewer_gate.clear isa String
        @test owner.reviewer_gate.reject isa String
    end

    @testset "Layout and annotation owner" begin
        owner = foundation.layout_annotation_owner

        @test owner.source_files == (
            "src/layout_engine.jl",
            "src/annotation_data.jl",
        )
        @test owner.supporting_types == (
            "PlotGeometry",
            "PlotBounds",
            "PlotAnnotationData",
        )
        @test owner.canonical_payload == "PlotLayout"
        @test owner.regression_suites == (
            "test/test_layout_engine.jl",
            "test/test_annotation_data.jl",
        )
        @test owner.closed_helper_regressions == (
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
        )
        @test owner.deferred_render_proof.owner_tranche == 4
        @test owner.deferred_public_surface_proof.owner_tranche == 5
        @test owner.reviewer_gate.clear isa String
        @test owner.reviewer_gate.reject isa String
    end

    @testset "Scenario inventories" begin
        @test propertynames(foundation.accepted_design_scenarios) == (
            :simple_tree_no_hybrid,
            :single_reticulation_gamma,
            :style_distinction_fulltree_vs_majortree,
            :useedgelength_scaling,
            :dataframe_label_rendering,
            :showgamma_rendering,
            :edgecolor_dict_fallback,
            :composable_dual_axes,
        )
        @test foundation.accepted_design_scenarios.simple_tree_no_hybrid.direct_proof_owner == 4
        @test foundation.accepted_design_scenarios.single_reticulation_gamma.direct_proof_owner == 4
        @test foundation.accepted_design_scenarios.useedgelength_scaling.direct_proof_owner == 4
        @test foundation.accepted_design_scenarios.dataframe_label_rendering.direct_proof_owner == 4
        @test foundation.accepted_design_scenarios.composable_dual_axes.direct_proof_owner == 5
        @test propertynames(foundation.upstream_helper_regressions) == (
            :edgenode_coords_with_lengths_fulltree,
            :edgenode_coords_with_lengths_majortree,
            :edgenode_coords_without_lengths_majortree,
            :nodelabel_validation_and_prep,
            :edgelabel_validation_and_prep,
            :level2_network_with_gamma,
            :level2_network_without_gamma,
        )
    end

    @testset "Fixture corpus" begin
        @test propertynames(FIXTURE_CORPUS.accepted_design_scenarios) ==
            propertynames(foundation.accepted_design_scenarios)
        @test propertynames(FIXTURE_CORPUS.upstream_helper_regressions) ==
            propertynames(foundation.upstream_helper_regressions)
        @test propertynames(FIXTURE_CORPUS.layout_regression_cases) == (
            :with_lengths_fulltree,
            :with_lengths_majortree,
            :without_lengths_majortree,
            :level2_with_gamma,
            :level2_without_gamma,
            :all_missing_lengths_fulltree_fallback,
            :mixed_missing_lengths_warning,
            :incompatible_root,
        )
        @test propertynames(FIXTURE_CORPUS.table_expectations) == (
            :nodelabel_filtered_result,
            :edgelabel_filtered_result,
            :prepared_node_table,
            :prepared_edge_table_majortree,
            :major_tree_minor_edge_midpoint,
            :helper_bounds_messages,
        )

        @test FIXTURE_CORPUS.accepted_design_scenarios.simple_tree_no_hybrid.newick ==
            "(A,((B,C),(D,E)));"
        @test FIXTURE_CORPUS.accepted_design_scenarios.single_reticulation_gamma.newick ==
            "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);"
        @test FIXTURE_CORPUS.accepted_design_scenarios.composable_dual_axes.newicks[2] ==
            "(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);"

        @test FIXTURE_CORPUS.upstream_helper_regressions.level2_network_with_gamma.newick ==
            "((((B)#H1:::0.2)#H2,((D,C,#H2:::0.8)S1,(#H1,A)S2)S3)S4);"
        @test FIXTURE_CORPUS.upstream_helper_regressions.level2_network_without_gamma.newick ==
            "((((B)#H1:::0.2)#H2,((D,C,#H2)S1,(#H1,A)S2)S3)S4);"
        @test FIXTURE_CORPUS.layout_regression_cases.all_missing_lengths_fulltree_fallback.expected_print ==
            "All edge lengths are missing, won't be used for plotting."
        @test FIXTURE_CORPUS.layout_regression_cases.incompatible_root.rooti == 2

        @test FIXTURE_CORPUS.warning_strings.nodelabel_unknown_nodes ==
            "Some node numbers in the nodelabel data frame are not found in the network:\n 100"
        @test FIXTURE_CORPUS.warning_strings.nodelabel_invalid_shape ==
            "nodelabel should have 2+ columns, the first one giving the node numbers (Integer)"
        @test FIXTURE_CORPUS.warning_strings.edgelabel_unknown_edges ==
            "Some edge numbers in the edgelabel data frame are not found in the network:\n 200"
        @test FIXTURE_CORPUS.warning_strings.edgelabel_invalid_shape ==
            "edgelabel should have 2+ columns, the first one giving the edge numbers (Integer)"
        @test FIXTURE_CORPUS.warning_strings.mixed_missing_edge_lengths ==
            "At least one non-missing edge length: plotting any missing length as 1.0"

        @test length(FIXTURE_CORPUS.annotation_rows.nodelabel_warning_rows.rows) == 5
        @test length(FIXTURE_CORPUS.annotation_rows.edgelabel_filtered_rows.rows) == 4
    end

    @testset "Fake-green prevention" begin
        @test !isempty(foundation.green_state_gates)
        @test !isempty(foundation.current_red_state)
        @test !isempty(foundation.stop_conditions)
        @test [state.id for state in foundation.current_red_state] == [
            :partial_tranche_3_shell_owner_drift,
            :partial_tranche_3_dependency_drift,
            :partial_tranche_3_jet_branch_gap,
            :partial_tranche_3_missing_helper_proof_suites,
            :partial_tranche_3_stale_truth_surface,
            :target_surfaces_still_deferred,
        ]
        @test foundation.current_red_state[end].status == :intentional_current_state
    end
end
