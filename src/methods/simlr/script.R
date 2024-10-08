## VIASH START
par <- list(
  input = "resources_test/dimensionality_reduction/pancreas/dataset.h5ad",
  output = "output.h5ad",
  n_clusters = NULL,
  n_dim = NA,
  tuning_param = 10,
  impute = FALSE,
  normalize = FALSE,
  cores_ratio = 1
)
meta <- list(
  functionality_name = "simlr"
)
## VIASH END

message("Reading input files")
input <- anndata::read_h5ad(par$input)

X <- t(as.matrix(input$layers[["normalized"]]))

if (is.null(par$n_clusters)) {
  message("Estimating the number of clusters")
  set.seed(1)
  NUMC <- 2:5
  estimates <- SIMLR::SIMLR_Estimate_Number_of_Clusters(
    X = X,
    NUMC = NUMC,
    cores.ratio = par$cores_ratio
  )
  n_clusters <- NUMC[which.min(estimates$K2)]
} else {
  n_clusters <- par$n_clusters
}

if (is.null(par$n_dim)) {
  n_dim <- NA
} else {
  n_dim <- par$n_dim
}

message("Running SIMLR")
simlr_result <- SIMLR::SIMLR(
  X = X,
  c = n_clusters,
  no.dim = n_dim,
  k = par$tuning_param,
  if.impute = par$impute,
  normalize = par$normalize,
  cores.ratio = par$cores_ratio
)
obsm_X_emb <- simlr_result$ydata

message("Write output AnnData to file")
output <- anndata::AnnData(
  uns = list(
    dataset_id = input$uns[["dataset_id"]],
    method_id = meta$functionality_name,
    normalization_id = input$uns[["normalization_id"]]
  ),
  obsm = list(
    X_emb = obsm_X_emb
  ),
  shape = input$shape
)
output$write_h5ad(par$output, compression = "gzip")
