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
    validate_node_data = getfield(PhyloMakie, :_validate_node_data)
    table_expectations = FIXTURE_CORPUS.table_expectations
    warning_strings = FIXTURE_CORPUS.warning_strings
    base_newick = FIXTURE_CORPUS.accepted_design_scenarios.dataframe_label_rendering.newick

    function annotation_layout(; kwargs...)
        plot_network = prepare_plot_network(only(parsephylogeny(NewickFormat(), base_newick)))
        config = resolve_plot_config(; kwargs...)
        geometry = compute_network_geometry(plot_network, config)
        return compute_layout(plot_network, config, geometry)
    end

    @testset "Node-label validation keeps accepted warnings and filtering" begin
        network = only(parsephylogeny(NewickFormat(), base_newick))
        warning_input =
            _annotation_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_warning_rows)
        labelnodes, filtered = @test_logs (:warn, warning_strings.nodelabel_unknown_nodes) validate_node_data(
            network,
            warning_input,
        )
        @test labelnodes === true
        @test filtered == warning_input

        invalid_input = warning_input[!, 2:3]
        labelnodes_invalid, invalid_result = @test_logs (:warn, warning_strings.nodelabel_invalid_shape) validate_node_data(
            network,
            invalid_input,
        )
        @test labelnodes_invalid === false
        @test invalid_result == invalid_input

        filtered_input =
            _annotation_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_filtered_rows)
        labelnodes_filtered, filtered_result = validate_node_data(network, filtered_input)
        @test labelnodes_filtered === true
        @test filtered_result ==
            _annotation_fixture_dataframe(table_expectations.nodelabel_filtered_result)
    end

    @testset "Computed node and edge annotation tables match accepted data" begin
        node_labels = _annotation_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_render_rows)
        edge_labels = _annotation_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_filtered_rows)
        node_layout = annotation_layout(
            nodelabel=node_labels,
            shownodenumber=true,
            shownodelabel=true,
        )

        @test node_layout isa LayoutComputation
        @test node_layout.extent isa PlotExtent
        @test node_layout.annotations isa AnnotationTables
        @test node_layout.annotations.labelnodes === true
        @test node_layout.annotations.node_data == _annotation_fixture_dataframe(table_expectations.prepared_node_table)

        edge_layout = annotation_layout(edgelabel=edge_labels, style=:majortree)

        @test edge_layout.annotations.labeledges === true
        @test edge_layout.annotations.edge_data == _annotation_fixture_dataframe(table_expectations.prepared_edge_table_majortree)
        @test edge_layout.extent.xlim_error_message == table_expectations.helper_bounds_messages.xlim
        @test edge_layout.extent.ylim_error_message == table_expectations.helper_bounds_messages.ylim

        midpoint_expectation = table_expectations.major_tree_minor_edge_midpoint
        midpoint_row = only(findall(edge_layout.annotations.edge_data.num .== midpoint_expectation.edge_number))
        @test edge_layout.annotations.edge_data[midpoint_row, :x] == midpoint_expectation.x
        @test edge_layout.annotations.edge_data[midpoint_row, :y] == midpoint_expectation.y
    end

    @testset "Warnings remain on annotation validation owner" begin
        warning_edges = _annotation_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_warning_rows)
        layout = @test_logs (:warn, warning_strings.edgelabel_unknown_edges) annotation_layout(
            edgelabel=warning_edges,
            style=:majortree,
        )
        @test layout.annotations.labeledges === true

        invalid_edges = warning_edges[!, 2:2]
        invalid_layout = @test_logs (:warn, warning_strings.edgelabel_invalid_shape) annotation_layout(
            edgelabel=invalid_edges,
            style=:majortree,
        )
        @test invalid_layout.annotations.labeledges === false
        @test all(invalid_layout.annotations.edge_data.lab .== "")
    end

    @testset "Edge labels with missing numbers keep accepted filtering" begin
        filtered_edge_numbers =
            _annotation_fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_missing_number_rows)
        filtered_layout = annotation_layout(edgelabel=filtered_edge_numbers, style=:majortree)
        expected_filtered =
            _annotation_fixture_dataframe(table_expectations.edgelabel_filtered_result)
        for row_index in axes(expected_filtered, 1)
            edge_number = string(expected_filtered[row_index, :edge])
            expected_label = expected_filtered[row_index, :bs]
            actual_row = only(findall(filtered_layout.annotations.edge_data.num .== edge_number))
            @test filtered_layout.annotations.edge_data[actual_row, :lab] == expected_label
        end
        missing_label_row = only(findall(filtered_layout.annotations.edge_data.num .== "4"))
        @test filtered_layout.annotations.edge_data[missing_label_row, :lab] == ""
    end
end
