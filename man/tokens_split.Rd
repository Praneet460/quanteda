% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tokens_split.R
\name{tokens_split}
\alias{tokens_split}
\title{Split tokens by a separator pattern}
\usage{
tokens_split(x, separator = " ", valuetype = c("fixed", "regex"),
  remove_separator = TRUE)
}
\arguments{
\item{x}{a \link{tokens} object}

\item{separator}{a single-character pattern match by which tokens are separated}

\item{valuetype}{the type of pattern matching: \code{"glob"} for 
"glob"-style wildcard expressions; \code{"regex"} for regular expressions;
or \code{"fixed"} for exact matching. See \link{valuetype} for details.}

\item{remove_separator}{if \code{TRUE}, remove separator from new tokens}
}
\description{
Replaces tokens by multiple replacements consisting of elements split by a
separator pattern, with the option of retaining the separator.  This function
effectively reverses the operation of \code{\link{tokens_compound}}.
}
\examples{
# undo tokens_compound()
ctoks <- tokens("pork barrel is an idiomatic multi-word expression")
tokens_compound(ctoks, phrase("pork barrel"))
tokens_compound(ctoks, phrase("pork barrel")) \%>\%
    tokens_split(separator = "_")
    
# similar to tokens(x, remove_hyphen = TRUE) but post-tokenization 
toks <- tokens("UK-EU negotiation is not going anywhere as of 2018-12-24.")
tokens_split(toks, separator = "-", remove_separator = FALSE) 
}
