# =============================================================================
# Seasonal Climate Variability — Northwest Bangladesh
# Period: 1973–2023
#
# Seasons:
#   Winter       = December–January–February (DJF)
#   Pre-monsoon  = March–April–May (MAM)
#   Monsoon      = June–September (JJAS)
#   Post-monsoon = October–November (ON)
#
# December is assigned to the following winter season. Thus, for example,
# Winter 1974 = Dec 1973 + Jan 1974 + Feb 1974.
#
# Rainfall is summed within each season-year; the other variables are averaged.
# The resulting seasonal values are then summarized across complete seasons.
#
# Outputs:
#   Temperature_Seasonal.png
#   Rainfall_Seasonal.png
#   Humidity_Seasonal.png
#   WindSpeed_Seasonal.png
#   Seasonal_Climatic_Table.csv
#   Seasonal_Climatic_Table_with_SD.csv
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
SEASON_LEVELS <- c("Winter", "Pre-monsoon", "Monsoon", "Post-monsoon")

VARIABLES <- list(
  Temperature = list(input = "MeanTemp_Monthly_Combined.csv", agg = "mean",
                     ylab = "Mean Temperature (°C)",
                     title = "Seasonal Temperature Variability",
                     output = "Temperature_Seasonal.png"),
  Rainfall = list(input = "Rainfall_Monthly_Combined.csv", agg = "sum",
                  ylab = "Total Rainfall (mm)",
                  title = "Seasonal Rainfall Variability",
                  output = "Rainfall_Seasonal.png"),
  Humidity = list(input = "Humidity_Monthly_Combined.csv", agg = "mean",
                  ylab = "Relative Humidity (%)",
                  title = "Seasonal Relative Humidity Variability",
                  output = "Humidity_Seasonal.png"),
  Wind_Speed = list(input = "WindSpeed_Monthly_Combined.csv", agg = "mean",
                    ylab = "Wind Speed (m/s)",
                    title = "Seasonal Wind Speed Variability",
                    output = "WindSpeed_Seasonal.png")
)

parse_dates <- function(x) {
  as.Date(suppressWarnings(parse_date_time(as.character(x),
                                            orders = c("dmy", "ymd", "mdy"))))
}

month_to_season <- function(month) {
  case_when(
    month %in% c(12, 1, 2) ~ "Winter",
    month %in% c(3, 4, 5) ~ "Pre-monsoon",
    month %in% c(6, 7, 8, 9) ~ "Monsoon",
    month %in% c(10, 11) ~ "Post-monsoon"
  )
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
      Season = month_to_season(Month),
      Season_Year = if_else(Month == 12, Year + 1L, Year),
      Value = as.numeric(Value)
    ) %>%
    filter(is.finite(Value))
}

summarise_seasonal <- function(df, agg) {
  # Keep only complete four-month/three-month seasonal groups.
  required_months <- tibble(
    Season = SEASON_LEVELS,
    n_required = c(3L, 3L, 4L, 2L)
  )

  seasonal_year <- df %>%
    group_by(District, Season_Year, Season) %>%
    summarise(
      n_months = n_distinct(Month),
      Value = if (agg == "sum") sum(Value) else mean(Value),
      .groups = "drop"
    ) %>%
    left_join(required_months, by = "Season") %>%
    filter(n_months == n_required)

  seasonal_year %>%
    group_by(District, Season) %>%
    summarise(
      Mean = mean(Value),
      SD = sd(Value),
      N_Years = n(),
      .groups = "drop"
    ) %>%
    mutate(
      District = factor(District, levels = DISTRICTS),
      Season = factor(Season, levels = SEASON_LEVELS)
    )
}

plot_seasonal <- function(stats, cfg) {
  ggplot(stats, aes(Season, Mean, color = District, group = District)) +
    geom_errorbar(aes(ymin = Mean - SD, ymax = Mean + SD),
                  width = 0.12, alpha = 0.5,
                  position = position_dodge(width = 0.25)) +
    geom_line(linewidth = 1, position = position_dodge(width = 0.25)) +
    geom_point(size = 2.5, position = position_dodge(width = 0.25)) +
    scale_color_manual(values = DISTRICT_COLORS) +
    labs(
      title = paste0(cfg$title, " (1973–2023)"),
      x = "Season", y = cfg$ylab, color = "District"
    ) +
    theme_bw(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
}

all_stats <- list()

for (vname in names(VARIABLES)) {
  cfg <- VARIABLES[[vname]]
  if (!file.exists(cfg$input)) {
    warning("Input not found; skipped: ", cfg$input)
    next
  }

  dat <- load_monthly(cfg$input)
  stats <- summarise_seasonal(dat, cfg$agg)
  all_stats[[vname]] <- stats %>% mutate(Variable = vname)

  ggsave(cfg$output, plot_seasonal(stats, cfg),
         width = 9, height = 6, dpi = 300)
  cat("Saved:", cfg$output, "\n")
}

if (length(all_stats) > 0) {
  combined <- bind_rows(all_stats)

  main_table <- combined %>%
    select(District, Season, Variable, Mean) %>%
    pivot_wider(names_from = Variable, values_from = Mean) %>%
    rename_with(~ paste0(.x, "_Mean"), -c(District, Season)) %>%
    arrange(District, Season)

  write_csv(main_table, "Seasonal_Climatic_Table.csv")

  sd_table <- combined %>%
    select(District, Season, Variable, Mean, SD, N_Years) %>%
    arrange(District, Season, Variable)

  write_csv(sd_table, "Seasonal_Climatic_Table_with_SD.csv")
}

cat("\nSeasonal climate variability analysis complete.\n")
