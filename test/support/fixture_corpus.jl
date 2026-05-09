const FIXTURE_CORPUS = (
    accepted_design_scenarios = (
        simple_tree_no_hybrid = (
            newick = "(A,((B,C),(D,E)));",
            required_output = "Renders without error; no hybrid-edge drawing code is invoked.",
            expected_helper_regression_ids = (),
        ),
        single_reticulation_gamma = (
            newick = "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
            required_output = "Major and minor hybrid edges are visible in distinct colors, and the minor edge has an arrow tip.",
            expected_helper_regression_ids = (:edgenode_coords_with_lengths_fulltree,),
        ),
        style_distinction_fulltree_vs_majortree = (
            newick = "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
            required_output = "The full-tree style and major-tree style remain visually distinct.",
            expected_helper_regression_ids = (
                :edgenode_coords_with_lengths_fulltree,
                :edgenode_coords_with_lengths_majortree,
            ),
        ),
        useedgelength_scaling = (
            newick = "(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);",
            required_output = "Node x positions follow edge lengths, and missing lengths render as 1.0.",
            expected_helper_regression_ids = (
                :edgenode_coords_with_lengths_fulltree,
                :edgenode_coords_with_lengths_majortree,
                :edgenode_coords_without_lengths_majortree,
            ),
        ),
        dataframe_label_rendering = (
            newick = "(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);",
            required_output = "Node and edge labels render at the correct midpoint anchors after validation.",
            expected_helper_regression_ids = (
                :nodelabel_validation_and_prep,
                :edgelabel_validation_and_prep,
            ),
        ),
        showgamma_rendering = (
            newick = "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
            required_output = "Hybrid-edge gamma text renders with the correct major and minor color semantics.",
            expected_helper_regression_ids = (
                :level2_network_with_gamma,
                :level2_network_without_gamma,
            ),
        ),
        edgecolor_dict_fallback = (
            newick = "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
            edgecolor_overrides = ((1, "tomato4"), (3, "tan"), (7, "skyblue")),
            defaultedgecolor = "black",
            required_output = "Mapped edges use the provided colors and unmapped edges fall back to the default edge color.",
            expected_helper_regression_ids = (),
        ),
        composable_dual_axes = (
            newicks = (
                "(((A:.2,(B:.1)#H1:.1::0.9):.1,(C:.11,#H1:.01::0.1):.19):.1,D:.4);",
                "(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);",
            ),
            required_output = "Two networks render into separate axes without coordinate bleed-through.",
            expected_helper_regression_ids = (),
        ),
    ),
    upstream_helper_regressions = (
        edgenode_coords_with_lengths_fulltree = (
            newick = "(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);",
            useedgelength = true,
            usedirecthybridline = false,
        ),
        edgenode_coords_with_lengths_majortree = (
            newick = "(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);",
            useedgelength = true,
            usedirecthybridline = true,
        ),
        edgenode_coords_without_lengths_majortree = (
            newick = "(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);",
            useedgelength = false,
            usedirecthybridline = true,
        ),
        nodelabel_validation_and_prep = (
            newick = "(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);",
            warning_ids = (:nodelabel_unknown_nodes, :nodelabel_invalid_shape),
        ),
        edgelabel_validation_and_prep = (
            newick = "(A:2.5,((B:1,#H1:0.5::0.1):1,(C:1,(D:0.5)#H1:0.5::0.9):1):0.5);",
            warning_ids = (:edgelabel_unknown_edges, :edgelabel_invalid_shape),
        ),
        level2_network_with_gamma = (
            newick = "((((B)#H1:::0.2)#H2,((D,C,#H2:::0.8)S1,(#H1,A)S2)S3)S4);",
            showgamma = true,
        ),
        level2_network_without_gamma = (
            newick = "((((B)#H1:::0.2)#H2,((D,C,#H2)S1,(#H1,A)S2)S3)S4);",
            showgamma = true,
        ),
    ),
    annotation_rows = (
        nodelabel_warning_rows = (
            columns = (:node, :bs, :edge),
            rows = (
                (node = -5, bs = "90", edge = 8),
                (node = -3, bs = "95", edge = 9),
                (node = -4, bs = "99", edge = 4),
                (node = 5, bs = "mytip", edge = 6),
                (node = 100, bs = "bogus", edge = 200),
            ),
        ),
        nodelabel_filtered_rows = (
            columns = (:node, :bs, :edge),
            rows = (
                (node = -5, bs = "90", edge = 8),
                (node = -3, bs = "95", edge = 9),
                (node = missing, bs = "99", edge = 4),
                (node = 5, bs = "mytip", edge = 6),
            ),
        ),
        nodelabel_render_rows = (
            columns = (:node, :bs),
            rows = (
                (node = -5, bs = "90"),
                (node = -3, bs = "95"),
                (node = -4, bs = "99"),
                (node = 5, bs = "mytips"),
            ),
        ),
        edgelabel_warning_rows = (
            columns = (:edge, :bs),
            rows = (
                (edge = 8, bs = "90"),
                (edge = 9, bs = "95"),
                (edge = 4, bs = "99"),
                (edge = 6, bs = "mytips"),
                (edge = 200, bs = "bogus"),
            ),
        ),
        edgelabel_filtered_rows = (
            columns = (:edge, :bs),
            rows = (
                (edge = 8, bs = missing),
                (edge = 9, bs = "95"),
                (edge = 4, bs = "99"),
                (edge = 6, bs = "mytips"),
            ),
        ),
    ),
    warning_strings = (
        nodelabel_unknown_nodes = "Some node numbers in the nodelabel data frame are not found in the network:\n 100",
        nodelabel_invalid_shape = "nodelabel should have 2+ columns, the first one giving the node numbers (Integer)",
        edgelabel_unknown_edges = "Some edge numbers in the edgelabel data frame are not found in the network:\n 200",
        edgelabel_invalid_shape = "edgelabel should have 2+ columns, the first one giving the edge numbers (Integer)",
    ),
)
