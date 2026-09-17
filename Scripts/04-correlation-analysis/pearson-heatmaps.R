# =============================================================================
# Pearson Correlation Heatmaps — Northwest Bangladesh
# Period: 1973–2023
#
# Produces one Pearson heatmap for each district and one for the regional mean.
# Significance stars are based on pairwise Pearson correlation tests.
#
# Inputs:
#   All_Parameters_<District>_Annual.csv
#
# Required columns:
#   Year, Annual_Mean_Temp, Annual_Rainfall,
#   Annual_Mean_Humidity, Annual_Mean_Wind_Speed
#
# Outputs:
#   <District>_Pearson_Heatmap.png
#   Regional_Mean_Pearson_Heatmap.png
# =============================================================================

required_packages <- c("readr", "dplyr", "tidyr", "ggplot2")
missing <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) stop("Install required packages first: ", paste(missing, collapse = ", "))

library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

START_YEAR <- 1973
END_YEAR <- 2023

VAR_COLS <- c("Annual_Mean_Temp", "Annual_Rainfall",
              "Annual_Mean_Humidity", "Annual_Mean_Wind_Speed")

VAR_LABELS <- c(
  Annual_Mean_Temp = "Temperature",
  Annual_Rainfall = "Rainfall",
  Annual_Mean_Humidity = "Humidity",
  Annual_Mean_Wind_Speed = "Wind Speed"
)

files <- list.files(".", pattern = "^All_Parameters_.*_Annual\\.csv$", full.names = TRUE)
if (length(files) == 0) stop("No All_Parameters_*_Annual.csv files were found.")

read_one <- function(path) {
  district <- sub("^All_Parameters_(.*)_Annual\\.csv$", "\\1", basename(path))

  df <- read_csv(path, show_col_types = FALSE)

  needed <- c("Year", VAR_COLS)
  missing_cols <- setdiff(needed, names(df))
  if (length(missing_cols) > 0) {
    stop("Missing columns in ", basename(path), ": ",
         paste(missing_cols, collapse = ", "))
  }

  df %>%
    select(Year, all_of(VAR_COLS)) %>%
    mutate(
      Year = as.integer(Year),
      across(all_of(VAR_COLS), as.numeric)
    ) %>%
    filter(Year >= START_YEAR, Year <= END_YEAR) %>%
    mutate(District = district)
}

all_data <- bind_rows(lapply(files, read_one))

regional_data <- all_data %>%
  group_by(Year) %>%
  summarise(
    across(all_of(VAR_COLS),
           ~ if (all(is.na(.x))) NA_real_ else mean(.x, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  mutate(District = "Regional_Mean")

pearson_p_matrix <- function(df) {
  n <- length(VAR_COLS)
  p <- matrix(NA_real_, n, n,
              dimnames = list(VAR_COLS, VAR_COLS))

  for (i in seq_len(n)) {
    for (j in seq_len(n)) {
      if (i == j) {
        p[i, j] <- 0
      } else {
        ok <- complete.cases(df[[VAR_COLS[i]]], df[[VAR_COLS[j]]])
        if (sum(ok) >= 3) {
          p[i, j] <- cor.test(
            df[[VAR_COLS[i]]][ok],
            df[[VAR_COLS[j]]][ok],
            method = "pearson"
          )$p.value
        }
      }
    }
  }
  p
}

build_pearson_heatmap <- function(df, title_prefix) {
  mat <- cor(df[, VAR_COLS],
             method = "pearson",
             use = "pairwise.complete.obs")

  pmat <- pearson_p_matrix(df)

  plot_df <- as.data.frame(as.table(mat), stringsAsFactors = FALSE) %>%
    rename(Variable_1 = Var1, Variable_2 = Var2, r = Freq) %>%
    mutate(
      p = as.vector(pmat),
      Variable_1 = factor(VAR_LABELS[Variable_1],
                          levels = unname(VAR_LABELS)),
      Variable_2 = factor(VAR_LABELS[Variable_2],
                          levels = rev(unname(VAR_LABELS))),
      Stars = case_when(
        Variable_1 == Variable_2 ~ "",
        p < 0.001 ~ "***",
        p < 0.01 ~ "**",
        p < 0.05 ~ "*",
        TRUE ~ ""
      ),
      Label = ifelse(Variable_1 == Variable_2,
                     sprintf("%.2f", r),
                     sprintf("%.2f%s", r, Stars))
    )

  ggplot(plot_df, aes(Variable_1, Variable_2, fill = r)) +
    geom_tile(color = "white", linewidth = 0.7) +
    geom_text(aes(label = Label), size = 4) +
    scale_fill_gradient2(limits = c(-1, 1), midpoint = 0,
                         name = "Pearson r") +
    coord_fixed() +
    labs(
      title = paste0("Pearson Correlation — ", title_prefix),
      subtitle = "* p < 0.05, ** p < 0.01, *** p < 0.001",
      x = NULL, y = NULL
    ) +
    theme_bw(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5),
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.grid = element_blank()
    )
}

run_all <- c(split(all_data, all_data$District),
             list(Regional_Mean = regional_data))

for (name in names(run_all)) {
  df <- run_all[[name]]

  p <- build_pearson_heatmap(df, name)

  output_name <- if (name == "Regional_Mean") {
    "Regional_Mean_Pearson_Heatmap.png"
  } else {
    paste0(name, "_Pearson_Heatmap.png")
  }

  ggsave(output_name, p, width = 7, height = 6, dpi = 300)
  cat("Saved:", output_name, "\n")
}

cat("\nPearson heatmap analysis complete.\n")
