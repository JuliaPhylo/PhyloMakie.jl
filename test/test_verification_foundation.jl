@testset "Verification foundation" begin
    foundation = getfield(PhyloMakie, :VERIFICATION_FOUNDATION)

    @test foundation isa NamedTuple
    @test isimmutable(foundation)
    @test propertynames(foundation) == (
        :target_public_surfaces,
        :lock_items,
        :public_attribute_owner,
        :layout_annotation_owner,
        :render_owner,
        :public_plot_owner,
        :package_truth_surfaces,
        :accepted_design_scenarios,
        :upstream_helper_regressions,
        :green_state_gates,
        :current_status,
        :stop_conditions,
    )

    @testset "Target public surfaces" begin
        @test length(foundation.target_public_surfaces) == 4
        @test [surface.public_name for surface in foundation.target_public_surfaces] == [
            "phyloplot",
            "phyloplot!",
            "plot(net)",
            "plot!(ax, net)",
        ]

        for surface in foundation.target_public_surfaces
            @test surface.implemented === true
            @test surface.proof_owner == :test_public_plot_owner
            @test surface.proof_artifact == "test/test_public_plot_owner.jl"
        end

        @test foundation.target_public_surfaces[1].docs_visibility ==
            :documented_convenience_surface
        @test foundation.target_public_surfaces[3].docs_visibility ==
            :documented_primary_surface
    end

    @testset "Lock items" begin
        @test length(foundation.lock_items) == 4
        @test [item.number for item in foundation.lock_items] == [2, 5, 6, 7]
        @test [item.title for item in foundation.lock_items] == [
            "Capability parity without API mimicry",
            "Makie composability and host-framework semantics",
            "Honest docs and migration surface",
            "Honest verification surface",
        ]
    end

    @testset "Public attribute owner" begin
        owner = foundation.public_attribute_owner

        @test owner.source_files == ("src/public_attribute_model.jl",)
        @test owner.canonical_payload == "PhyloPlotAttributes"
        @test owner.supported_public_attributes == EXPECTED_SUPPORTED_PHYLOPLOT_ATTRIBUTES
        @test owner.recipe_attribute_surface == "Makie.attribute_names(PhyloPlot)"
        @test owner.runtime_consumers == (
            "prepare_plot_layout(net, attributes; preorder=true)::PlotLayout",
            "render_plot!(target, net, attributes, layout)::PlotRenderLayers",
            "Makie.plot!(plot::PhyloPlot)",
        )
        @test owner.legacy_rejection.source ==
            "Makie.deprecated_attributes(::Type{<:PhyloPlot})"
        @test owner.legacy_rejection.rejected_spellings ==
            EXPECTED_DEPRECATED_PHYLOPLOT_ATTRIBUTES
        @test occursin("omits separate controls", owner.omitted_control_note)
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
            "render_plot!(target, net, attributes, layout)::PlotRenderLayers"
        @test owner.render_consumer.source_file == "src/render_adapter.jl"
        @test owner.public_surface_consumer.owner_tranche == 5
        @test owner.public_surface_consumer.owner == "Makie.plot!(plot::PhyloPlot)"
        @test owner.public_surface_consumer.source_file == "src/public_plot_owner.jl"
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
        @test endswith(owner.source_set_note, "04-01_tranche-04--makie-source-set.md")
        @test owner.primitive_entrypoints == (
            "linesegments!",
            "arrows2d!",
            "text!",
            "Makie.colorbuffer",
        )
        @test owner.public_owner_reuse.owner_tranche == 5
        @test owner.public_owner_reuse.owner == "Makie.plot!(plot::PhyloPlot)"
        @test occursin("Axis and Plot targets", owner.public_owner_reuse.contract)
        @test any(endswith("src/recipes.jl"), owner.makie_source_files)
        @test any(endswith("src/figureplotting.jl"), owner.makie_source_files)
        @test any(endswith("src/basic_recipes/arrows.jl"), owner.makie_source_files)
        @test any(endswith("src/basic_recipes/text.jl"), owner.makie_source_files)
        @test any(endswith("src/display.jl"), owner.makie_source_files)
        @test any(endswith("src/screen.jl"), owner.makie_source_files)
        @test owner.closed_render_regressions == (
            :style_distinction_fulltree_vs_majortree,
            :minor_edge_linestyle_numeric_dotted_rendering,
            :minor_edge_linestyle_blank_hides_minor_edges,
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

    @testset "Public plot owner" begin
        owner = foundation.public_plot_owner

        @test owner.source_files == ("src/public_plot_owner.jl",)
        @test owner.public_recipe == "Makie.@recipe PhyloPlot (net,) begin ... end"
        @test owner.makie_dispatch == (
            "Makie.plottype(::PhyloNetworks.HybridNetwork) = PhyloPlot",
            "Makie.plot!(plot::PhyloPlot)",
        )
        @test owner.supported_surfaces == (
            "plot(net)",
            "plot!(ax, net)",
            "phyloplot",
            "phyloplot!",
        )
        @test owner.stored_artifacts == (
            "resolved_attributes",
            "resolved_layout",
            "render_layers",
            "data_limits",
        )
        @test owner.direct_proof_suites == (
            "test/test_PhyloMakie.jl",
            "test/test_public_attribute_model.jl",
            "test/test_public_plot_owner.jl",
        )
        @test owner.caller_owned_network_boundary ==
            "deepcopy(Makie.to_value(plot[:net]))"
        @test owner.reviewer_gate.clear isa String
        @test owner.reviewer_gate.reject isa String
    end

    @testset "Package truth surfaces" begin
        @test [surface.id for surface in foundation.package_truth_surfaces] == [
            :readme,
            :home,
            :public_api,
            :migration_guide,
            :verification_foundation,
            :render_verification,
        ]
        @test [surface.path for surface in foundation.package_truth_surfaces] == [
            "README.md",
            "docs/src/index.md",
            "docs/src/public-api.md",
            "docs/src/migration-guide.md",
            "docs/src/verification-foundation.md",
            "docs/src/render-verification.md",
        ]
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
        for scenario in values(foundation.accepted_design_scenarios)
            @test scenario.proof_owner == :test_public_plot_owner
            @test scenario.proof_artifact == "test/test_public_plot_owner.jl"
            @test scenario.docs_proof_surface in (
                "docs/src/public-api.md",
                "docs/src/render-verification.md",
            )
            @test scenario.migration_label isa String
            @test scenario.public_surface isa String
            @test scenario.migration_guidance isa String
        end
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
        @test FIXTURE_CORPUS.render_regression_cases.gamma_and_edgecolor.default_edge_color ==
            "black"
        @test FIXTURE_CORPUS.render_regression_cases.annotation_and_limits.x_limits ==
            (0.0, 6.5)
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
            :public_entry_surfaces_live,
            :runtime_carrier_live,
            :package_tests_green,
            :docs_build_green,
            :docs_and_migration_surface_closed,
            :verification_surface_closed,
        ]
        @test [state.status for state in foundation.current_status] == [
            :verified_on_2026_05_10,
            :verified_on_2026_05_10,
            :verified_on_2026_05_10,
            :verified_on_2026_05_10,
            :closed_in_tranche_7,
            :closed_in_tranche_7,
        ]
    end

    @testset "Stop conditions" begin
        @test [stop_condition.id for stop_condition in foundation.stop_conditions] == [
            :legacy_names_needed_for_docs_closure,
            :api_broadening_needed_for_docs_closure,
            :post_tranche_6_baseline_missing,
            :proof_collapses_to_text_policing,
        ]
    end
end
