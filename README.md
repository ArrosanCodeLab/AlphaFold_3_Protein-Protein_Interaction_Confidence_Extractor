# 🚀 AlphaFold 3 Protein-Protein Interaction Confidence Extractor

This repository provides an R script that extracts and visualizes **pairwise interface confidence scores** from **AlphaFold 3 multimer predictions**, especially useful when analyzing wild-type and mutant protein complexes.

✅ The script is designed to:
- Read multiple AlphaFold3 `summary_confidences_*.json` files
- Extract and arrange the `chain_pair_iptm` and `chain_pair_pae_min` matrices
- Export all results into a well-structured **Excel workbook**

---

## 🧪 Example Use Case
Imagine you are analyzing protein-protein interactions in a predicted trimeric complex composed of three proteins:

- **Protein A**
- **Protein B**
- **Protein C**

You have:
- ✅ Wild-type complex prediction (WT)
- 🔁 Several single-point mutants (e.g., f581a, y584a, etc.)
- 📂 5 AlphaFold3 models generated per complex (ranked 0 to 4)

Each model has a corresponding `summary_confidences_*.json` file containing matrix data such as:

```json
"chain_pair_iptm": [
  [0.67, 0.61, 0.82],
  [0.61, 0.21, 0.72],
  [0.82, 0.72, 0.84]
],
"chain_pair_pae_min": [
  [0.76, 1.21, 0.95],
  [1.5, 0.76, 2.32],
  [0.98, 1.9, 0.76]
]
```

The script reads these matrices for each model of each mutant and arranges them neatly in Excel for downstream comparison.

---

## 📤 Output
The script generates an Excel workbook `A_B_C_chain_pair_results.xlsx` with two sheets:

### 📊 Sheet 1: `Chain_Pair_iPTM`
Displays `chain_pair_iptm` values (confidence of protein interfaces) for each model in a grid format.

#### Example Layout:
|       | A | B | C |
|-------|---|---|---|
| **A** | 0.67 | 0.61 | 0.82 |
| **B** | 0.61 | 0.21 | 0.72 |
| **C** | 0.82 | 0.72 | 0.84 |

### 📉 Sheet 2: `Chain_Pair_PAE_min`
Displays `chain_pair_pae_min` values (minimum predicted alignment error between chains) in the same layout.

🔍 Lower PAE = higher confidence in the spatial arrangement between proteins.

---

## 🧠 How to Use
1. 🔧 Make sure your AlphaFold3 `summary_confidences_*.json` files are organized in folders by mutant type.
2. 📝 Update the `folder_configs` section of the script to reflect:
   - The base directory for each mutant
   - The file prefix (shared by all 5 model files)
   - A readable name for labeling
3. ▶️ Run the script in R.
4. 📂 Open the Excel file and compare the interaction confidence scores across mutants and models.

---

## 📦 Dependencies
Install the required R packages using:
```R
install.packages("jsonlite")
install.packages("openxlsx")
```

---

## 💻 Full R Script
```r
# Load required libraries
library(jsonlite)  # For JSON processing
library(openxlsx)  # For writing to Excel

# Define the folder configurations
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
```

---

## 🔓 License
MIT License

---

## 👨‍🔬 Author
**Arrosan Rajalingam** – [a.rajalingam.23@abdn.ac.uk](mailto:a.rajalingam.23@abdn.ac.uk)  
Murakami Lab
University of Aberdeen

Feel free to contribute, fork, or adapt this for other multimeric complexes or additional metrics!

