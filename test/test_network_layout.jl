function _plot_network_snapshot(net::HybridNetwork)
    return (
        rooti=net.rooti,
        isrooted=net.isrooted,
        preorder_numbers=[node.number for node in net.vec_node],
        edge_state=[
            (
                number=edge.number,
                parent=PhyloNetworks.getparent(edge).number,
                child=PhyloNetworks.getchild(edge).number,
                ischild1=edge.ischild1,
                containroot=edge.containroot,
            ) for edge in net.edge
        ],
    )
end

function _network_geometry_tuple(geometry)
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

@testset "Network layout computation" begin
    PlotNetwork = getfield(PhyloMakie, :PlotNetwork)
    NetworkGeometry = getfield(PhyloMakie, :NetworkGeometry)
    prepare_plot_network = getfield(PhyloMakie, :prepare_plot_network)
    compute_network_geometry = getfield(PhyloMakie, :compute_network_geometry)
    resolve_plot_config = getfield(PhyloMakie, :resolve_plot_config)
    layout_cases = FIXTURE_CORPUS.layout_regression_cases

    @testset "Prepared network is caller-safe" begin
        layout_case = layout_cases.with_lengths_fulltree
        network = only(parsenetwork(NewickFormat(), layout_case.newick))
        before = _plot_network_snapshot(network)
        plot_network = prepare_plot_network(network)

        @test plot_network isa PlotNetwork
        @test plot_network.net !== network
        @test _plot_network_snapshot(network) == before
        @test plot_network.net.isrooted === true
        @test !isempty(plot_network.net.vec_node)
    end

    @testset "Geometry matches accepted fixture coordinates" begin
        for case_name in (
            :with_lengths_fulltree,
            :with_lengths_majortree,
            :without_lengths_majortree,
            :level2_with_gamma,
            :level2_without_gamma,
        )
            layout_case = getproperty(layout_cases, case_name)
            network = only(parsenetwork(NewickFormat(), layout_case.newick))
            plot_network = prepare_plot_network(network)
            config = resolve_plot_config(; layout_case.attribute_kwargs...)
            geometry = compute_network_geometry(plot_network, config)

            @test geometry isa NetworkGeometry
            @test _network_geometry_tuple(geometry) == layout_case.expected
            @test _plot_network_snapshot(network).preorder_numbers == Int[]
        end
    end

    @testset "Mixed missing edge lengths warn and use fallback length" begin
        layout_case = layout_cases.mixed_missing_lengths_warning
        network = only(parsenetwork(NewickFormat(), layout_case.newick))
        for edge_number in layout_case.missing_edge_numbers
            edge_index = findfirst(edge -> edge.number == edge_number, network.edge)
            @test !isnothing(edge_index)
            network.edge[edge_index].length = -1.0
        end
        config = resolve_plot_config(; layout_case.attribute_kwargs...)
        geometry = @test_logs (:warn, layout_case.expected_warning) compute_network_geometry(
            prepare_plot_network(network),
            config,
        )

        comparison_network = only(parsenetwork(NewickFormat(), layout_case.newick))
        for edge_number in layout_case.missing_edge_numbers
            edge_index = findfirst(edge -> edge.number == edge_number, comparison_network.edge)
            @test !isnothing(edge_index)
            comparison_network.edge[edge_index].length = 1.0
        end
        comparison_geometry = compute_network_geometry(
            prepare_plot_network(comparison_network),
            config,
        )
        @test _network_geometry_tuple(geometry) == _network_geometry_tuple(comparison_geometry)
    end

    @testset "All-missing edge lengths print fallback notice" begin
        layout_case = layout_cases.all_missing_lengths_fulltree_fallback
        config = resolve_plot_config(; layout_case.attribute_kwargs...)
        geometry, stdout_text = _capture_stdout() do
            compute_network_geometry(
                prepare_plot_network(only(parsenetwork(NewickFormat(), layout_case.newick))),
                config,
            )
        end
        @test rstrip(stdout_text) == layout_case.expected_print
        @test _network_geometry_tuple(geometry) == layout_case.expected

        no_lengths_geometry = compute_network_geometry(
            prepare_plot_network(only(parsenetwork(NewickFormat(), layout_case.newick))),
            resolve_plot_config(useedgelength=false, style=:fulltree),
        )
        @test _network_geometry_tuple(geometry) != _network_geometry_tuple(no_lengths_geometry)
    end

    @testset "Traversal errors remain honest" begin
        layout_case = layout_cases.incompatible_root
        network = only(parsenetwork(NewickFormat(), layout_case.newick))
        network.rooti = layout_case.rooti
        caught_error = try
            prepare_plot_network(network)
            nothing
        catch err
            err
        end
        @test caught_error isa PhyloNetworks.RootMismatch
        @test caught_error.msg == layout_case.expected_error_message
    end

    @testset "Already-prepared caller network is not mutated" begin
        layout_case = layout_cases.with_lengths_fulltree
        fresh_network = only(parsenetwork(NewickFormat(), layout_case.newick))
        fresh_geometry = compute_network_geometry(
            prepare_plot_network(fresh_network),
            resolve_plot_config(; layout_case.attribute_kwargs...),
        )

        prepared_network = only(parsenetwork(NewickFormat(), layout_case.newick))
        PhyloNetworks.directedges!(prepared_network)
        PhyloNetworks.preorder!(prepared_network)
        before = _plot_network_snapshot(prepared_network)
        prepared_geometry = compute_network_geometry(
            prepare_plot_network(prepared_network),
            resolve_plot_config(; layout_case.attribute_kwargs...),
        )

        @test _plot_network_snapshot(prepared_network) == before
        @test _network_geometry_tuple(prepared_geometry) ==
            _network_geometry_tuple(fresh_geometry)
        @test _network_geometry_tuple(prepared_geometry) == layout_case.expected
    end
end
