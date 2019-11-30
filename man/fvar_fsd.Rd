\name{fvar-fsd}
\alias{fvar}
\alias{fvar.default}
\alias{fvar.matrix}
\alias{fvar.data.frame}
\alias{fvar.grouped_df}
\alias{fsd}
\alias{fsd.default}
\alias{fsd.matrix}
\alias{fsd.data.frame}
\alias{fsd.grouped_df}
\title{Fast (Grouped, Weighted) Variance and Standard Deviation for Matrix-Like Objects}  % Vectors, Matrix and Data Frame Columns
\description{
\code{fvar} and \code{fsd} are generic functions that compute the (column-wise) variance and standard deviation of \code{x}, (optionally) grouped by \code{g} and/or frequency-weighted by \code{w}. The \code{\link{TRA}} argument can further be used to transform \code{x} using its (grouped, weighted) variance/sd.
}
\usage{
fvar(x, ...)
fsd(x, ...)

## Default S3 methods:
fvar(x, g = NULL, w = NULL, TRA = FALSE, na.rm = TRUE,
     use.g.names = TRUE, stable.algo = TRUE, ...)
 fsd(x, g = NULL, w = NULL, TRA = FALSE, na.rm = TRUE,
     use.g.names = TRUE, stable.algo = TRUE, ...)

## S3 methods for class 'matrix'
fvar(x, g = NULL, w = NULL, TRA = FALSE, na.rm = TRUE,
     use.g.names = TRUE, drop = TRUE, stable.algo = TRUE, ...)
 fsd(x, g = NULL, w = NULL, TRA = FALSE, na.rm = TRUE,
     use.g.names = TRUE, drop = TRUE, stable.algo = TRUE, ...)

## S3 methods for class 'data.frame'
fvar(x, g = NULL, w = NULL, TRA = FALSE, na.rm = TRUE,
     use.g.names = TRUE, drop = TRUE, stable.algo = TRUE, ...)
 fsd(x, g = NULL, w = NULL, TRA = FALSE, na.rm = TRUE,
     use.g.names = TRUE, drop = TRUE, stable.algo = TRUE, ...)

## S3 methods for class 'grouped_df'
fvar(x, w = NULL, TRA = FALSE, na.rm = TRUE,
     use.g.names = FALSE, keep.group_vars = TRUE, keep.w = TRUE,
     stable.algo = TRUE, ...)
 fsd(x, w = NULL, TRA = FALSE, na.rm = TRUE,
     use.g.names = FALSE, keep.group_vars = TRUE, keep.w = TRUE,
     stable.algo = TRUE, ...)
}
\arguments{
\item{x}{a numeric vector, matrix, data.frame or grouped tibble (\code{dplyr::grouped_df}).}

\item{g}{a factor, \code{\link{GRP}} object, atomic vector (internally converted to factor) or a list of vectors / factors (internally converted to a \code{\link{GRP}} object) used to group \code{x}.}

\item{w}{a numeric vector of (non-negative) weights, may contain missing values.}

\item{TRA}{an integer or quoted operator indicating the transformation to perform:
1 - "replace_fill"     |     2 - "replace"     |     3 - "-"     |     4 - "-+"     |     5 - "/"     |     6 - "\%"     |     7 - "+"     |     8 - "*". See \code{\link{TRA}}.}

\item{na.rm}{logical. Skip missing values in \code{x}. Defaults to \code{TRUE} and implemented at very little computational cost. If \code{na.rm = FALSE} a \code{NA} is returned when encountered.}

\item{use.g.names}{make group-names and add to the result as names (vector method) or row-names (matrix and data.frame method). No row-names are generated for data.tables and grouped tibbles.}

\item{drop}{\emph{matrix and data.frame method:} drop dimensions and return an atomic vector if \code{g = NULL} and \code{TRA = FALSE}.}

\item{keep.group_vars}{\emph{grouped_df method:} Logical. \code{FALSE} removes grouping variables after computation.}

\item{keep.w}{\emph{grouped_df method:} Logical. Retain summed weighting variable after computation (if contained in \code{grouped_df}).}

\item{stable.algo}{logical. \code{TRUE} (default) use Welford's numerically stable online algorithm. \code{FALSE} implements a faster but numerically instable one-pass method. See Details. }

\item{...}{arguments to be passed to or from other methods.}

}
\details{
\emph{Welford's online algorithm} used by default to compute the variance is well described \href{https://en.wikipedia.org/wiki/Algorithms_for_calculating_variance}{here} (the section \emph{Weighted incremental algorithm} also shows how the weighted variance is obtained by this algorithm).

If \code{stable.algo = FALSE}, the variance is computed in one-pass as \code{(sum(x^2)-n*mean(x)^2)/(n-1)}, where \code{sum(x^2)} is the sum of squares from which the expected sum of squares \code{n*mean(x)^2} is subtracted, normalized by \code{n-1} (Bessel's correction). This is numerically instable if \code{sum(x^2)} and \code{n*mean(x)^2} are large numbers very close together, which will be the case for large \code{n}, large \code{x}-values and small variances (catastrophic cancellation occurs, leading to a loss of numeric precision). Numeric precision is however still maximized through the internal use of long doubles in C++, and the fast algorithm can be up to 4-times faster compared to Welford's method.

The weighted variance is computed with frequency weights as \code{(sum(x^2*w)-sum(w)*weighted.mean(x,w)^2)/(sum(w)-1)}. If \code{na.rm = TRUE}, missing values will be removed from both \code{x} and \code{w} i.e. utilizing only \code{x[complete.cases(x,w)]} and \code{w[complete.cases(x,w)]}.

Missing-value removal as controlled by the \code{na.rm} argument is done very efficiently by simply skipping the values (thus setting \code{na.rm = FALSE} on data with no missing values doesn't give extra speed). Large performance gains can nevertheless be achieved in the presence of missing values if \code{na.rm = FALSE}, since then the corresponding computation is terminated once a \code{NA} is encountered and \code{NA} is returned.

This all seamlessly generalizes to grouped computations, which are performed in a single pass (without splitting the data) and therefore extremely fast.

When applied to data frame's with groups or \code{drop = FALSE}, \code{fvar/fsd} preserves all column attributes (such as variable labels) but does not distinguish between classed and unclassed object (thus applying \code{fvar/fsd} to a factor column will give a 'malformed factor' error, and applying it to a date variable will give an error or a pretty weird date). The attributes of the \code{data.frame} itself are also perserved.
}
\value{
\code{fvar} returns the variance of \code{x}, grouped by \code{g}, or (if \code{\link{TRA}} is used) \code{x} transformed by its variance, grouped by \code{g}. \code{fsd} computes the standard deviation of \code{x} in like manor.
}
\seealso{
\link[=fast-statistical-functions]{Fast Statistical Functions}
}
\examples{
## default vector method
fvar(mtcars$mpg)                            # Simple variance (all examples below also hold for fvar!)
fsd(mtcars$mpg)                             # Simple standard deviation
fsd(mtcars$mpg, w = mtcars$hp)              # Weighted sd: Weighted by hp
fsd(mtcars$mpg, TRA = "/")                  # Simple transformation: scaling (See also ?fscale for quickly standardizing i.e. scaling and centering data)
fsd(mtcars$mpg, mtcars$cyl)                 # Grouped sd
fsd(mtcars$mpg, mtcars$cyl, mtcars$hp)      # Grouped weighted sd
fsd(mtcars$mpg, mtcars$cyl, TRA = "/")      # Scaling by group
fsd(mtcars$mpg, mtcars$cyl, mtcars$hp, "/") # Group-scaling using weighted group sds

## data.frame method
fsd(iris)                           # This works, although 'Species' is a factor variable
fsd(iris, drop = FALSE)             # This gives an error, becase fsd wants to add back attributes to 'Species'
fsd(mtcars, drop = FALSE)           # This works, all columns are numeric variables
fsd(iris[-5], iris[5])              # By Species: iris[5] is still a list, and thus passed to GRP() first, see ?GRP
fsd(iris[-5], iris[[5]])            # Same thing but much faster: fsd recognizes that 'Species' is a factor and uses it directly
fsd(iris[-5], iris[[5]], TRA = "/") # Data scaled by species (see also fscale for proper standardization)

## matrix method
m <- qM(mtcars)
fsd(m)
fsd(m, mtcars$cyl) # etc...

## method for grouped tibbles - for use with dplyr:
library(dplyr)
mtcars \%>\% group_by(cyl,vs,am) \%>\% fsd
mtcars \%>\% group_by(cyl,vs,am) \%>\% fsd(keep.group_vars = FALSE) # remove grouping columns
mtcars \%>\% group_by(cyl,vs,am) \%>\% fsd(hp)      # Weighted by hp. Since drop.w = TRUE by default, hp is removed from the result.
mtcars \%>\% group_by(cyl,vs,am) \%>\% fsd(hp, "/") # Weighted scaling transformation
}
