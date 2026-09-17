# =============================================================================
# Climate Correlation Analysis — Northwest Bangladesh
# Period: 1973–2023
#
# Correlations:
#   Pearson   — linear association
#   Spearman  — rank-based monotonic association
#   Kendall   — rank-based monotonic association
#
# The tests describe statistical association; they do not establish causation.
#
# Inputs:
#   All_Parameters_<District>_Annual.csv
#
# Required columns:
#   Year, Annual_Mean_Temp, Annual_Rainfall,
#   Annual_Mean_Humidity, Annual_Mean_Wind_Speed
#
# Outputs:
#   <District>_Correlation_Table.csv
#   <District>_Correlation_Table.png
#   <District>_Correlation_Heatmap.png
#   <District>_TempHumidity_Scatter.png
#   Regional_Mean_* equivalents
# =============================================================================

required_packages <- c("readr", "dplyr", "tidyr", "stringr", "ggplot2")
missing <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) stop("Install required packages first: ", paste(missing, collapse = ", "))

library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

START_YEAR <- 1973
END_YEAR <- 2023

VAR_COLS <- c(
  "Annual_Mean_Temp",
  "Annual_Rainfall",
  "Annual_Mean_Humidity",
  "Annual_Mean_Wind_Speed"
)

VAR_LABELS <- c(
  Annual_Mean_Temp = "Temperature",
  Annual_Rainfall = "Rainfall",
  Annual_Mean_Humidity = "Humidity",
  Annual_Mean_Wind_Speed = "Wind Speed"
)

read_one <- function(path) {
  district <- sub("^All_Parameters_(.*)_Annual\\.csv$", "\\1", basename(path))

  df <- read_csv(path, show_col_types = FALSE)

  missing_cols <- setdiff(c("Year", VAR_COLS), names(df))
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

files <- list.files(".", pattern = "^All_Parameters_.*_Annual\\.csv$", full.names = TRUE)
if (length(files) == 0) stop("No All_Parameters_*_Annual.csv files were found.")

all_district_data <- bind_rows(lapply(files, read_one))

# Regional annual series = mean across districts available in each year.
regional_data <- all_district_data %>%
  group_by(Year) %>%
  summarise(
    across(all_of(VAR_COLS), ~ if (all(is.na(.x))) NA_real_ else mean(.x, na.rm = TRUE)),
    N_Districts = sum(complete.cases(across(all_of(VAR_COLS)))),
    .groups = "drop"
  ) %>%
  mutate(District = "Regional_Mean")

# -----------------------------------------------------------------------------
# Correlation helper
# -----------------------------------------------------------------------------

test_pair <- function(x, y, method) {
  ok <- complete.cases(x, y)
  x <- x[ok]
  y <- y[ok]

  if (length(x) < 3) {
    return(c(coef = NA_real_, p = NA_real_, n = length(x)))
  }

  test <- suppressWarnings(cor.test(x, y, method = method, exact = FALSE))

  c(
    coef = unname(test$estimate),
    p = test$p.value,
    n = length(x)
  )
}

build_corr_table <- function(df) {
  pairs <- combn(VAR_COLS, 2, simplify = FALSE)

  bind_rows(lapply(pairs, function(pair) {
    pear <- test_pair(df[[pair[1]]], df[[pair[2]]], "pearson")
    spear <- test_pair(df[[pair[1]]], df[[pair[2]]], "spearman")
    kend <- test_pair(df[[pair[1]]], df[[pair[2]]], "kendall")

    data.frame(
      Variable_1 = unname(VAR_LABELS[pair[1]]),
      Variable_2 = unname(VAR_LABELS[pair[2]]),
      N_Pearson = pear["n"],
      Pearson_r = pear["coef"],
      Pearson_p = pear["p"],
      N_Spearman = spear["n"],
      Spearman_rho = spear["coef"],
      Spearman_p = spear["p"],
      N_Kendall = kend["n"],
      Kendall_tau = kend["coef"],
      Kendall_p = kend["p"]
    )
  })) %>%
    mutate(
      across(where(is.numeric), ~ round(.x, 4))
    )
}

correlation_matrix <- function(df, method) {
  mat <- as.matrix(df[, VAR_COLS])
  r <- as.data.frame(cor(mat, method = method, use = "pairwise.complete.obs"))
  r$Variable_1 <- rownames(r)

  r %>%
    select(Variable_1, everything()) %>%
    pivot_longer(-Variable_1, names_to = "Variable_2", values_to = "Coefficient")
}

p_matrix <- function(df, method) {
  nvar <- length(VAR_COLS)
  p <- matrix(NA_real_, nvar, nvar,
              dimnames = list(VAR_COLS, VAR_COLS))

  for (i in seq_len(nvar)) {
    for (j in seq_len(nvar)) {
      if (i == j) {
        p[i, j] <- 0
      } else {
        p[i, j] <- test_pair(df[[VAR_COLS[i]]],
                             df[[VAR_COLS[j]]], method)["p"]
      }
    }
  }
  p
}

# -----------------------------------------------------------------------------
# Heatmap with one panel per correlation method
# -----------------------------------------------------------------------------

build_heatmap <- function(df, title_prefix) {
  methods <- c("pearson", "spearman", "kendall")

  plot_data <- bind_rows(lapply(methods, function(method) {
    r <- correlation_matrix(df, method)
    p <- p_matrix(df, method)

    r %>%
      mutate(
        Method = method,
        P_value = as.vector(p[match(Variable_1, rownames(p)),
                              match(Variable_2, colnames(p))])
      )
  })) %>%
    mutate(
      Variable_1 = factor(VAR_LABELS[Variable_1], levels = unname(VAR_LABELS)),
      Variable_2 = factor(VAR_LABELS[Variable_2], levels = rev(unname(VAR_LABELS))),
      Sig = case_when(
        P_value < 0.001 ~ "***",
        P_value < 0.01 ~ "**",
        P_value < 0.05 ~ "*",
        TRUE ~ ""
      ),
      Label = sprintf("%.2f%s", Coefficient, Sig),
      Method = factor(Method, levels = methods,
                      labels = c("Pearson", "Spearman", "Kendall"))
    )

  ggplot(plot_data, aes(Variable_1, Variable_2, fill = Coefficient)) +
    geom_tile(color = "white") +
    geom_text(aes(label = Label), size = 3.6) +
    facet_wrap(~Method, nrow = 1) +
    scale_fill_gradient2(limits = c(-1, 1), midpoint = 0,
                         name = "Coefficient") +
    coord_fixed() +
    labs(
      title = paste0(title_prefix, " — Climate Variable Correlations"),
      subtitle = "* p < 0.05, ** p < 0.01, *** p < 0.001",
      x = NULL, y = NULL
    ) +
    theme_bw(base_size = 11) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5),
      axis.text.x = element_text(angle = 45, hjust = 1),
      panel.grid = element_blank(),
      legend.position = "right"
    )
}

# -----------------------------------------------------------------------------
# Temperature–humidity scatter
# -----------------------------------------------------------------------------

build_temp_humidity_scatter <- function(df, title_prefix) {
  ok <- complete.cases(df$Annual_Mean_Temp, df$Annual_Mean_Humidity)
  plot_df <- df[ok, ]

  pear <- test_pair(plot_df$Annual_Mean_Temp,
                    plot_df$Annual_Mean_Humidity, "pearson")
  spear <- test_pair(plot_df$Annual_Mean_Temp,
                     plot_df$Annual_Mean_Humidity, "spearman")
  kend <- test_pair(plot_df$Annual_Mean_Temp,
                    plot_df$Annual_Mean_Humidity, "kendall")

  label <- sprintf(
    "Pearson r = %.3f (p = %.3g)\nSpearman ρ = %.3f (p = %.3g)\nKendall τ = %.3f (p = %.3g)",
    pear["coef"], pear["p"], spear["coef"], spear["p"], kend["coef"], kend["p"]
  )

  ggplot(plot_df, aes(Annual_Mean_Temp, Annual_Mean_Humidity)) +
    geom_point(size = 2, alpha = 0.7) +
    geom_smooth(method = "lm", formula = y ~ x, se = TRUE) +
    annotate("label", x = Inf, y = Inf, label = label,
             hjust = 1.05, vjust = 1.1, size = 3.2) +
    labs(
      title = paste0(title_prefix, " — Temperature vs Relative Humidity"),
      subtitle = "Statistical association; not a causal test",
      x = "Annual Mean Temperature (°C)",
      y = "Annual Mean Relative Humidity (%)"
    ) +
    theme_bw(base_size = 12) +
    theme(plot.title = element_text(face = "bold", hjust = 0.5),
          plot.subtitle = element_text(hjust = 0.5))
}

# -----------------------------------------------------------------------------
# Run for each district and the regional mean
# -----------------------------------------------------------------------------

run_all <- c(split(all_district_data, all_district_data$District),
             list(Regional_Mean = regional_data))

for (name in names(run_all)) {
  df <- run_all[[name]]

  cat("\nProcessing:", name, "\n")

  table <- build_corr_table(df)
  write_csv(table, paste0(name, "_Correlation_Table.csv"))

  p_heat <- build_heatmap(df, name)
  ggsave(paste0(name, "_Correlation_Heatmap.png"),
         p_heat, width = 12, height = 5.5, dpi = 300)

  p_scatter <- build_temp_humidity_scatter(df, name)
  ggsave(paste0(name, "_TempHumidity_Scatter.png"),
         p_scatter, width = 8, height = 6, dpi = 300)

  print(table)
}

cat("\nClimate correlation analysis complete.\n")
