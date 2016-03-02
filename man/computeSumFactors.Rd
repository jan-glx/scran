\name{Deconvolution Methods}
\alias{computeSumFactors}
\alias{computeSumFactors,ANY-method}
\alias{computeSumFactors,SCESet-method}

\title{Normalization by deconvolution}
\description{Methods to normalize single-cell RNA-seq data by deconvolving size factors from cell pools.}

\usage{
\S4method{computeSumFactors}{ANY}(x, sizes=c(20, 40, 60, 80, 100), 
    clusters=NULL, ref.clust=NULL, positive=FALSE)
\S4method{computeSumFactors}{SCESet}(x, ...)
}

\arguments{
\item{x}{
    A numeric count matrix where rows are genes and columns are cells.
    Alternatively, a SCESet object containing such a matrix.
}
\item{sizes}{A numeric vector of pool sizes, i.e., number of cells per pool.}
\item{clusters}{An optional factor specifying which cells belong to which cluster, for deconvolution within clusters.}
\item{ref.clust}{A level of \code{clusters} to be used as the reference cluster for inter-cluster normalization.}
\item{positive}{A logical scalar indicating whether linear inverse models should be used to enforce positive estimates.}
\item{...}{Additional arguments to pass to \code{computeSumFactors,ANY-method}.}
}

\section{Overview of the deconvolution method}{
The \code{computeSumFactors} function provides an implementation of the deconvolution strategy for normalization.
Briefly, a pool of cells is selected and the counts for those cells are summed together.
The count sums for this pool is normalized against an average reference pseudo-cell, constructed by averaging the counts across all cells.
This defines a size factor for the pool as the median ratio between the count sums and the average across all genes.

Now, the bias for the pool is equal to the sum of the biases for the constituent cells.
The same applies for the size factors (which are effectively estimates of the bias for each cell).
This means that the size factor for the pool can be written as a linear equation of the size factors for the cells.
Repeating this process for multiple pools will yield a linear system that can be solved to obtain the size factors for the individual cells.

In this manner, pool-based factors are deconvolved to yield the relevant cell-based factors.
The advantage is that the pool-based estimates are more accurate, as summation reduces the number of stochastic zeroes and the associated bias of the size factor estimate.
This accuracy will feed back into the deconvolution process, thus improving the accuracy of the cell-based size factors.
}

\section{Normalization within and between clusters}{
In general, it is more appropriate to pool more similar cells to avoid violating the assumption of a non-DE majority of genes across the data set.
This can be done by specifying the \code{clusters} argument where cells in each cluster have similar expression profiles.
Deconvolution is subsequently applied on the cells within each cluster.
Each cluster should contain a sufficient number of cells for pooling -- twice the maximum value of \code{sizes} is recommended.
A convenince function \code{\link{quickCluster}} is provided for rapid clustering based on Spearman's rank correlation.

Size factors computed within each cluster must be rescaled for comparison between clusters.
This is done by normalizing between clusters to identify the rescaling factor.
One cluster is chosen as a ``reference'' (by default, that with the median of the mean per-cell library sizes is used) to which all others are normalized.
Ideally, a cluster that is not extremely different from all other clusters should be used as the reference.
This can be specified using \code{ref.clust} if there is prior knowledge about which cluster is most suitable, e.g., from PCA or t-SNE plots.
}

\section{Additional details about pooling and deconvolution}{
Within each cluster (if not specified, all cells are put into a single cluster), cells are sorted by increasing library size and a sliding window is applied to this ordering.
Each location of the window defines a cell pool with similar library sizes.
This avoids inflated estimation errors for very small cells when they are pooled with very large cells.
Sliding the window will construct a linear system.
This is repeated with all window sizes in \code{sizes} to obtain an over-determined system that can be solved with methods like the QR decomposition.

In theory, it is possible to obtain negative estimates for the size factors.
These are most likely for very small library sizes and are obviously nonsensical.
Some protection can be provided by setting \code{positive=TRUE}, which will use linear inverse models to solve the system.
This ensures that non-negative values for the size factors will always be obtained.
Note that some cells may still have size factors of zero and should be removed prior to downstream analysis.
Such occurrences are unavoidable -- rather, the aim is to prevent negative values from affecting the estimates for all other cells.
}

\value{
For \code{computeSumFactors,ANY-method}, a numeric vector of size factors for all cells in \code{x} is returned.

For \code{computeSumFactors,SCESet-method}, an object of class \code{x} is returned containing the vector of size factors in \code{sizeFactors(x)}.
}

\author{
Aaron Lun and Karsten Bach
}

\seealso{
\code{\link{quickCluster}}
}

\examples{
set.seed(100)
popsize <- 800
ngenes <- 10000
all.facs <- 2^rnorm(popsize, sd=0.5)
counts <- matrix(rnbinom(ngenes*popsize, mu=all.facs*10, size=1), ncol=popsize, byrow=TRUE)
out.facs <- computeSumFactors(counts)
}

\keyword{normalization}