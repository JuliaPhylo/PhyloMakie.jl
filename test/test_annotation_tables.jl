using DataFrames: DataFrame
using PhyloNetworks

function _annotation_fixture_dataframe(table_fixture)
    return DataFrame(
        [column => [row[column] for row in table_fixture.rows] for column in table_fixture.columns]...,
    )
end

@testset "Annotation table computation" begin
    PlotExtent = getfield(PhyloMakie, :PlotExtent)
    AnnotationTables = getfield(PhyloMakie, :AnnotationTables)
    LayoutComputation = getfield(PhyloMakie, :LayoutComputation)
    prepare_plot_network = getfield(PhyloMakie, :prepare_plot_network)
    compute_network_geometry = getfield(PhyloMakie, :compute_network_geometry)
    compute_layout = getfield(PhyloMakie, :compute_layout)
    resolve_plot_config = getfield(PhyloMakie, :resolve_plot_config)
    table_expectations = FIXTURE_CORPUS.table_expectations
    base_newick = FIXTURE_CORPUS.accepted_design_scenarios.dataframe_label_rendering.newick

    @testset "Computed node and edge annotation tables match accepted data" begin
        node_labels = _annotation_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_render_rows)
        edge_labels = _annotation_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_filtered_rows)
        node_plot_network = prepare_plot_network(readnewick(base_newick))
        node_config = resolve_plot_config(
            nodelabel=node_labels,
            shownodenumber=true,
            shownodelabel=true,
        )
        node_geometry = compute_network_geometry(node_plot_network, node_config)
        node_layout = compute_layout(node_plot_network, node_config, node_geometry)

        @test node_layout isa LayoutComputation
        @test node_layout.extent isa PlotExtent
        @test node_layout.annotations isa AnnotationTables
        @test node_layout.annotations.labelnodes === true
        @test node_layout.annotations.node_data == _annotation_fixture_dataframe(table_expectations.prepared_node_table)

        edge_plot_network = prepare_plot_network(readnewick(base_newick))
        edge_config = resolve_plot_config(edgelabel=edge_labels, style=:majortree)
        edge_geometry = compute_network_geometry(edge_plot_network, edge_config)
        edge_layout = compute_layout(edge_plot_network, edge_config, edge_geometry)

        @test edge_layout.annotations.labeledges === true
        @test edge_layout.annotations.edge_data == _annotation_fixture_dataframe(table_expectations.prepared_edge_table_majortree)
        @test edge_layout.extent.xlim_error_message == table_expectations.helper_bounds_messages.xlim
        @test edge_layout.extent.ylim_error_message == table_expectations.helper_bounds_messages.ylim
    end

    @testset "Warnings remain on annotation validation owner" begin
        warning_strings = FIXTURE_CORPUS.warning_strings
        warning_edges = _annotation_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_warning_rows)
        plot_network = prepare_plot_network(readnewick(base_newick))
        config = resolve_plot_config(edgelabel=warning_edges, style=:majortree)
        geometry = compute_network_geometry(plot_network, config)
        layout = @test_logs (:warn, warning_strings.edgelabel_unknown_edges) compute_layout(
            plot_network,
            config,
            geometry,
        )
        @test layout.annotations.labeledges === true
    end
end
