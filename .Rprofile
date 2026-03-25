# .Rprofile - Ensure required packages are available

# Use Posit Package Manager for pre-compiled binaries
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))

# Function to check and install packages
check_and_install <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

# List of required packages (matches app.R)
required_packages <- c(
  "shiny",
  "shinydashboard",
  "shinyjs",
  "shinycssloaders",
  "plotly",
  "dplyr",
  "DT"
)

# Check and install each package
invisible(lapply(required_packages, check_and_install))