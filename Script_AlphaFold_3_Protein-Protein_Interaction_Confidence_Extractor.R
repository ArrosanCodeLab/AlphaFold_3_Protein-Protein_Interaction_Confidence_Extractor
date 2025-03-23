#Install the required R packages using:
install.packages("jsonlite")
install.packages("openxlsx")

# Load required libraries
library(jsonlite)  # For JSON processing
library(openxlsx)  # For writing to Excel

# Define the folder configurations where your summary_confidences_*.json located
# I have 6 predictions, so I have 6 folder configurations
# 📌 Note: Ensure file_prefix matches the naming exactly, e.g., "fold_A_B_C_summary_confidences_"
folder_configs <- list(
  list(
    base_dir = "C:/Users/r02ar23/Desktop/250320_A_Single_Mutations/A_B_C/A_B_C/",
    file_prefix = "fold_A_B_C_summary_confidences_",
    name = "WT"
  ),
  list(
    base_dir = "C:/Users/r02ar23/Desktop/250320_A_Single_Mutations/A_B_C/f581a/",
    file_prefix = "fold_f581a_summary_confidences_",
    name = "f581a"
  ),
  list(
    base_dir = "C:/Users/r02ar23/Desktop/250320_A_Single_Mutations/A_B_C/y584a/",
    file_prefix = "fold_y584a_summary_confidences_",
    name = "y584a"
  ),
  list(
    base_dir = "C:/Users/r02ar23/Desktop/250320_A_Single_Mutations/A_B_C/e587a/",
    file_prefix = "fold_e587a_summary_confidences_",
    name = "e587a"
  ),
  list(
    base_dir = "C:/Users/r02ar23/Desktop/250320_A_Single_Mutations/A_B_C/r588a/",
    file_prefix = "fold_r588a_summary_confidences_",
    name = "r588a"
  ),
  list(
    base_dir = "C:/Users/r02ar23/Desktop/250320_A_Single_Mutations/A_B_C/i636a/",
    file_prefix = "fold_i636a_summary_confidences_",
    name = "i636a"
  )
)

# Initialize lists to store data
chain_pair_iptm_list <- list()
chain_pair_pae_min_list <- list()
file_suffix <- ".json"

# Process each folder
for (config in folder_configs) {
  files <- paste0(config$base_dir, config$file_prefix, 0:4, file_suffix)
  for (i in 1:length(files)) {
    if (file.exists(files[i])) {
      json_data <- fromJSON(files[i])
      model_name <- paste0(config$name, "_Model_", i-1)
      if ("chain_pair_iptm" %in% names(json_data)) {
        chain_pair_iptm_list[[model_name]] <- json_data$chain_pair_iptm
      } else {
        warning(paste("chain_pair_iptm not found in file:", files[i]))
      }
      if ("chain_pair_pae_min" %in% names(json_data)) {
        chain_pair_pae_min_list[[model_name]] <- json_data$chain_pair_pae_min
      } else {
        warning(paste("chain_pair_pae_min not found in file:", files[i]))
      }
    } else {
      warning(paste("File not found:", files[i]))
    }
  }
}

# Define output file path
output_file <- "C:/Users/r02ar23/Desktop/250320_A_Single_Mutations/A_B_C/A_B_C_chain_pair_results.xlsx"

# Create a workbook
wb <- createWorkbook()

# Define chain names
chain_names <- c("A", "B", "C")

# Layout parameters
n_chains <- length(chain_names)
block_width <- n_chains + 1
block_height <- n_chains + 1
models_per_row <- 5
mutant_order <- c("WT", "f581a", "y584a", "e587a", "r588a", "i636a")

# Sheet 1: iPTM
addWorksheet(wb, "Chain_Pair_iPTM")
current_row <- 1
for (mutant in mutant_order) {
  current_col <- 1
  for (model_num in 0:4) {
    model_name <- paste0(mutant, "_Model_", model_num)
    if (model_name %in% names(chain_pair_iptm_list)) {
      df <- as.data.frame(chain_pair_iptm_list[[model_name]])
      colnames(df) <- chain_names
      rownames(df) <- chain_names
      writeData(wb, "Chain_Pair_iPTM", model_name, startRow = current_row, startCol = current_col)
      writeData(wb, "Chain_Pair_iPTM", df, startRow = current_row + 1, startCol = current_col, rowNames = TRUE)
      current_col <- current_col + block_width + 1
    }
  }
  current_row <- current_row + block_height + 1
}

# Sheet 2: PAE_min
addWorksheet(wb, "Chain_Pair_PAE_min")
current_row <- 1
for (mutant in mutant_order) {
  current_col <- 1
  for (model_num in 0:4) {
    model_name <- paste0(mutant, "_Model_", model_num)
    if (model_name %in% names(chain_pair_pae_min_list)) {
      df <- as.data.frame(chain_pair_pae_min_list[[model_name]])
      colnames(df) <- chain_names
      rownames(df) <- chain_names
      writeData(wb, "Chain_Pair_PAE_min", model_name, startRow = current_row, startCol = current_col)
      writeData(wb, "Chain_Pair_PAE_min", df, startRow = current_row + 1, startCol = current_col, rowNames = TRUE)
      current_col <- current_col + block_width + 1
    }
  }
  current_row <- current_row + block_height + 1
}

# Save workbook
saveWorkbook(wb, file = output_file, overwrite = TRUE)

# Done
cat("✅ Data exported to:", output_file, "with chain_pair_iptm in Sheet 1 and chain_pair_pae_min in Sheet 2\n")