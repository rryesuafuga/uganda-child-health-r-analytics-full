FROM rocker/shiny:4.3.1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libv8-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages
RUN R -e "install.packages(c( \
    'shiny', \
    'shinydashboard', \
    'shinyjs', \
    'shinycssloaders', \
    'plotly', \
    'dplyr', \
    'DT' \
), repos='https://cloud.r-project.org/')"

# Create app directory
WORKDIR /app

# Copy app file
COPY app.R .

# Expose port
EXPOSE 7860

# Run the app
CMD ["R", "-e", "shiny::runApp('app.R', host='0.0.0.0', port=7860)"]