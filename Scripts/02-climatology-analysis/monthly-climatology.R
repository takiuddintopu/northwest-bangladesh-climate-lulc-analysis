# =============================================================================
# Monthly Climate Climatology — Northwest Bangladesh
# Period: 1973–2023
#
# Rainfall is summed within each year-month and then averaged across years.
# Temperature, relative humidity, and wind speed are averaged within each
# year-month and then averaged across years.
#
# Inputs:
#   MeanTemp_Monthly_Combined.csv
#   Rainfall_Monthly_Combined.csv
#   Humidity_Monthly_Combined.csv
#   WindSpeed_Monthly_Combined.csv
#
# Outputs:
#   Temperature_MonthlyClimatology.png
#   Rainfall_MonthlyClimatology.png
#   Humidity_MonthlyClimatology.png
#   WindSpeed_MonthlyClimatology.png
# =============================================================================

required_packages <- c("readr", "dplyr", "tidyr", "lubridate", "ggplot2")
missing <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) stop("Install required packages first: ", paste(missing, collapse = ", "))

library(readr)
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)

START_YEAR <- 1973
END_YEAR <- 2023

DISTRICTS <- c("Rajshahi", "Pabna", "Natore", "Bogura")
DISTRICT_ALIASES <- list(
  Rajshahi = c("Rajshahi", "Rajshai"),
  Pabna = c("Pabna"),
  Natore = c("Natore"),
  Bogura = c("Bogura", "Bogra")
)
DISTRICT_COLORS <- c(Rajshahi = "#E63946", Pabna = "#2A9D8F",
                     Natore = "#E9C46A", Bogura = "#457B9D")

VARIABLES <- list(
  Temperature = list(
    input = "MeanTemp_Monthly_Combined.csv",
    agg = "mean",
    ylab = "Mean Temperature (°C)",
    title = "Monthly Temperature Climatology (1973–2023)",
    output = "Temperature_MonthlyClimatology.png"
  ),
  Rainfall = list(
    input = "Rainfall_Monthly_Combined.csv",
    agg = "sum",
    ylab = "Total Rainfall (mm)",
    title = "Monthly Rainfall Climatology (1973–2023)",
    output = "Rainfall_MonthlyClimatology.png"
  ),
  Humidity = list(
    input = "Humidity_Monthly_Combined.csv",
    agg = "mean",
    ylab = "Relative Humidity (%)",
    title = "Monthly Relative Humidity Climatology (1973–2023)",
    output = "Humidity_MonthlyClimatology.png"
  ),
  Wind_Speed = list(
    input = "WindSpeed_Monthly_Combined.csv",
    agg = "mean",
    ylab = "Wind Speed (m/s)",
    title = "Monthly Wind Speed Climatology (1973–2023)",
    output = "WindSpeed_MonthlyClimatology.png"
  )
)

parse_dates <- function(x) {
  d <- suppressWarnings(parse_date_time(as.character(x),
                                         orders = c("dmy", "ymd", "mdy")))
  as.Date(d)
}

load_monthly <- function(path) {
  raw <- read_csv(path, show_col_types = FALSE)
  names(raw) <- trimws(names(raw))

  date_col <- names(raw)[1]
  raw$Date <- parse_dates(raw[[date_col]])

  if (all(is.na(raw$Date))) stop("Could not parse dates in: ", basename(path))

  raw <- raw %>%
    filter(year(Date) >= START_YEAR, year(Date) <= END_YEAR)

  data_cols <- setdiff(names(raw), c(date_col, "Date"))

  matched <- vapply(data_cols, function(cn) {
    hits <- names(DISTRICT_ALIASES)[vapply(
      DISTRICT_ALIASES,
      function(a) any(vapply(a, function(x) grepl(x, cn, ignore.case = TRUE), logical(1))),
      logical(1)
    )]
    if (length(hits) == 0) NA_character_ else hits[1]
  }, character(1))

  keep <- data_cols[!is.na(matched)]
  if (length(keep) == 0) stop("No district columns detected in: ", basename(path))

  result <- raw[, c("Date", keep)]
  names(result) <- c("Date", matched[!is.na(matched)])

  result %>%
    pivot_longer(-Date, names_to = "District", values_to = "Value") %>%
    mutate(
      Year = year(Date),
      Month = month(Date),
      Value = as.numeric(Value)
    ) %>%
    filter(is.finite(Value))
}

summarise_climatology <- function(df, agg) {
  yearly_monthly <- df %>%
    group_by(District, Year, Month) %>%
    summarise(
      Value = if (agg == "sum") sum(Value) else mean(Value),
      .groups = "drop"
    )

  yearly_monthly %>%
    group_by(District, Month) %>%
    summarise(
      Mean = mean(Value),
      SD = sd(Value),
      N_Years = n(),
      .groups = "drop"
    ) %>%
    mutate(
      District = factor(District, levels = DISTRICTS),
      Month = factor(Month, levels = 1:12, labels = month.abb)
    )
}

plot_climatology <- function(stats, cfg) {
  ggplot(stats, aes(Month, Mean, color = District, group = District)) +
    geom_ribbon(aes(ymin = Mean - SD, ymax = Mean + SD, fill = District),
                alpha = 0.12, color = NA) +
    geom_line(linewidth = 1) +
    geom_point(size = 1.8) +
    scale_color_manual(values = DISTRICT_COLORS) +
    scale_fill_manual(values = DISTRICT_COLORS, guide = "none") +
    labs(title = cfg$title, x = "Month", y = cfg$ylab, color = "District") +
    theme_bw(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}

for (cfg in VARIABLES) {
  if (!file.exists(cfg$input)) {
    warning("Input not found; skipped: ", cfg$input)
    next
  }

  dat <- load_monthly(cfg$input)
  stats <- summarise_climatology(dat, cfg$agg)

  ggsave(cfg$output, plot_climatology(stats, cfg),
         width = 9, height = 6, dpi = 300)

  cat("Saved:", cfg$output, "\n")
}

cat("\nMonthly climatology analysis complete.\n")
