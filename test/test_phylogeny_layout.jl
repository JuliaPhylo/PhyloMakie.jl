function _phylogeny_geometry_tuple(geometry)
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

@testset "Phylogeny layout computation" begin
    PreparedPhylogeny = getfield(PhyloMakie, :PreparedPhylogeny)
    PhylogenyGeometry = getfield(PhyloMakie, :PhylogenyGeometry)
    prepare_for_layout = getfield(PhyloMakie, :prepare_for_layout)
    compute_phylogeny_geometry = getfield(PhyloMakie, :compute_phylogeny_geometry)
    resolve_plot_config = getfield(PhyloMakie, :resolve_plot_config)
    layout_cases = FIXTURE_CORPUS.layout_regression_cases

    @testset "Preparation is caller-safe and allocation-light" begin
        layout_case = layout_cases.with_lengths_fulltree
        phylogeny = parsephylogeny(NewickFormat(), layout_case.newick)
        before = _native_phylogeny_snapshot(phylogeny)
        prepared_phylogeny = prepare_for_layout(phylogeny)

        @test prepared_phylogeny isa PreparedPhylogeny
        @test prepared_phylogeny.phylogeny === phylogeny
        @test isequal(_native_phylogeny_snapshot(phylogeny), before)
        @test is_rooted(prepared_phylogeny.phylogeny)
        @test node_id.(prepared_phylogeny.preorder) == before.preorder
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
            phylogeny = parsephylogeny(NewickFormat(), layout_case.newick)
            before = _native_phylogeny_snapshot(phylogeny)
            prepared_phylogeny = prepare_for_layout(phylogeny)
            config = resolve_plot_config(; layout_case.attribute_kwargs...)
            geometry = compute_phylogeny_geometry(prepared_phylogeny, config)

            @test geometry isa PhylogenyGeometry
            @test _phylogeny_geometry_tuple(geometry) == layout_case.expected
            @test isequal(_native_phylogeny_snapshot(phylogeny), before)
        end
    end

    @testset "Layout accepts another AbstractPhylogeny implementation" begin
        phylogeny = parsephylogeny(NewickFormat(), "(A:1,(B:2,C:3):4);")
        interface_tree = InterfaceTestTree(phylogeny)
        config = resolve_plot_config(useedgelength = true, style = :fulltree)
        native_geometry = compute_phylogeny_geometry(prepare_for_layout(phylogeny), config)
        interface_geometry = compute_phylogeny_geometry(
            prepare_for_layout(interface_tree),
            config,
        )

        @test prepare_for_layout(interface_tree).phylogeny === interface_tree
        @test _phylogeny_geometry_tuple(interface_geometry) ==
            _phylogeny_geometry_tuple(native_geometry)
    end

    @testset "Mixed missing edge lengths warn and use fallback length" begin
        layout_case = layout_cases.mixed_missing_lengths_warning
        phylogeny = parsephylogeny(NewickFormat(), layout_case.newick)
        for edge_number in layout_case.missing_edge_numbers
            set_branch_length!(edge(phylogeny, edge_number, Val(:id)), missing)
        end
        config = resolve_plot_config(; layout_case.attribute_kwargs...)
        geometry = @test_logs (:warn, layout_case.expected_warning) compute_phylogeny_geometry(
            prepare_for_layout(phylogeny),
            config,
        )

        comparison_phylogeny = parsephylogeny(NewickFormat(), layout_case.newick)
        for edge_number in layout_case.missing_edge_numbers
            set_branch_length!(edge(comparison_phylogeny, edge_number, Val(:id)), 1.0)
        end
        comparison_geometry = compute_phylogeny_geometry(
            prepare_for_layout(comparison_phylogeny),
            config,
        )
        @test _phylogeny_geometry_tuple(geometry) == _phylogeny_geometry_tuple(comparison_geometry)
    end

    @testset "All-missing edge lengths print fallback notice" begin
        layout_case = layout_cases.all_missing_lengths_fulltree_fallback
        config = resolve_plot_config(; layout_case.attribute_kwargs...)
        geometry, stdout_text = _capture_stdout() do
            compute_phylogeny_geometry(
                prepare_for_layout(parsephylogeny(NewickFormat(), layout_case.newick)),
                config,
            )
        end
        @test rstrip(stdout_text) == layout_case.expected_print
        @test _phylogeny_geometry_tuple(geometry) == layout_case.expected

        no_lengths_geometry = compute_phylogeny_geometry(
            prepare_for_layout(parsephylogeny(NewickFormat(), layout_case.newick)),
            resolve_plot_config(useedgelength = false, style = :fulltree),
        )
        @test _phylogeny_geometry_tuple(geometry) != _phylogeny_geometry_tuple(no_lengths_geometry)
    end

    @testset "Inadmissible rerooting is transactional" begin
        layout_case = layout_cases.incompatible_root
        phylogeny = parsephylogeny(NewickFormat(), layout_case.newick)
        before = _native_phylogeny_snapshot(phylogeny)
        caught_error = try
            reroot!(phylogeny, node(phylogeny, layout_case.root_index))
            nothing
        catch error
            error
        end
        @test caught_error isa PhylogenyValidationError
        @test isequal(_native_phylogeny_snapshot(phylogeny), before)
    end

    @testset "Repeated preparation does not mutate the caller" begin
        layout_case = layout_cases.with_lengths_fulltree
        phylogeny = parsephylogeny(NewickFormat(), layout_case.newick)
        before = _native_phylogeny_snapshot(phylogeny)
        first_geometry = compute_phylogeny_geometry(
            prepare_for_layout(phylogeny),
            resolve_plot_config(; layout_case.attribute_kwargs...),
        )
        second_geometry = compute_phylogeny_geometry(
            prepare_for_layout(phylogeny),
            resolve_plot_config(; layout_case.attribute_kwargs...),
        )

        @test isequal(_native_phylogeny_snapshot(phylogeny), before)
        @test _phylogeny_geometry_tuple(second_geometry) ==
            _phylogeny_geometry_tuple(first_geometry)
        @test _phylogeny_geometry_tuple(second_geometry) == layout_case.expected
    end
end
