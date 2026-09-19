# =============================================================================
# GEV Analysis of Annual Maximum Monthly Rainfall
# Northwest Bangladesh | 1973–2023
#
# IMPORTANT:
# The input AMS series represents the ANNUAL MAXIMUM OF MONTHLY RAINFALL
# TOTALS, not annual maximum daily rainfall. Because complete daily data for
# the study period were not available, each year's largest monthly rainfall
# total is used as the block maximum.
#
# Methods:
#   - Mann–Kendall + Sen's slope: trend assessment of the AMS series
#   - GEV distribution fitted by maximum likelihood (ismev::gev.fit)
#   - Anderson–Darling statistic: goodness-of-fit diagnostic
#   - Parametric bootstrap: 95% confidence intervals for return levels
#
# Inputs:
#   AMS_<District>.csv
#   Required columns: Year, Max_Rainfall
#
# Outputs:
#   AMS_Trends.png
#   GEV_QQ_Diagnostics.png
#   GEV_ReturnLevels.png
#   GEV_Parameters_GOF.csv
#   GEV_ReturnLevels_Table.csv
# =============================================================================

required_packages <- c("readr", "dplyr", "purrr", "ggplot2",
                       "ismev", "evd", "goftest", "Kendall", "trend", "gridExtra")
missing <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) stop("Install required packages first: ", paste(missing, collapse = ", "))

library(readr)
library(dplyr)
library(purrr)
library(ggplot2)
library(ismev)
library(evd)
library(goftest)
library(Kendall)
library(trend)

set.seed(20260917)

START_YEAR <- 1973
END_YEAR <- 2023
EXPECTED_YEARS <- END_YEAR - START_YEAR + 1

DISTRICTS <- c("Rajshahi", "Pabna", "Natore", "Bogura")
DISTRICT_COLORS <- c(Rajshahi = "#E63946", Pabna = "#2A9D8F",
                     Natore = "#E9C46A", Bogura = "#457B9D")

RETURN_PERIODS <- c(2, 5, 10, 25, 50, 100)
N_BOOT <- 10000
N_BOOT_CURVE <- 1000

# -----------------------------------------------------------------------------
# 1. Load annual maximum monthly rainfall series
# -----------------------------------------------------------------------------

files <- list.files(".", pattern = "^AMS_.*\\.csv$", full.names = TRUE)
if (length(files) == 0) stop("No AMS_*.csv files were found in the working directory.")

read_ams <- function(path) {
  district <- sub("^AMS_(.*)\\.csv$", "\\1", basename(path))

  df <- read_csv(path, show_col_types = FALSE)
  names(df) <- trimws(names(df))

  required <- c("Year", "Max_Rainfall")
  if (!all(required %in% names(df))) {
    # Allow the rainfall column to have another name, provided Year exists.
    if (!"Year" %in% names(df)) {
      stop("File ", basename(path), " must contain a Year column.")
    }

    value_candidates <- setdiff(names(df), "Year")
    if (length(value_candidates) != 1) {
      stop("File ", basename(path),
           " must contain Year plus one rainfall-value column.")
    }
    names(df)[names(df) == value_candidates[1]] <- "Max_Rainfall"
  }

  df %>%
    transmute(
      District = district,
      Year = as.integer(Year),
      Max_Rainfall = as.numeric(Max_Rainfall)
    ) %>%
    filter(Year >= START_YEAR, Year <= END_YEAR) %>%
    filter(is.finite(Max_Rainfall)) %>%
    arrange(Year)
}

ams_data <- map_dfr(files, read_ams)

# Check for duplicate year entries within district.
duplicates <- ams_data %>%
  count(District, Year) %>%
  filter(n > 1)

if (nrow(duplicates) > 0) {
  stop("Duplicate Year entries found within district. Resolve them before GEV fitting.")
}

coverage <- ams_data %>%
  group_by(District) %>%
  summarise(
    First_Year = min(Year),
    Last_Year = max(Year),
    N_Years = n(),
    .groups = "drop"
  )

print(coverage)

if (any(coverage$N_Years != EXPECTED_YEARS)) {
  warning("At least one district does not contain all 51 years (1973–2023). ",
          "GEV estimates will use the available years.")
}

# -----------------------------------------------------------------------------
# 2. Trend assessment of the AMS series
# -----------------------------------------------------------------------------

run_mk_sen <- function(df) {
  df <- arrange(df, Year)
  x <- df$Max_Rainfall

  mk <- MannKendall(x)
  sen <- sens.slope(x)

  data.frame(
    District = unique(df$District),
    N_Years = length(x),
    MK_Tau = as.numeric(mk$tau),
    MK_Pvalue = as.numeric(mk$sl),
    Sen_Slope = as.numeric(sen$estimates),
    Sen_Slope_Unit = "mm/yr",
    MK_Sig = ifelse(mk$sl < 0.001, "***",
                    ifelse(mk$sl < 0.01, "**",
                           ifelse(mk$sl < 0.05, "*", "ns")))
  )
}

mk_results <- ams_data %>%
  group_split(District) %>%
  map_dfr(run_mk_sen)

# A non-significant trend test is not proof of stationarity. The result is
# therefore reported as a trend assessment used to evaluate evidence of
# temporal non-stationarity before fitting a stationary GEV model.

# -----------------------------------------------------------------------------
# 3. Fit stationary GEV models by maximum likelihood
# -----------------------------------------------------------------------------

fit_gev <- function(x) {
  fit <- ismev::gev.fit(x, show = FALSE)

  list(
    mu = unname(fit$mle[1]),
    sigma = unname(fit$mle[2]),
    xi = unname(fit$mle[3]),
    mu_se = unname(fit$se[1]),
    sigma_se = unname(fit$se[2]),
    xi_se = unname(fit$se[3]),
    nllh = unname(fit$nllh),
    n = length(x)
  )
}

gev_fits <- list()

for (d in DISTRICTS) {
  x <- ams_data$Max_Rainfall[ams_data$District == d]

  if (length(x) == 0) {
    warning("No AMS data found for ", d, "; skipping.")
    next
  }

  fit <- tryCatch(
    fit_gev(x),
    error = function(e) stop("GEV fitting failed for ", d, ": ", conditionMessage(e))
  )

  gev_fits[[d]] <- list(District = d, x = x, fit = fit)
}

# -----------------------------------------------------------------------------
# 4. GEV parameter and goodness-of-fit diagnostic table
# -----------------------------------------------------------------------------

build_gev_table <- function(g) {
  f <- g$fit
  ad <- tryCatch(
    goftest::ad.test(
      g$x, "pgev",
      loc = f$mu, scale = f$sigma, shape = f$xi
    ),
    error = function(e) NULL
  )

  data.frame(
    District = g$District,
    N_Years = f$n,
    Mu = f$mu,
    Mu_SE = f$mu_se,
    Sigma = f$sigma,
    Sigma_SE = f$sigma_se,
    Xi = f$xi,
    Xi_SE = f$xi_se,
    NLLH = f$nllh,
    AIC = 2 * f$nllh + 2 * 3,
    AD_Statistic = if (is.null(ad)) NA_real_ else as.numeric(ad$statistic),
    AD_Pvalue_Diagnostic = if (is.null(ad)) NA_real_ else ad$p.value
  )
}

gev_table <- map_dfr(gev_fits, build_gev_table)
write_csv(gev_table, "GEV_Parameters_GOF.csv")

# -----------------------------------------------------------------------------
# 5. Return levels and parametric-bootstrap confidence intervals
# -----------------------------------------------------------------------------

return_level <- function(mu, sigma, xi, T) {
  evd::qgev(1 - 1 / T, loc = mu, scale = sigma, shape = xi)
}

bootstrap_return_levels <- function(g, periods, n_boot) {
  f0 <- g$fit
  n <- length(g$x)

  estimate <- return_level(f0$mu, f0$sigma, f0$xi, periods)
  boot <- matrix(NA_real_, nrow = n_boot, ncol = length(periods))

  for (b in seq_len(n_boot)) {
    xb <- tryCatch(
      evd::rgev(n, loc = f0$mu, scale = f0$sigma, shape = f0$xi),
      error = function(e) NULL
    )
    if (is.null(xb)) next

    fb <- tryCatch(
      ismev::gev.fit(xb, show = FALSE),
      error = function(e) NULL
    )
    if (is.null(fb)) next

    vals <- tryCatch(
      return_level(fb$mle[1], fb$mle[2], fb$mle[3], periods),
      error = function(e) rep(NA_real_, length(periods))
    )

    if (all(is.finite(vals))) boot[b, ] <- vals
  }

  successful <- colSums(is.finite(boot))

  lower <- apply(boot, 2, quantile, probs = 0.025, na.rm = TRUE)
  upper <- apply(boot, 2, quantile, probs = 0.975, na.rm = TRUE)

  data.frame(
    District = g$District,
    Return_Period_Years = periods,
    Estimate_mm = estimate,
    Lower_CI_mm = lower,
    Upper_CI_mm = upper,
    Successful_Bootstraps = successful,
    Bootstrap_Success_Rate = successful / n_boot
  )
}

return_table <- map_dfr(
  gev_fits,
  ~ bootstrap_return_levels(.x, RETURN_PERIODS, N_BOOT)
)

write_csv(return_table, "GEV_ReturnLevels_Table.csv")

# -----------------------------------------------------------------------------
# 6. Figure: AMS trends
# -----------------------------------------------------------------------------

trend_plot_data <- ams_data %>%
  left_join(mk_results[, c("District", "Sen_Slope")], by = "District") %>%
  group_by(District) %>%
  mutate(
    midpoint_year = median(Year),
    midpoint_value = median(Max_Rainfall),
    Sen_Trend = midpoint_value + Sen_Slope * (Year - midpoint_year),
    District = factor(District, levels = DISTRICTS)
  ) %>%
  ungroup()

p1 <- ggplot(trend_plot_data, aes(Year, Max_Rainfall)) +
  geom_point(aes(color = District), size = 1.6, alpha = 0.7) +
  geom_line(aes(y = Sen_Trend, color = District),
            linewidth = 0.8, linetype = "dashed") +
  facet_wrap(~ District, ncol = 2) +
  scale_color_manual(values = DISTRICT_COLORS, guide = "none") +
  labs(
    title = "Annual Maximum Monthly Rainfall Trends (1973–2023)",
    subtitle = "Dashed line = Sen's slope trend; significance from Mann–Kendall test",
    x = "Year",
    y = "Annual Maximum Monthly Rainfall (mm)"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    axis.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("AMS_Trends.png", p1, width = 10, height = 7, dpi = 300)

# -----------------------------------------------------------------------------
# 7. Figure: GEV Q-Q diagnostics
# -----------------------------------------------------------------------------

qq_data <- map_dfr(gev_fits, function(g) {
  f <- g$fit
  x_sorted <- sort(g$x)
  n <- length(x_sorted)

  # Gringorten plotting position
  p <- ((seq_len(n)) - 0.44) / (n + 0.12)

  data.frame(
    District = g$District,
    Theoretical = evd::qgev(p, loc = f$mu, scale = f$sigma, shape = f$xi),
    Empirical = x_sorted
  )
})

p2 <- ggplot(qq_data, aes(Theoretical, Empirical)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  geom_point(aes(color = District), size = 1.7, alpha = 0.8) +
  facet_wrap(~ District, ncol = 2, scales = "free") +
  scale_color_manual(values = DISTRICT_COLORS, guide = "none") +
  labs(
    title = "GEV Q–Q Diagnostic Plots",
    x = "GEV Theoretical Quantile (mm)",
    y = "Empirical Quantile (mm)"
  ) +
  theme_bw(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

ggsave("GEV_QQ_Diagnostics.png", p2, width = 10, height = 7, dpi = 300)

# -----------------------------------------------------------------------------
# 8. Figure: GEV return-level curves with bootstrap confidence intervals
# -----------------------------------------------------------------------------

build_return_curve <- function(g, n_boot_curve = N_BOOT_CURVE) {
  f <- g$fit
  T_grid <- exp(seq(log(1.05), log(150), length.out = 60))

  estimate <- return_level(f$mu, f$sigma, f$xi, T_grid)
  boot <- matrix(NA_real_, nrow = n_boot_curve, ncol = length(T_grid))
  n <- length(g$x)

  for (b in seq_len(n_boot_curve)) {
    xb <- tryCatch(
      evd::rgev(n, loc = f$mu, scale = f$sigma, shape = f$xi),
      error = function(e) NULL
    )
    if (is.null(xb)) next

    fb <- tryCatch(ismev::gev.fit(xb, show = FALSE),
                   error = function(e) NULL)
    if (is.null(fb)) next

    vals <- tryCatch(
      return_level(fb$mle[1], fb$mle[2], fb$mle[3], T_grid),
      error = function(e) rep(NA_real_, length(T_grid))
    )

    if (all(is.finite(vals))) boot[b, ] <- vals
  }

  curve <- data.frame(
    Return_Period = T_grid,
    Estimate = estimate,
    Lower_CI = apply(boot, 2, quantile, probs = 0.025, na.rm = TRUE),
    Upper_CI = apply(boot, 2, quantile, probs = 0.975, na.rm = TRUE)
  )

  # Empirical plotting positions
  x_sorted <- sort(g$x)
  n_emp <- length(x_sorted)
  p_emp <- (seq_len(n_emp) - 0.44) / (n_emp + 0.12)

  empirical <- data.frame(
    Return_Period = 1 / (1 - p_emp),
    Value = x_sorted
  )

  labels <- data.frame(
    Return_Period = RETURN_PERIODS,
    Value = return_level(f$mu, f$sigma, f$xi, RETURN_PERIODS)
  )

  list(curve = curve, empirical = empirical, labels = labels)
}

curve_list <- map(gev_fits, build_return_curve)

plot_list <- map(names(curve_list), function(d) {
  g <- curve_list[[d]]

  ggplot() +
    geom_ribbon(
      data = g$curve,
      aes(Return_Period, ymin = Lower_CI, ymax = Upper_CI),
      fill = DISTRICT_COLORS[d], alpha = 0.20
    ) +
    geom_line(
      data = g$curve,
      aes(Return_Period, Estimate),
      color = DISTRICT_COLORS[d], linewidth = 1
    ) +
    geom_point(
      data = g$empirical,
      aes(Return_Period, Value),
      color = "grey40", size = 1.2, alpha = 0.55
    ) +
    geom_point(
      data = g$labels,
      aes(Return_Period, Value),
      color = DISTRICT_COLORS[d],
      fill = "white", shape = 21, size = 2.8
    ) +
    geom_text(
      data = g$labels,
      aes(Return_Period, Value,
          label = paste0(Return_Period, "-yr")),
      vjust = -1.0, size = 3
    ) +
    scale_x_log10(breaks = RETURN_PERIODS) +
    labs(
      title = d,
      x = "Return Period (years)",
      y = "Annual Maximum Monthly Rainfall (mm)"
    ) +
    theme_bw(base_size = 11) +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      axis.title = element_text(face = "bold"),
      panel.grid.minor = element_blank()
    )
})


png("GEV_ReturnLevels.png", width = 3000, height = 2400, res = 300)
gridExtra::grid.arrange(
  grobs = plot_list, ncol = 2,
  top = grid::textGrob(
    "GEV Return-Level Curves for Annual Maximum Monthly Rainfall",
    gp = grid::gpar(fontface = "bold", fontsize = 15)
  )
)
dev.off()

cat("\nGEV analysis complete.\n")
cat("Outputs: AMS_Trends.png, GEV_QQ_Diagnostics.png, GEV_ReturnLevels.png,\n",
    "GEV_Parameters_GOF.csv, GEV_ReturnLevels_Table.csv\n")
