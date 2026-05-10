@testset "Verification foundation" begin
    foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)

    @test foundation isa NamedTuple
    @test isimmutable(foundation)
    @test propertynames(foundation) == (
        :target_public_surfaces,
        :lock_items,
        :keyword_owner,
        :layout_annotation_owner,
        :render_owner,
        :accepted_design_scenarios,
        :upstream_helper_regressions,
        :green_state_gates,
        :current_status,
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
        @test owner.render_consumer.owner_tranche == 4
        @test owner.render_consumer.owner ==
            "render_plot!(ax, net, spec, layout)::PlotRenderLayers"
        @test owner.render_consumer.source_file == "src/render_adapter.jl"
        @test owner.deferred_public_surface_proof.owner_tranche == 5
        @test owner.reviewer_gate.clear isa String
        @test owner.reviewer_gate.reject isa String
    end

    @testset "Render owner" begin
        owner = foundation.render_owner

        @test owner.source_files == ("src/render_adapter.jl",)
        @test owner.supporting_types == (
            "SegmentRenderLayer",
            "ArrowTipRenderLayer",
            "TextRenderLayer",
            "PlotRenderLayers",
        )
        @test owner.typed_layer_bundle == "PlotRenderLayers"
        @test owner.regression_suites == (
            "test/support/render_test_helpers.jl",
            "test/test_render_adapter.jl",
        )
        @test endswith(
            owner.source_set_note,
            "04-01_tranche-04--makie-source-set.md",
        )
        @test owner.primitive_entrypoints == (
            "linesegments!",
            "arrows2d!",
            "text!",
            "Makie.colorbuffer",
        )
        @test any(endswith("src/recipes.jl"), owner.makie_source_files)
        @test any(endswith("src/figureplotting.jl"), owner.makie_source_files)
        @test any(endswith("src/basic_recipes/arrows.jl"), owner.makie_source_files)
        @test any(endswith("src/basic_recipes/text.jl"), owner.makie_source_files)
        @test any(endswith("src/display.jl"), owner.makie_source_files)
        @test any(endswith("src/screen.jl"), owner.makie_source_files)
        @test owner.closed_render_regressions == (
            :style_distinction_fulltree_vs_majortree,
            :minorlinetype_numeric_dotted_rendering,
            :minorlinetype_blank_hides_minor_edges,
            :edgecolor_dict_fallback,
            :gamma_color_policy,
            :text_cex_scope_policy,
            :vector_text_cex_rendering,
            :tip_label_rendering,
            :internal_node_name_rendering,
            :node_number_rendering,
            :node_label_rendering,
            :edge_label_rendering,
            :edge_length_rendering,
            :edge_number_rendering,
            :explicit_limit_application,
        )
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
        @test foundation.accepted_design_scenarios.simple_tree_no_hybrid.closure_status ==
            :closed_render_owner
        @test foundation.accepted_design_scenarios.edgecolor_dict_fallback.closure_status ==
            :closed_render_owner
        @test foundation.accepted_design_scenarios.composable_dual_axes.direct_proof_owner == 5
        @test foundation.accepted_design_scenarios.composable_dual_axes.closure_status ==
            :deferred_public_surface_proof
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
        @test propertynames(FIXTURE_CORPUS.render_regression_cases) == (
            :style_fulltree,
            :style_majortree,
            :gamma_and_edgecolor,
            :annotation_and_limits,
        )
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
        @test FIXTURE_CORPUS.render_regression_cases.gamma_and_edgecolor.defaultedgecolor ==
            "black"
        @test FIXTURE_CORPUS.render_regression_cases.annotation_and_limits.xlim == (0.0, 6.5)
    end

    @testset "Green gates and current status" begin
        @test [gate.id for gate in foundation.green_state_gates] == [
            :root_makie_activation,
            :test_makie_activation,
            :docs_makie_activation,
            :package_tests,
            :aqua,
            :jet,
            :docs_build,
        ]
        @test [state.id for state in foundation.current_status] == [
            :dependency_activation_closed,
            :render_owner_closed,
            :render_verification_closed,
            :target_surfaces_still_deferred,
        ]
        @test foundation.current_status[end].status == :intentional_current_state
    end

    @testset "Stop conditions" begin
        @test [stop_condition.id for stop_condition in foundation.stop_conditions] == [
            :would_require_public_entry_surface,
            :helper_owner_regression,
            :source_set_drift_from_ratified_note,
            :docs_truth_boundary_violation,
            :render_proof_degenerates_to_text_policing,
        ]
    end
end
