## Developer decisions


## Plot design

### Reactivity and interactivity

- The plot dynamically changes when `Makie.update!(plt.attributes, ...` are called with the following keyword arguments (each of these keyword arguments map by default to an input node on the compute graph):
    - `net::HybridNetwork`
    - `useedgelength`
    - `showtiplabel`
    - `shownodelabel`
    - `shownodenumber`
    - `showedgelength`
    - `showedgenumber`
    - `showgamma`
    - `edgecolor`
    - `defaultedgecolor`
    - `majorhybridedgecolor`
    - `minorhybridedgecolor`
    - `edgewidth`
    - `minorlinetype`
    - `arrowlen`
    - `nodelabel`
    - `edgelabel`
    - `nodecex`
    - `edgecex`
    - `nodelabelcolor`
    - `edgelabelcolor`
    - `edgenumbercolor`
    - `nodelabeladj`
    - `edgelabeladj`
    - `tipoffset`
    - `tipcex`
    - `xlim`
    - `ylim`
    - `style`

- The plot should react to mouse actions on the following elements:
    - Any edge
        - Hover:
        - Right-click:
        - Left-click:
        - Middle-click:
        - Right-click and drag:
    - Any node
        - Hover:
        - Right-click:
        - Left-click:
        - Middle-click:
        - Right-click and drag:
    - Any glyph or text element around the node