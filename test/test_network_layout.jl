using PhyloNetworks

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

@testset "Network layout computation" begin
    PlotNetwork = getfield(PhyloMakie, :PlotNetwork)
    NetworkGeometry = getfield(PhyloMakie, :NetworkGeometry)
    prepare_plot_network = getfield(PhyloMakie, :prepare_plot_network)
    compute_network_geometry = getfield(PhyloMakie, :compute_network_geometry)
    resolve_plot_config = getfield(PhyloMakie, :resolve_plot_config)
    layout_cases = FIXTURE_CORPUS.layout_regression_cases

    @testset "Prepared network is caller-safe" begin
        layout_case = layout_cases.with_lengths_fulltree
        network = readnewick(layout_case.newick)
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
            network = readnewick(layout_case.newick)
            plot_network = prepare_plot_network(network)
            config = resolve_plot_config(; layout_case.attribute_kwargs...)
            geometry = compute_network_geometry(plot_network, config)

            @test geometry isa NetworkGeometry
            @test _network_geometry_tuple(geometry) == layout_case.expected
            @test _plot_network_snapshot(network).preorder_numbers == Int[]
        end
    end

    @testset "Traversal errors remain honest" begin
        layout_case = layout_cases.incompatible_root
        network = readnewick(layout_case.newick)
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
end
