% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tokens.R
\name{as.tokens}
\alias{as.tokens}
\alias{as.tokens.list}
\alias{as.tokens.spacyr_parsed}
\alias{as.list.tokens}
\alias{unlist.tokens}
\alias{as.character.tokens}
\alias{is.tokens}
\alias{+.tokens}
\alias{c.tokens}
\title{Coercion, checking, and combining functions for tokens objects}
\usage{
as.tokens(x, concatenator = "_", ...)

\method{as.tokens}{list}(x, concatenator = "_", ...)

\method{as.tokens}{spacyr_parsed}(x, concatenator = "/",
  include_pos = c("none", "pos", "tag"), use_lemma = FALSE, ...)

\method{as.list}{tokens}(x, ...)

\method{unlist}{tokens}(x, recursive = FALSE, use.names = TRUE)

\method{as.character}{tokens}(x, use.names = FALSE, ...)

is.tokens(x)

\method{+}{tokens}(t1, t2)

\method{c}{tokens}(...)
}
\arguments{
\item{x}{object to be coerced or checked}

\item{concatenator}{character between multi-word expressions, default is the
underscore character.  See Details.}

\item{...}{additional arguments used by specific methods.  For
\link{c.tokens}, these are the \link{tokens} objects to be concatenated.}

\item{include_pos}{character; whether and which part-of-speech tag to use:
\code{"none"} do not use any part of speech indicator, \code{"pos"} use the
\code{pos} variable, \code{"tag"} use the \code{tag} variable.  The POS
will be added to the token after \code{"concatenator"}.}

\item{use_lemma}{logical; if \code{TRUE}, use the lemma rather than the raw
token}

\item{recursive}{a required argument for \link{unlist} but inapplicable to
\link{tokens} objects}

\item{use.names}{logical; preserve names if \code{TRUE}.  For
\code{as.character} and \code{unlist} only.}

\item{t1}{tokens one to be added}

\item{t2}{tokens two to be added}
}
\value{
\code{as.tokens} returns a quanteda \link{tokens} object.

\code{as.list} returns a simple list of characters from a
  \link{tokens} object.

\code{unlist} returns a simple vector of characters from a 
  \link{tokens} object.

\code{as.character} returns a character vector from a 
  \link{tokens} object.

\code{is.tokens} returns \code{TRUE} if the object is of class
  tokens, \code{FALSE} otherwise.

\code{c(...)} and \code{+} return a tokens object whose documents
  have been added as a single sequence of documents.
}
\description{
Coercion functions to and from \link{tokens} objects, checks for whether an 
object is a \link{tokens} object, and functions to combine \link{tokens} 
objects.
}
\details{
The \code{concatenator} is used to automatically generate dictionary
  values for multi-word expressions in \code{\link{tokens_lookup}} and
  \code{\link{dfm_lookup}}. The underscore character is commonly used to join
  elements of multi-word expressions (e.g. "piece_of_cake", "New_York"), but
  other characters (e.g. whitespace " " or a hyphen "-") can also be used. 
  In those cases, users have to tell the system what is the concatenator in 
  your tokens so that the conversion knows to treat this character as the
  inter-word delimiter, when reading in the elements that will become the
  tokens.
}
\examples{

# create tokens object from list of characters with custom concatenator
dict <- dictionary(list(country = "United States", 
                   sea = c("Atlantic Ocean", "Pacific Ocean")))
lis <- list(c("The", "United-States", "has", "the", "Atlantic-Ocean", 
              "and", "the", "Pacific-Ocean", "."))
toks <- as.tokens(lis, concatenator = "-")
tokens_lookup(toks, dict)

# combining tokens
toks1 <- tokens(c(doc1 = "a b c d e", doc2 = "f g h"))
toks2 <- tokens(c(doc3 = "1 2 3"))
toks1 + toks2
c(toks1, toks2)

}
