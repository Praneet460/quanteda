#' Plot a network of feature co-occurrences
#'
#' Plot an \link{fcm} object as a network, where edges show co-occurrences of
#' features.
#' @param x a \link{fcm} or \link{dfm}  object
#' @param min_freq a frequency count threshold or proportion for co-occurrence
#'   frequencies of features to be included.
#' @param omit_isolated if \code{TRUE}, features do not occur more frequent than
#'   \code{min_freq} will be omitted.
#' @param edge_color color of edges that connect vertices.
#' @param edge_alpha opacity of edges ranging from 0 to 1.0.
#' @param edge_size size of edges for most frequent co-occurrence The size of
#'   other edges are determined proportionally to the 99th percentile frequency
#'   instead of the maximum to reduce the impact of outliers.
#' @param vertex_size size of vertices.
#' @param vertex_color color of vertices.
#' @param vertex_labelcolor color of texts. Defaults to the same as
#'   \code{vertex_color}. If \code{NA} is given, texts are not rendered.
#' @param offset if \code{NULL}, the distance between vertices and texts are
#'   determined automatically.
#' @param vertex_labelfont font-family of texts. Use default font if
#'   \code{NULL}.
#' @param ... additional arguments passed to \link[network]{network} or
#'   \link[igraph]{graph_from_adjacency_matrix}.  Not used for \code{as.igraph}.
#' @details Currently the size of the network is limited to 1000, because of the
#'   computationally intensive nature of network formation for larger matrices.
#'   When the \link{fcm} is large, users should select features using
#'   \link{fcm_select}, set the threshold using \code{min_freq}, or implement
#'   own plotting function using \code{\link[=as.network.fcm]{as.network}}.
#' @author Kohei Watanabe and Stefan Müller
#' @examples
#' toks <- corpus_subset(data_corpus_irishbudget2010) %>%
#'     tokens(remove_punct = TRUE) %>%
#'     tokens_tolower() %>%
#'     tokens_remove(stopwords("english"), padding = FALSE)
#' myfcm <- fcm(toks, context = "window", tri = FALSE)
#' feat <- names(topfeatures(myfcm, 30))
#' fcm_select(myfcm, feat, verbose = FALSE) %>% 
#'     textplot_network(min_freq = 0.5)
#' fcm_select(myfcm, feat, verbose = FALSE) %>% 
#'     textplot_network(min_freq = 0.8)
#' fcm_select(myfcm, feat, verbose = FALSE) %>%
#'     textplot_network(min_freq = 0.8, vertex_labelcolor = rep(c('gray40', NA), 15))
#' @export
#' @seealso \code{\link{fcm}}
#' @import ggplot2 
#' @keywords textplot
textplot_network <- function(x, min_freq = 0.5, omit_isolated = TRUE, 
                             edge_color = "#1F78B4", edge_alpha = 0.5, 
                             edge_size = 2, 
                             vertex_color = "#4D4D4D", vertex_size = 2,
                             vertex_labelcolor = NULL,
                             vertex_labelfont = NULL, 
                             offset = NULL, ...) {
    UseMethod("textplot_network")
}

#' @export
textplot_network.dfm <- function(x, min_freq = 0.5, omit_isolated = TRUE, 
                                 edge_color = "#1F78B4", edge_alpha = 0.5, 
                                 edge_size = 2, 
                                 vertex_color = "#4D4D4D", vertex_size = 2,
                                 vertex_labelcolor = NULL,
                                 vertex_labelfont = NULL, 
                                 offset = NULL, ...) {
    
    if (!sum(x)) stop(message_error("dfm_empty"))
    textplot_network(fcm(x), min_freq = min_freq, omit_isolated = omit_isolated, 
                     edge_color = edge_color, edge_alpha = edge_alpha, 
                     edge_size = edge_size, 
                     vertex_color = vertex_color, vertex_size = vertex_size,
                     vertex_labelcolor = vertex_labelcolor,
                     vertex_labelfont = vertex_labelfont, 
                     offset = NULL, ...)
}

    
#' @export
textplot_network.fcm <- function(x, min_freq = 0.5, omit_isolated = TRUE, 
                                 edge_color = "#1F78B4", edge_alpha = 0.5, 
                                 edge_size = 2, 
                                 vertex_color = "#4D4D4D", vertex_size = 2,
                                 vertex_labelcolor = NULL,
                                 vertex_labelfont = NULL, 
                                 offset = NULL, 
                                 ...) {
    
    if (!sum(x)) stop(message_error("fcm_empty"))
    font <- check_font(vertex_labelfont)
    net <- as.network(x, min_freq = min_freq, omit_isolated = omit_isolated, ...)

    vertex <- data.frame(sna::gplot.layout.fruchtermanreingold(net, NULL))
    colnames(vertex) <- c("x", "y")
    vertex$label <- network::network.vertex.names(net)

    weight <- network::get.edge.attribute(net, "weight")
    weight <- weight / quantile(weight, 0.99)
    #weight <- weight / mean(tail(sort(weight), 10))
    
    index <- network::as.edgelist(net)
    edge <- data.frame(x1 = vertex[,1][index[,1]], 
                       y1 = vertex[,2][index[,1]],
                       x2 = vertex[,1][index[,2]], 
                       y2 = vertex[,2][index[,2]],
                       weight = weight)
    
    if (is.null(vertex_labelcolor))
        vertex_labelcolor <- vertex_color
    
    # drop colors of omitted vertices
    l <- featnames(x) %in% network::network.vertex.names(net)
    if (length(vertex_labelcolor) > 1) vertex_labelcolor <- vertex_labelcolor[l]
    if (length(vertex_color) > 1) vertex_color <- vertex_color[l]
    if (length(vertex_size) > 1) vertex_size <- vertex_size[l]
    
    edge$color <- edge_color
    edge$alpha <- edge_alpha
    edge$size <- edge_size
    vertex$color <- vertex_color
    vertex$size <- vertex_size
    vertex$labelcolor <- vertex_labelcolor
    
    plot_network(edge, vertex, font, offset)
}



# as.network ----------

#' redefinition of network::as.network()
#' @param x input object
#' @param ... additional arguments
#' @keywords internal
#' @export 
as.network <- function(x, ...) {
    UseMethod("as.network")
}

#' @export
as.network.default <- function(x, ...) {
    network::as.network(x, ...)
}

#' @rdname textplot_network
#' @method as.network fcm
#' @export
#' @seealso \code{\link[network]{network}}
as.network.fcm <- function(x, min_freq = 0.5, omit_isolated = TRUE, ...) {
    
    if (nfeat(x) > 1000) stop('fcm is too large for a network plot')
    f <- x@margin
    x <- remove_edges(x, min_freq, omit_isolated)
    x <- network::network(as.matrix(x), matrix.type = "adjacency", directed = FALSE, 
                          ignore.eval = FALSE, names.eval = "weight", ...)
    network::set.vertex.attribute(x, "frequency", f[network::network.vertex.names(x)])
}

#' summary.character method to override the network::summary.character()
#' 
#' Necessary to prevent the \pkg{network} package's \code{summary.character} method 
#' from causing inconsistent behaviour with other summary methods.
#' @param object the character input
#' @param ... for additional passing of arguments to default method
#' @keywords internal
#' @method summary character
#' @export
summary.character <- function(object, ...) {
    base::summary.default(object, ...)
}

# as.igraph ----------

#' Convert an fcm to an igraph object
#' 
#' Convert an \link{fcm} object to an \pkg{igraph} graph object.
#' @keywords internal
#' @export 
as.igraph <- function(x, ...) UseMethod("as.igraph")

#' @rdname textplot_network
#' @method as.igraph fcm
#' @export
#' @seealso \code{\link[igraph]{graph_from_adjacency_matrix}}
#' @examples
#' 
#' # as.igraph
#' if (requireNamespace("igraph", quietly = TRUE)) {
#'     txt <- c("a a a b b c", "a a c e", "a c e f g")
#'     mat <- fcm(txt)
#'     as.igraph(mat, min_freq = 1, omit_isolated = FALSE)
#' }
as.igraph.fcm <- function(x, min_freq = 0.5, omit_isolated = TRUE, ...) {
    f <- x@margin
    x <- remove_edges(x, min_freq, omit_isolated)
    x <- igraph::graph_from_adjacency_matrix(x, ...)
    igraph::set_vertex_attr(x, "frequency", value = f[igraph::vertex_attr(x, "name")])
}

# internal ----------

remove_edges <- function(x, min_freq, omit_isolated) {
    
    Matrix::diag(x) <- 0
    x <- as(x, "dgTMatrix")
    
    # drop weak edges
    if (min_freq > 0) {
        if (min_freq < 1) {
            min_freq <- quantile(x@x, min_freq)
        }
        l <- x@x >= min_freq
        x@i <- x@i[l]
        x@j <- x@j[l]
        x@x <- x@x[l]
    }
    
    # drop isolated vertices 
    if (omit_isolated) {
        l <- colSums(x) != 0 | rowSums(x) != 0
        x <- x[l, l, drop = FALSE]
    }
    
    if (length(x@x) == 0 || all(x@x == 0))
        stop("There is no co-occurence higher than the threshold")
    
    return(x)
}

plot_network <- function(edge, vertex, font, offset) {
    
    label <- x1 <- x2 <- y <- y1 <- y2 <- NULL
    
    plot <- ggplot() + 
        geom_curve(data = edge, aes(x = x1, y = y1, xend = x2, yend = y2), 
                   color = edge$color, curvature = 0.2, 
                   alpha = edge$alpha, lineend = "round",
                   size = edge$weight * edge$size,
                   angle = 90) + 
        geom_point(data = vertex, aes(x, y), color = vertex$color, 
                   size = vertex$size, shape = 19)
    
    if (is.null(offset)) {
        plot <- plot + 
            ggrepel::geom_text_repel(data = vertex, 
                                     aes(x, y, label = label),
                                     segment.color = vertex$color, 
                                     segment.size = 0.2,
                                     color = vertex$labelcolor,
                                     family = font)
    } else {
        plot <- plot + 
            geom_text(data = vertex, aes(x, y, label = label),
                      nudge_y = offset, 
                      color = vertex$labelcolor,
                      family = font)
    }
    
    plot <- plot + 
        scale_x_continuous(breaks = NULL) + 
        scale_y_continuous(breaks = NULL) +
        theme_void(base_family = font) + 
        theme(
            plot.margin = margin(0, 0, 0, 0),
            panel.background = element_blank(), 
            axis.title.x = element_blank(), 
            axis.title.y = element_blank(),
            legend.position = "none",
            panel.grid.minor = element_blank(), 
            panel.grid.major = element_blank())
    
    return(plot)
}
