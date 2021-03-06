
# what about attribute preervation ? -> I think it is not good having all kinds of stuff attached to a matrix. Also dapply and BY convert that way.
qDF <- function(X, row.names.col = FALSE) {
  if(is.atomic(X)) {
    d <- dim(X)
    ld <- length(d)
    if(ld >= 2L) {
      if(ld != 2L) {
        dn <- dimnames(X)
        dim(X) <- c(d[1L], prod(d[-1L]))
        if(!is.null(dn)) {
          for (i in 2L:ld) if(is.null(dn[[i]])) dn[[i]] <- seq_len(d[i])
          dimnames(X) <- list(dn[[1L]], interact_names(dn[-1L])) # Good?
        }
      }
      if(!isFALSE(row.names.col) && !is.null(force(dn <- dimnames(X))[[1L]])) {
        res <- c(list(dn[[1L]]), .Call(Cpp_mctl, X, FALSE, 0L))
        names(res) <- c(if(is.character(row.names.col)) row.names.col[1L] else "row.names", dn[[2L]])
        attr(res, "row.names") <- .set_row_names(length(dn[[1L]]))
        return(`oldClass<-`(res, "data.frame"))
      }
      return(.Call(Cpp_mctl, X, TRUE, 1L))
    }
    nam <- names(X)
    if(isFALSE(row.names.col) || is.null(nam)) {
      if(is.null(nam)) {
        res <- `names<-`(list(X), l1orlst(as.character(substitute(X))))
        attr(res, "row.names") <- .set_row_names(length(X))
      } else {
        res <- `names<-`(list(`names<-`(X, NULL)), l1orlst(as.character(substitute(X))))
        attr(res, "row.names") <- nam
      }
    } else {
      res <- list(nam, `names<-`(X, NULL))
      names(res) <- c(if(is.character(row.names.col)) row.names.col[1L] else "row.names", l1orlst(as.character(substitute(X))))
      attr(res, "row.names") <- .set_row_names(length(X))
    }
    return(`oldClass<-`(res, "data.frame"))
  }
  # if(inherits(X, "data.frame")) return(X)
  if(is.null(attr(X, "names"))) attr(X, "names") <- paste0("V", seq_along(unclass(X)))
  if(is.null(attr(X, "row.names"))) {
    attr(X, "row.names") <- .set_row_names(fnrow2(X))
  } else if(!isFALSE(row.names.col)) {
    ax <- attributes(X)
    X <- c(list(ax[["row.names"]]), X) # best ??
    ax[["row.names"]] <- .set_row_names(length(X[[1L]])) # this is ok, X is a list ...
    ax[["names"]] <- c(if(is.character(row.names.col)) row.names.col[1L] else "row.names", ax[["names"]])
    setattributes(X, ax)
  }
  oldClass(X) <- "data.frame"
  X
}

qDT <- function(X, row.names.col = FALSE) {
  if(is.atomic(X)) {
    d <- dim(X)
    ld <- length(d)
    if(ld >= 2L) {
      if(ld != 2L) {
        dn <- dimnames(X)
        dim(X) <- c(d[1L], prod(d[-1L]))
        if(!is.null(dn)) {
          for (i in 2L:ld) if(is.null(dn[[i]])) dn[[i]] <- seq_len(d[i])
          dimnames(X) <- list(dn[[1L]], interact_names(dn[-1L])) # Good?
        }
      }
      if(!isFALSE(row.names.col) && !is.null(force(dn <- dimnames(X))[[1L]])) {
        res <- c(list(dn[[1L]]), .Call(Cpp_mctl, X, FALSE, 0L))
        names(res) <- c(if(is.character(row.names.col)) row.names.col[1L] else "row.names", dn[[2L]])
        attr(res, "row.names") <- .set_row_names(length(dn[[1L]]))
        return(`oldClass<-`(res, c("data.table","data.frame")))
      }
      return(.Call(Cpp_mctl, X, TRUE, 2L))
    }
    if(isFALSE(row.names.col) || is.null(nam <- names(X))) {
      res <- `names<-`(list(X), l1orlst(as.character(substitute(X))))
    } else {
      res <- list(nam, `names<-`(X, NULL))
      names(res) <- c(if(is.character(row.names.col)) row.names.col[1L] else "row.names", l1orlst(as.character(substitute(X))))
    }
    attr(res, "row.names") <- .set_row_names(length(X))
    return(`oldClass<-`(res, c("data.table","data.frame")))
  }
  if(inherits(X, "data.table")) return(X)
  if(is.null(attr(X, "names"))) attr(X, "names") <- paste0("V", seq_along(unclass(X)))
  if(!isFALSE(row.names.col) && !is.null(rn <- attr(X, "row.names"))) {
    ax <- attributes(X)
    X <- c(list(rn), X)
    ax[["names"]] <- c(if(is.character(row.names.col)) row.names.col[1L] else "row.names", ax[["names"]])
    setattributes(X, ax)
  }
  attr(X, "row.names") <- .set_row_names(fnrow2(X))
  oldClass(X) <- c("data.table","data.frame")
  X
}

qM <- function(X) {
  if(is.atomic(X)) {
    d <- dim(X)
    ld <- length(d)
    if(ld > 2L) {
      dn <- dimnames(X)
      dim(X) <- c(d[1L], prod(d[-1L]))
      if(!is.null(dn)) {
        for (i in 2L:ld) if(is.null(dn[[i]])) dn[[i]] <- seq_len(d[i])
        dimnames(X) <- list(dn[[1L]], interact_names(dn[-1L])) # Good?
      }
      return(X)
    }
    if(ld == 2L) return(X)
    return(matrix(X, ncol = 1, dimnames = list(names(X), l1orlst(as.character(substitute(X))))))
  }
  rn <- attr(X, "row.names")
  res <- do.call(cbind, X)
  if(!(is.numeric(rn) || is.null(rn) || rn[1L] == "1")) dimnames(res) <- list(rn, attr(X, "names"))
  res
}


