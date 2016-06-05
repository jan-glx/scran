#ifndef SCRAN_H
#define SCRAN_H

#include "R.h"
#include "Rinternals.h"
#include "R_ext/Rdynload.h"
#include "R_ext/Visibility.h"
#include "R_ext/BLAS.h"
#include "R_ext/Lapack.h"

#include <stdexcept>
#include <algorithm>
#include <deque>
#include <cmath>

extern "C" {

SEXP forge_system (SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);

SEXP shuffle_scores (SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP, SEXP);

SEXP get_null_rho (SEXP, SEXP);

SEXP get_null_rho_design (SEXP, SEXP, SEXP, SEXP);

SEXP compute_rho(SEXP, SEXP, SEXP, SEXP);

SEXP auto_shuffle(SEXP, SEXP);

SEXP compute_cordist(SEXP, SEXP);

}

#include "utils.h"

#endif 
