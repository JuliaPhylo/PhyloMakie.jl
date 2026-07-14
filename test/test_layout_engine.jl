using PhyloNetworks

function _geometry_tuple(geometry)
    return (
        geometry.edge_x_lo,
        geometry.edge_x_hi,
        geometry.edge_y_lo,
        geometry.edge_y_hi,
        geometry.node_x,
        geometry.node_y,
        geometry.node_y_lo,
        geometry.node_y_hi,
        geometry.arrow_x_lo,
        geometry.arrow_x_hi,
        geometry.arrow_y_lo,
        geometry.arrow_y_hi,
        geometry.xmin,
        geometry.xmax,
        geometry.ymin,
        geometry.ymax,
    )
end

function _read_network(newick::AbstractString)
    return readnewick(newick)
end

function _capture_stdout(f::Function)
    return mktemp() do _, io
        value = redirect_stdout(io) do
            f()
        end
        flush(io)
        seekstart(io)
        return value, read(io, String)
    end
end

@testset "Layout engine" begin
    resolve_phylo_plot_attributes = getfield(PhyloMakie, :resolve_phylo_plot_attributes)
    layout_plot_geometry = getfield(PhyloMakie, :layout_plot_geometry)
    layout_cases = FIXTURE_CORPUS.layout_regression_cases

    @testset "Computed coordinates match expected values" begin
        for case_name in (
            :with_lengths_fulltree,
            :with_lengths_majortree,
            :without_lengths_majortree,
            :level2_with_gamma,
            :level2_without_gamma,
        )
            layout_case = getproperty(layout_cases, case_name)
            network = _read_network(layout_case.newick)
            attributes = resolve_phylo_plot_attributes(; layout_case.attribute_kwargs...)
            geometry = layout_plot_geometry(network, attributes; preorder=true)
            @test _geometry_tuple(geometry) == layout_case.expected
        end
    end

    @testset "Mixed missing edge lengths warning path" begin
        layout_case = layout_cases.mixed_missing_lengths_warning
        network = _read_network(layout_case.newick)
        for edge_number in layout_case.missing_edge_numbers
            edge_index = findfirst(edge -> edge.number == edge_number, network.edge)
            @test !isnothing(edge_index)
            network.edge[edge_index].length = -1.0
        end
        attributes = resolve_phylo_plot_attributes(; layout_case.attribute_kwargs...)
        geometry = @test_logs (:warn, layout_case.expected_warning) layout_plot_geometry(
            network,
            attributes;
            preorder=true,
        )

        comparison_network = _read_network(layout_case.newick)
        for edge_number in layout_case.missing_edge_numbers
            edge_index = findfirst(edge -> edge.number == edge_number, comparison_network.edge)
            @test !isnothing(edge_index)
            comparison_network.edge[edge_index].length = 1.0
        end
        comparison_geometry = layout_plot_geometry(comparison_network, attributes; preorder=true)
        @test _geometry_tuple(geometry) == _geometry_tuple(comparison_geometry)
    end

    @testset "All-missing fallback parity" begin
        layout_case = layout_cases.all_missing_lengths_fulltree_fallback
        network = _read_network(layout_case.newick)
        attributes = resolve_phylo_plot_attributes(; layout_case.attribute_kwargs...)
        geometry, stdout_text = _capture_stdout() do
            layout_plot_geometry(network, attributes; preorder=true)
        end
        @test rstrip(stdout_text) == layout_case.expected_print
        @test _geometry_tuple(geometry) == layout_case.expected

        no_lengths_attributes =
            resolve_phylo_plot_attributes(useedgelength=false, style=:fulltree)
        no_lengths_geometry = layout_plot_geometry(
            _read_network(layout_case.newick),
            no_lengths_attributes;
            preorder=true,
        )
        @test _geometry_tuple(geometry) != _geometry_tuple(no_lengths_geometry)
    end

    @testset "Root index mismatch raises RootMismatch error" begin
        layout_case = layout_cases.incompatible_root
        network = _read_network(layout_case.newick)
        network.rooti = layout_case.rooti
        attributes = resolve_phylo_plot_attributes(; layout_case.attribute_kwargs...)
        caught_error = try
            layout_plot_geometry(network, attributes; preorder=true)
            nothing
        catch err
            err
        end
        @test caught_error isa PhyloNetworks.RootMismatch
        @test caught_error.msg == layout_case.expected_error_message
    end

    @testset "Layout output is identical whether preorder runs internally or is pre-run by the caller" begin
        layout_case = layout_cases.with_lengths_fulltree
        fresh_network = _read_network(layout_case.newick)
        original_preorder_from_fresh = [node.number for node in fresh_network.vec_node]
        original_edge_direction_from_fresh = [edge.ischild1 for edge in fresh_network.edge]
        original_containroot_from_fresh = [edge.containroot for edge in fresh_network.edge]
        original_isrooted_from_fresh = fresh_network.isrooted
        attributes = resolve_phylo_plot_attributes(; layout_case.attribute_kwargs...)
        prepared_by_owner = layout_plot_geometry(
            fresh_network,
            attributes;
            preorder=true,
        )
        @test fresh_network.isrooted === original_isrooted_from_fresh
        @test [node.number for node in fresh_network.vec_node] == original_preorder_from_fresh
        @test [edge.ischild1 for edge in fresh_network.edge] == original_edge_direction_from_fresh
        @test [edge.containroot for edge in fresh_network.edge] == original_containroot_from_fresh

        prepared_network = _read_network(layout_case.newick)
        PhyloNetworks.directedges!(prepared_network)
        PhyloNetworks.preorder!(prepared_network)
        original_preorder = [node.number for node in prepared_network.vec_node]
        original_edge_direction = [edge.ischild1 for edge in prepared_network.edge]
        geometry_without_repreorder = layout_plot_geometry(
            prepared_network,
            attributes;
            preorder=false,
        )
        @test _geometry_tuple(prepared_by_owner) == _geometry_tuple(geometry_without_repreorder)
        @test [node.number for node in prepared_network.vec_node] == original_preorder
        @test [edge.ischild1 for edge in prepared_network.edge] == original_edge_direction
        @test _geometry_tuple(geometry_without_repreorder) == layout_case.expected
    end
end
