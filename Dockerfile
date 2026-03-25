FROM rocker/r-ver:4.3.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libv8-dev \
    && rm -rf /var/lib/apt/lists/*

# Use Posit Package Manager for pre-compiled Linux binaries (no compilation needed)
RUN R -e "options(repos = c(CRAN = 'https://packagemanager.posit.co/cran/__linux__/jammy/latest')); \
    install.packages(c( \
    'shiny', \
    'shinydashboard', \
    'shinyjs', \
    'shinycssloaders', \
    'plotly', \
    'dplyr', \
    'DT' \
))"

# Create app directory and set permissions for HF Spaces (runs as uid 1000)
RUN useradd -m -u 1000 appuser
WORKDIR /app
COPY app.R .
RUN chown -R appuser:appuser /app

USER appuser

# Expose port for Hugging Face Spaces
EXPOSE 7860

# Run the app
CMD ["R", "-e", "shiny::runApp('app.R', host='0.0.0.0', port=7860)"]
