#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector fsumCpp(const NumericVector& x, int ng = 0, const IntegerVector& g = 0, bool narm = true) {
  int l = x.size();

  if(ng == 0) {
    if(narm) {
      int j = l-1;
      long double sum = x[j];
      while(std::isnan(sum) && j!=0) sum = x[--j];
      if(j != 0) for(int i = j; i--; ) {
        if(!std::isnan(x[i])) sum += x[i]; // Fastest ??
      }
      return NumericVector::create((double)sum); // Converting long double directly to numeric vector is slow !!!
    } else {
      long double sum = 0;
      for(int i = 0; i != l; ++i) {
        if(std::isnan(x[i])) {
          sum = x[i];
          break;
        } else {
          sum += x[i];
        }
      }
      return NumericVector::create((double)sum);
    }
  } else { // with groups
    if(g.size() != l) stop("length(g) must match nrow(X)");
    if(narm) {
      NumericVector sum(ng, NA_REAL); // Other way ??
      for(int i = l; i--; ) {
        if(!std::isnan(x[i])) { // faster way to code this ??? -> Not Bad at all
          if(std::isnan(sum[g[i]-1])) sum[g[i]-1] = x[i];
          else sum[g[i]-1] += x[i];
        }
      }
      DUPLICATE_ATTRIB(sum, x);
      return sum;
    } else {
      NumericVector sum(ng); // good?? -> yes !! // Not initializing numerically unstable !!!
      int ngs = 0;
      for(int i = 0; i != l; ++i) {
        if(std::isnan(x[i])) {
          if(!std::isnan(sum[g[i]-1])) {
            sum[g[i]-1] = x[i];
            ++ngs;
            if(ngs == ng) break;
          }
        } else {
          sum[g[i]-1] += x[i];
        }
      }
      DUPLICATE_ATTRIB(sum, x);
      return sum;
    }
  }
}





// [[Rcpp::export]]
SEXP fsummCpp(const NumericMatrix& x, int ng = 0, const IntegerVector& g = 0, // No speed loss by putting SEXP !!
              bool narm = true, bool drop = true) {
  int l = x.nrow(), col = x.ncol();

  if(ng == 0) {
    NumericVector sum = no_init_vector(col); // Initialize faster -> Nope !!!
    if(narm) {
      for(int j = col; j--; ) { // Instead Am(j,_) you can use Am.row(j).
        NumericMatrix::ConstColumn column = x( _ , j);
        int k = l-1;
        long double sumj = column[k]; // Slight speed loss 38 vs 32 milliseconds on WDIM
        while(std::isnan(sumj) && k!=0) sumj = column[--k];
        if(k != 0) for(int i = k; i--; ) {
          if(!std::isnan(column[i])) sumj += column[i];
        }
        sum[j] = (double)sumj; // No speed loss, but more secure
      }
    } else {
      for(int j = col; j--; ) {
        NumericMatrix::ConstColumn column = x( _ , j);
        long double sumj = 0;
        for(int i = 0; i != l; ++i) {
          if(std::isnan(column[i])) {
            sumj = column[i];
            break;
          } else {
            sumj += column[i];
          }
        }
        sum[j] = (double)sumj;
      }
    }
    if(drop) sum.attr("names") = colnames(x); // Slight speed loss 31 to 34 milliseconds on WDIM, but doing it in R not faster !!
    else {
      // SHALLOW_DUPLICATE_ATTRIB(sum, x);
      sum.attr("dim") = Dimension(1, col);
      colnames(sum) = colnames(x);
    }
    return sum;
  } else { // with groups
    if(g.size() != l) stop("length(g) must match nrow(X)");
    if(narm) {
      NumericMatrix sum = no_init_matrix(ng, col);
      std::fill(sum.begin(), sum.end(), NA_REAL);
      for(int j = col; j--; ) {
        NumericMatrix::ConstColumn column = x( _ , j);
        NumericMatrix::Column sumj = sum( _ , j);
        for(int i = l; i--; ) {
          if(!std::isnan(column[i])) {
            if(std::isnan(sumj[g[i]-1])) sumj[g[i]-1] = column[i];
            else sumj[g[i]-1] += column[i];
          }
        }
      }
      colnames(sum) = colnames(x);  // extremely efficient !!
      return sum;
    } else {
      NumericMatrix sum(ng, col); // no init numerically unstable !!!
      for(int j = col; j--; ) {
        NumericMatrix::ConstColumn column = x( _ , j);
        NumericMatrix::Column sumj = sum( _ , j);
        int ngs = 0;
        for(int i = 0; i != l; ++i) {
          if(std::isnan(column[i])) {
            if(!std::isnan(sumj[g[i]-1])) {
              sumj[g[i]-1] = column[i];
              ++ngs;
              if(ngs == ng) break;
            }
          } else {
            sumj[g[i]-1] += column[i];
          }
        }
      }
      colnames(sum) = colnames(x);
      return sum;
    }
    // sum.attr("dimnames") = List::create(R_NilValue,colnames(x));
    // colnames(sum) = colnames(x); // NEW! faster than R ?? -> nope, slower !! -> Do as above !!
  }
}





// [[Rcpp::export]]
SEXP fsumlCpp(const List& x, int ng = 0, const IntegerVector& g = 0,
              bool narm = true, bool drop = true) {
  int l = x.size();

  if (ng == 0) {
    NumericVector sum(l); // not initializing not faster WIth NWDI (35 instead of 32 milliseconds)
    if(narm) {
      for(int j = l; j--; ) {
        // for(int j = 0; j != l; ++j) { // Not necessarily faster !!
        NumericVector column = x[j];
        int k = column.size()-1;
        long double sumi = column[k]; // a bit extra speed with double, 31 vs 36 milliseconds on NWDI
        while(std::isnan(sumi) && k!=0) sumi = column[--k];
        if(k != 0) for(int i = k; i--; ) {
          if(!std::isnan(column[i])) sumi += column[i];
        }
        sum[j] = (double)sumi;
      }
    } else {
      for(int j = l; j--; ) {
        NumericVector column = x[j];
        long double sumi = 0;
        int row = column.size();
        for(int i = 0; i != row; ++i) {
          if(std::isnan(column[i])) {
            sumi = column[i];
            break;
          } else {
            sumi += column[i];
          }
        }
        sum[j] = (double)sumi;
      }
    }
    if(drop) {
      sum.attr("names") = x.attr("names");
      return sum;
    } else {
      List out(l);
      for(int j = l; j--; ) {
        out[j] = sum[j];
        SHALLOW_DUPLICATE_ATTRIB(out[j], x[j]);
      }
      DUPLICATE_ATTRIB(out, x);
      out.attr("row.names") = 1;
      return out;
    }
  } else { // With groups !!
    List sum(l);
    int gss = g.size();
    if(narm) {
      for(int j = l; j--; ) {
        NumericVector column = x[j];
        if(gss != column.size()) stop("length(g) must match nrow(X)");
        NumericVector sumj(ng, NA_REAL);
        for(int i = gss; i--; ) {
          if(std::isnan(column[i])) continue; // faster way to code this ??? -> Not Bad at all, 54.. millisec for WDIM
          if(std::isnan(sumj[g[i]-1])) sumj[g[i]-1] = column[i];
          else sumj[g[i]-1] += column[i];
        }
        SHALLOW_DUPLICATE_ATTRIB(sumj, column);
        sum[j] = sumj;
      }
    } else {
      for(int j = l; j--; ) {
        NumericVector column = x[j];
        if(gss != column.size()) stop("length(g) must match nrow(X)");
        NumericVector sumj(ng); //  = no_init_vector(ng); // Not initializing in loop is numerically unstable !!
        int ngs = 0;
        for(int i = 0; i != gss; ++i) {
          if(std::isnan(column[i])) {
            if(!std::isnan(sumj[g[i]-1])) {
              sumj[g[i]-1] = column[i];
              ++ngs;
              if(ngs == ng) break;
            }
          } else {
            sumj[g[i]-1] += column[i];
          }
        }
        SHALLOW_DUPLICATE_ATTRIB(sumj, column);
        sum[j] = sumj;
      }
    }
    DUPLICATE_ATTRIB(sum, x);
    sum.attr("row.names") = NumericVector::create(NA_REAL, -ng);
    return sum;
  }
}