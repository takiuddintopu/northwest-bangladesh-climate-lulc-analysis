# =============================================================================
# Annual Climate Trend Analysis — Northwest Bangladesh
# Period: 1973–2023
# Methods: Mann–Kendall test and Sen's slope estimator
#
# Inputs:
#   Annual_Rainfall_Combined.csv
#   Annual_Mean_Temp_Combined.csv
#   Annual_Humidity_Combined.csv
#   Annual_WindSpeed_Combined.csv
#
# Expected format:
#   First column: Year (or a parseable date)
#   Remaining columns: district values; district names must appear in headers.
#
# Outputs:
#   <Variable>_MannKendall_Trend.png
#   <Variable>_MannKendall_Sen_Stats.csv
# =============================================================================

required_packages <- c("readr", "dplyr", "tidyr", "lubridate",
                       "ggplot2", "Kendall", "trend", "scales")
missing <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  stop("Install required packages first: ", paste(missing, collapse = ", "))
}

library(readr)
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(Kendall)
library(trend)
library(scales)

START_YEAR <- 1973
END_YEAR <- 2023

DISTRICTS <- c("Rajshahi", "Pabna", "Natore", "Bogura")
DISTRICT_COLORS <- c(Rajshahi = "#E63946", Pabna = "#2A9D8F",
                     Natore = "#E9C46A", Bogura = "#457B9D")

VARIABLES <- list(
  Rainfall = list(
    input = "Annual_Rainfall_Combined.csv",
    unit = "mm/yr",
    ylab = "Annual Rainfall (mm)",
    title = "Annual Rainfall Trends (1973–2023)",
    out_png = "Rainfall_MannKendall_Trend.png",
    out_csv = "Rainfall_MannKendall_Sen_Stats.csv"
  ),
  Mean_Temp = list(
    input = "Annual_Mean_Temp_Combined.csv",
    unit = "°C/yr",
    ylab = "Annual Mean Temperature (°C)",
    title = "Annual Mean Temperature Trends (1973–2023)",
    out_png = "MeanTemp_MannKendall_Trend.png",
    out_csv = "MeanTemp_MannKendall_Sen_Stats.csv"
  ),
  Humidity = list(
    input = "Annual_Humidity_Combined.csv",
    unit = "%/yr",
    ylab = "Annual Mean Relative Humidity (%)",
    title = "Annual Mean Relative Humidity Trends (1973–2023)",
    out_png = "Humidity_MannKendall_Trend.png",
    out_csv = "Humidity_MannKendall_Sen_Stats.csv"
  ),
  Wind_Speed = list(
    input = "Annual_WindSpeed_Combined.csv",
    unit = "m/s/yr",
    ylab = "Annual Mean Wind Speed (m/s)",
    title = "Annual Mean Wind Speed Trends (1973–2023)",
    out_png = "WindSpeed_MannKendall_Trend.png",
    out_csv = "WindSpeed_MannKendall_Sen_Stats.csv"
  )
)

load_annual <- function(path) {
  raw <- read_csv(path, show_col_types = FALSE)
  names(raw) <- trimws(names(raw))
  first_col <- names(raw)[1]

  if (toupper(first_col) == "YEAR") {
    raw$Year <- as.integer(raw[[first_col]])
  } else {
    raw$Year <- suppressWarnings(year(parse_date_time(
      as.character(raw[[first_col]]),
      orders = c("dmy", "ymd", "mdy")
    )))
  }

  if (all(is.na(raw$Year))) {
    stop("Could not identify years in: ", basename(path))
  }

  raw <- raw %>%
    filter(Year >= START_YEAR, Year <= END_YEAR)

  data_cols <- setdiff(names(raw), c(first_col, "Date", "Year"))

  matched <- vapply(data_cols, function(cn) {
    hit <- DISTRICTS[grepl(DISTRICTS, cn, ignore.case = TRUE)]
    if (length(hit) == 0) NA_character_ else hit[1]
  }, character(1))

  keep <- data_cols[!is.na(matched)]
  if (length(keep) == 0) {
    stop("No district columns were detected in: ", basename(path))
  }

  result <- raw[, c("Year", keep)]
  names(result) <- c("Year", matched[!is.na(matched)])

  result %>%
    pivot_longer(-Year, names_to = "District", values_to = "Value") %>%
    filter(is.finite(Value)) %>%
    group_by(District, Year) %>%
    summarise(Value = mean(Value), .groups = "drop") %>%
    arrange(District, Year)
}

run_mk_sen <- function(df, unit) {
  bind_rows(lapply(split(df, df$District), function(sub) {
    sub <- sub[order(sub$Year), ]
    x <- sub$Value

    if (length(x) < 5) stop("Too few observations for ", unique(sub$District))

    mk <- MannKendall(x)
    sen <- sens.slope(x)

    data.frame(
      District = unique(sub$District),
      N_Years = length(x),
      Mean = mean(x),
      SD = sd(x),
      Sen_Slope = as.numeric(sen$estimates),
      Sen_Slope_Unit = unit,
      MK_Tau = as.numeric(mk$tau),
      MK_Pvalue = as.numeric(mk$sl),
      MK_Sig = ifelse(mk$sl < 0.001, "***",
                      ifelse(mk$sl < 0.01, "**",
                             ifelse(mk$sl < 0.05, "*", "ns")))
    )
  }))
}

build_plot <- function(df, stats, cfg) {
  plot_df <- df %>%
    left_join(stats[, c("District", "Sen_Slope")], by = "District") %>%
    group_by(District) %>%
    mutate(
      midpoint_year = median(Year),
      midpoint_value = median(Value),
      Sen_Trend = midpoint_value + Sen_Slope * (Year - midpoint_year),
      District = factor(District, levels = DISTRICTS)
    ) %>%
    ungroup()

  labels <- stats %>%
    mutate(label = sprintf(
      "Sen = %+.3f %s; τ = %.3f; p = %.4g %s",
      Sen_Slope, cfg$unit, MK_Tau, MK_Pvalue, MK_Sig
    ))

  ggplot(plot_df, aes(Year, Value, color = District)) +
    geom_point(size = 1.5, alpha = 0.6) +
    geom_line(aes(y = Sen_Trend), linewidth = 0.9, linetype = "dashed") +
    facet_wrap(~District, ncol = 2) +
    scale_color_manual(values = DISTRICT_COLORS, guide = "none") +
    scale_x_continuous(breaks = seq(START_YEAR, END_YEAR, by = 10)) +
    scale_y_continuous(labels = comma) +
    labs(
      title = cfg$title,
      subtitle = "Dashed line = Sen's slope trend",
      x = "Year",
      y = cfg$ylab,
      caption = paste(labels$label, collapse = "   |   ")
    ) +
    theme_bw(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5),
      plot.caption = element_text(size = 8, hjust = 0),
      axis.title = element_text(face = "bold"),
      panel.grid.minor = element_blank()
    )
}

for (cfg in VARIABLES) {
  if (!file.exists(cfg$input)) {
    warning("Input not found; skipped: ", cfg$input)
    next
  }

  cat("\nProcessing:", cfg$input, "\n")
  dat <- load_annual(cfg$input)
  stats <- run_mk_sen(dat, cfg$unit)

  write_csv(stats, cfg$out_csv)
  ggsave(cfg$out_png, build_plot(dat, stats, cfg),
         width = 10, height = 7, dpi = 300)

  print(stats)
}

cat("\nAnnual climate trend analysis complete.\n")
