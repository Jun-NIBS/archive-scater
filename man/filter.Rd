% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/verbs.R
\docType{methods}
\name{filter}
\alias{filter}
\alias{filter,SCESet-method}
\alias{filter.SCESet}
\title{Return \code{SCESet} with cells matching conditions.}
\usage{
filter(object, ...)

\S4method{filter}{SCESet}(object, ...)

filter.SCESet(object, ...)
}
\arguments{
\item{object}{A \code{SCESet} object.}

\item{...}{Additional arguments to be passed to \code{dplyr::filter} to
act on \code{pData(object)}.}
}
\description{
Subsets the columns (cells) of a \code{SCESet} based on 
matching conditions in the rows of \code{pData(object)}.
}
\examples{
data("sc_example_counts")
data("sc_example_cell_info")
pd <- new("AnnotatedDataFrame", data = sc_example_cell_info)
example_sceset <- newSCESet(countData = sc_example_counts, phenoData = pd)
example_sceset_treat1 <- filter(example_sceset, Treatment == "treat1")
}
