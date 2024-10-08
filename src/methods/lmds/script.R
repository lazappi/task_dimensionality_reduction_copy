## VIASH START
par <- list(
  input = "resources_test/dimensionality_reduction/pancreas/dataset.h5ad",
  output = "output.h5ad",
  n_dim = 3,
  n_landmarks = 1000,
  distance_method = "pearson"
)
## VIASH END

message("Reading input files")
input <- anndata::read_h5ad(par$input)

# TODO: if we wanted to, we could compute the distance
# matrix in batches. This would be useful for large datasets.
message("Running LMDS")
X_emb <- lmds::lmds(
  input$layers[["normalized"]],
  ndim = par$n_dim,
  num_landmarks = par$n_landmarks,
  distance_method = par$distance_method
)

message("Write output AnnData to file")
output <- anndata::AnnData(
  uns = list(
    dataset_id = input$uns[["dataset_id"]],
    method_id = meta$functionality_name,
    normalization_id = input$uns[["normalization_id"]]
  ),
  obsm = list(
    X_emb = X_emb
  ),
  shape = input$shape
)
output$write_h5ad(par$output, compression = "gzip")
