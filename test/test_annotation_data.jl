using DataFrames: DataFrame
using PhyloNetworks

function _fixture_dataframe(table_fixture)
    return DataFrame(
        [column => [row[column] for row in table_fixture.rows] for column in table_fixture.columns]...,
    )
end

function _read_annotation_network(newick::AbstractString)
    return readnewick(newick)
end

@testset "Annotation data owner" begin
    normalize_plot_keywords = getfield(PhyloMakie, :normalize_plot_keywords)
    prepare_plot_layout = getfield(PhyloMakie, :prepare_plot_layout)
    validate_node_data = getfield(PhyloMakie, :_validate_node_data)
    table_expectations = FIXTURE_CORPUS.table_expectations
    warning_strings = FIXTURE_CORPUS.warning_strings
    base_newick = FIXTURE_CORPUS.accepted_design_scenarios.dataframe_label_rendering.newick

    @testset "Node-label validation" begin
        network = _read_annotation_network(base_newick)
        warning_input = _fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_warning_rows)
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

        filtered_input = _fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_filtered_rows)
        labelnodes_filtered, filtered_result = validate_node_data(network, filtered_input)
        @test labelnodes_filtered === true
        @test filtered_result == _fixture_dataframe(table_expectations.nodelabel_filtered_result)
    end

    @testset "Prepared node table" begin
        node_labels = _fixture_dataframe(FIXTURE_CORPUS.annotation_rows.nodelabel_render_rows)
        layout = prepare_plot_layout(
            _read_annotation_network(base_newick),
            normalize_plot_keywords(
                nodelabel=node_labels,
                shownodenumber=true,
                shownodelabel=true,
            ),
        )
        @test layout.annotations.labelnodes === true
        @test layout.annotations.node_data == _fixture_dataframe(table_expectations.prepared_node_table)
    end

    @testset "Edge-label validation" begin
        warning_edges = _fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_warning_rows)
        layout_with_warning = @test_logs (:warn, warning_strings.edgelabel_unknown_edges) prepare_plot_layout(
            _read_annotation_network(base_newick),
            normalize_plot_keywords(edgelabel=warning_edges, style=:majortree),
        )
        @test layout_with_warning.annotations.labeledges === true

        invalid_edges = warning_edges[!, 2:2]
        invalid_layout = @test_logs (:warn, warning_strings.edgelabel_invalid_shape) prepare_plot_layout(
            _read_annotation_network(base_newick),
            normalize_plot_keywords(edgelabel=invalid_edges, style=:majortree),
        )
        @test invalid_layout.annotations.labeledges === false
        @test all(invalid_layout.annotations.edge_data.lab .== "")

        filtered_edge_numbers = _fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_missing_number_rows)
        filtered_layout = prepare_plot_layout(
            _read_annotation_network(base_newick),
            normalize_plot_keywords(edgelabel=filtered_edge_numbers, style=:majortree),
        )
        expected_filtered = _fixture_dataframe(table_expectations.edgelabel_filtered_result)
        for row_index in axes(expected_filtered, 1)
            edge_number = string(expected_filtered[row_index, :edge])
            expected_label = expected_filtered[row_index, :bs]
            actual_row = only(findall(filtered_layout.annotations.edge_data.num .== edge_number))
            @test filtered_layout.annotations.edge_data[actual_row, :lab] == expected_label
        end
        missing_label_row = only(findall(filtered_layout.annotations.edge_data.num .== "4"))
        @test filtered_layout.annotations.edge_data[missing_label_row, :lab] == ""
    end

    @testset "Prepared edge table and helper-level bounds" begin
        edge_labels = _fixture_dataframe(FIXTURE_CORPUS.annotation_rows.edgelabel_filtered_rows)
        layout = prepare_plot_layout(
            _read_annotation_network(base_newick),
            normalize_plot_keywords(edgelabel=edge_labels, style=:majortree),
        )
        @test layout.annotations.labeledges === true
        @test layout.annotations.edge_data == _fixture_dataframe(table_expectations.prepared_edge_table_majortree)

        midpoint_expectation = table_expectations.major_tree_minor_edge_midpoint
        midpoint_row = only(findall(layout.annotations.edge_data.num .== midpoint_expectation.edge_number))
        @test layout.annotations.edge_data[midpoint_row, :x] == midpoint_expectation.x
        @test layout.annotations.edge_data[midpoint_row, :y] == midpoint_expectation.y

        @test layout.bounds.xlim_error_message == table_expectations.helper_bounds_messages.xlim
        @test layout.bounds.ylim_error_message == table_expectations.helper_bounds_messages.ylim
    end
end
