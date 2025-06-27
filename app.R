# app.R - Enhanced Uganda Health Analytics with CSS, JavaScript, and Modular Structure
# Using golem-inspired modular approach

library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(DT)
library(shinyjs)
library(shinycssloaders)

# ============= MODULES (Golem-style) =============
# Module for value boxes
valueBoxModuleUI <- function(id) {
  ns <- NS(id)
  valueBoxOutput(ns("box"))
}

valueBoxModuleServer <- function(id, data, metric, title, icon_name, color) {
  moduleServer(id, function(input, output, session) {
    output$box <- renderValueBox({
      latest <- data() %>% filter(year == max(year))
      value <- mean(latest[[metric]], na.rm = TRUE)
      
      if(metric %in% c("vaccination_coverage", "stunting_prevalence")) {
        value <- paste0(round(value, 1), "%")
      } else {
        value <- round(value, 1)
      }
      
      valueBox(
        value = tags$span(class = "animated-value", value),
        subtitle = title,
        icon = icon(icon_name),
        color = color
      )
    })
  })
}

# Module for charts
chartModuleUI <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("indicator"), "Select Indicator:",
                choices = c("Under-5 Mortality" = "under5_mortality",
                          "Vaccination Coverage" = "vaccination_coverage",
                          "Stunting Prevalence" = "stunting_prevalence")),
    withSpinner(plotlyOutput(ns("plot"), height = "400px"), type = 6, color = "#3498db")
  )
}

chartModuleServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlotly({
      plot_data <- data() %>%
        group_by(year, region) %>%
        summarise(value = mean(.data[[input$indicator]], na.rm = TRUE), .groups = 'drop')
      
      plot_ly(plot_data, x = ~year, y = ~value, color = ~region,
              type = 'scatter', mode = 'lines+markers',
              hovertemplate = '%{y:.1f}<extra></extra>') %>%
        layout(title = gsub("_", " ", input$indicator),
               xaxis = list(title = "Year"),
               yaxis = list(title = "Value"))
    })
  })
}

# ============= CUSTOM CSS =============
custom_css <- "
/* Import Google Fonts */
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600;700&display=swap');

/* Global Styles */
body {
  font-family: 'Poppins', sans-serif;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.content-wrapper, .right-side {
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

/* Header Styling */
.main-header .logo {
  font-weight: 700;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
}

/* Value Boxes with Animation */
.small-box {
  border-radius: 15px;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  backdrop-filter: blur(4px);
  border: 1px solid rgba(255, 255, 255, 0.18);
  transition: all 0.3s ease;
  background: rgba(255, 255, 255, 0.9);
}

.small-box:hover {
  transform: translateY(-10px) scale(1.02);
  box-shadow: 0 15px 35px 0 rgba(31, 38, 135, 0.5);
}

.animated-value {
  display: inline-block;
  animation: countUp 2s ease-out;
}

@keyframes countUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Box Styling */
.box {
  border-radius: 15px;
  box-shadow: 0 4px 20px 0 rgba(0, 0, 0, 0.1);
  border: none;
  transition: all 0.3s ease;
}

.box:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 30px 0 rgba(0, 0, 0, 0.15);
}

.box-header {
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 15px 15px 0 0;
}

/* Interactive Network Visualization Container */
#network-viz {
  background: white;
  border-radius: 15px;
  padding: 20px;
  margin: 20px 0;
}

/* Custom Buttons */
.btn-custom {
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 25px;
  padding: 10px 30px;
  font-weight: 600;
  transition: all 0.3s ease;
}

.btn-custom:hover {
  transform: translateY(-3px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
  color: white;
}

/* Loading Animation */
.loading-wave {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100px;
}

.loading-bar {
  width: 10px;
  height: 100%;
  background: #667eea;
  margin: 0 5px;
  border-radius: 5px;
  animation: wave 1.2s ease-in-out infinite;
}

.loading-bar:nth-child(2) { animation-delay: -1.1s; }
.loading-bar:nth-child(3) { animation-delay: -1.0s; }
.loading-bar:nth-child(4) { animation-delay: -0.9s; }

@keyframes wave {
  0%, 40%, 100% { transform: scaleY(0.4); }
  20% { transform: scaleY(1); }
}

/* Glassmorphism Cards */
.glass-card {
  background: rgba(255, 255, 255, 0.25);
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.18);
  padding: 20px;
  margin: 10px 0;
}
"

# ============= CUSTOM JAVASCRIPT =============
custom_js <- "
// Animated Counter Function
shinyjs.animateCounter = function(params) {
  const element = document.getElementById(params.id);
  const endValue = parseFloat(params.value);
  const duration = 2000;
  const startValue = 0;
  const startTime = performance.now();
  
  function updateCounter(currentTime) {
    const elapsedTime = currentTime - startTime;
    const progress = Math.min(elapsedTime / duration, 1);
    const currentValue = startValue + (endValue - startValue) * easeOutQuart(progress);
    
    element.textContent = Math.round(currentValue);
    
    if (progress < 1) {
      requestAnimationFrame(updateCounter);
    }
  }
  
  function easeOutQuart(t) {
    return 1 - Math.pow(1 - t, 4);
  }
  
  requestAnimationFrame(updateCounter);
};

// D3.js Network Visualization
shinyjs.createNetworkViz = function(params) {
  // Clear previous visualization
  d3.select('#' + params.id).selectAll('*').remove();
  
  const width = 600;
  const height = 400;
  const data = params.data;
  
  // Create SVG
  const svg = d3.select('#' + params.id)
    .append('svg')
    .attr('width', width)
    .attr('height', height);
  
  // Create gradient
  const gradient = svg.append('defs')
    .append('linearGradient')
    .attr('id', 'nodeGradient')
    .attr('x1', '0%')
    .attr('y1', '0%')
    .attr('x2', '100%')
    .attr('y2', '100%');
  
  gradient.append('stop')
    .attr('offset', '0%')
    .style('stop-color', '#667eea');
  
  gradient.append('stop')
    .attr('offset', '100%')
    .style('stop-color', '#764ba2');
  
  // Create force simulation
  const simulation = d3.forceSimulation(data.nodes)
    .force('link', d3.forceLink(data.links).id(d => d.id).distance(100))
    .force('charge', d3.forceManyBody().strength(-300))
    .force('center', d3.forceCenter(width / 2, height / 2));
  
  // Add links
  const link = svg.append('g')
    .selectAll('line')
    .data(data.links)
    .enter().append('line')
    .style('stroke', '#999')
    .style('stroke-opacity', 0.6)
    .style('stroke-width', d => Math.sqrt(d.value));
  
  // Add nodes
  const node = svg.append('g')
    .selectAll('circle')
    .data(data.nodes)
    .enter().append('circle')
    .attr('r', d => d.size)
    .style('fill', 'url(#nodeGradient)')
    .style('cursor', 'pointer')
    .call(d3.drag()
      .on('start', dragstarted)
      .on('drag', dragged)
      .on('end', dragended));
  
  // Add hover effect
  node.on('mouseover', function(event, d) {
    d3.select(this)
      .transition()
      .duration(200)
      .attr('r', d.size * 1.5);
  })
  .on('mouseout', function(event, d) {
    d3.select(this)
      .transition()
      .duration(200)
      .attr('r', d.size);
  });
  
  // Add labels
  const label = svg.append('g')
    .selectAll('text')
    .data(data.nodes)
    .enter().append('text')
    .text(d => d.name)
    .style('font-size', '12px')
    .style('font-family', 'Poppins, sans-serif')
    .style('font-weight', '600');
  
  // Update positions on tick
  simulation.on('tick', () => {
    link
      .attr('x1', d => d.source.x)
      .attr('y1', d => d.source.y)
      .attr('x2', d => d.target.x)
      .attr('y2', d => d.target.y);
    
    node
      .attr('cx', d => d.x)
      .attr('cy', d => d.y);
    
    label
      .attr('x', d => d.x + 15)
      .attr('y', d => d.y + 5);
  });
  
  // Drag functions
  function dragstarted(event, d) {
    if (!event.active) simulation.alphaTarget(0.3).restart();
    d.fx = d.x;
    d.fy = d.y;
  }
  
  function dragged(event, d) {
    d.fx = event.x;
    d.fy = event.y;
  }
  
  function dragended(event, d) {
    if (!event.active) simulation.alphaTarget(0);
    d.fx = null;
    d.fy = null;
  }
};

// Particle Animation Background
shinyjs.createParticles = function() {
  const canvas = document.createElement('canvas');
  canvas.id = 'particles-canvas';
  canvas.style.position = 'fixed';
  canvas.style.top = '0';
  canvas.style.left = '0';
  canvas.style.width = '100%';
  canvas.style.height = '100%';
  canvas.style.zIndex = '-1';
  canvas.style.opacity = '0.5';
  document.body.appendChild(canvas);
  
  const ctx = canvas.getContext('2d');
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
  
  const particles = [];
  const particleCount = 50;
  
  class Particle {
    constructor() {
      this.x = Math.random() * canvas.width;
      this.y = Math.random() * canvas.height;
      this.vx = Math.random() * 2 - 1;
      this.vy = Math.random() * 2 - 1;
      this.radius = Math.random() * 3 + 1;
    }
    
    update() {
      this.x += this.vx;
      this.y += this.vy;
      
      if (this.x < 0 || this.x > canvas.width) this.vx = -this.vx;
      if (this.y < 0 || this.y > canvas.height) this.vy = -this.vy;
    }
    
    draw() {
      ctx.beginPath();
      ctx.arc(this.x, this.y, this.radius, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(102, 126, 234, 0.5)';
      ctx.fill();
    }
  }
  
  for (let i = 0; i < particleCount; i++) {
    particles.push(new Particle());
  }
  
  function animate() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    particles.forEach(particle => {
      particle.update();
      particle.draw();
    });
    
    requestAnimationFrame(animate);
  }
  
  animate();
};
"

# ============= DATA GENERATION =============
generate_uganda_data <- function() {
  set.seed(42)
  years <- 2010:2023
  regions <- c("Central", "Eastern", "Northern", "Western")
  
  data <- expand.grid(
    year = years,
    region = regions,
    stringsAsFactors = FALSE
  ) %>%
    mutate(
      under5_mortality = case_when(
        region == "Northern" ~ 100 - (year - 2010) * 2.5 + rnorm(n(), 0, 3),
        region == "Eastern" ~ 95 - (year - 2010) * 2.3 + rnorm(n(), 0, 3),
        region == "Western" ~ 92 - (year - 2010) * 2.4 + rnorm(n(), 0, 3),
        TRUE ~ 88 - (year - 2010) * 2.6 + rnorm(n(), 0, 3)
      ),
      stunting_prevalence = case_when(
        region == "Northern" ~ 42 - (year - 2010) * 0.8 + rnorm(n(), 0, 2),
        region == "Eastern" ~ 40 - (year - 2010) * 0.9 + rnorm(n(), 0, 2),
        TRUE ~ 38 - (year - 2010) * 1.0 + rnorm(n(), 0, 2)
      ),
      vaccination_coverage = 50 + (year - 2010) * 3 + rnorm(n(), 0, 3),
      malaria_incidence = 300 - (year - 2010) * 8 + rnorm(n(), 0, 10)
    ) %>%
    mutate_if(is.numeric, ~pmax(., 0))
  
  return(data)
}

# ============= UI =============
ui <- dashboardPage(
  dashboardHeader(title = tags$span(style = "font-weight: 700;", "Uganda Health Analytics")),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Advanced Analytics", tabName = "analytics", icon = icon("chart-line")),
      menuItem("Network Analysis", tabName = "network", icon = icon("project-diagram"))
    )
  ),
  
  dashboardBody(
    # Include shinyjs and custom CSS/JS
    useShinyjs(),
    tags$head(
      tags$style(HTML(custom_css)),
      tags$script(src = "https://d3js.org/d3.v7.min.js")
    ),
    extendShinyjs(text = custom_js, functions = c("animateCounter", "createNetworkViz", "createParticles")),
    
    tabItems(
      # Dashboard Tab
      tabItem(
        tabName = "dashboard",
        
        # Animated value boxes using modules
        fluidRow(
          column(4, valueBoxModuleUI("mortality")),
          column(4, valueBoxModuleUI("stunting")),
          column(4, valueBoxModuleUI("vaccination"))
        ),
        
        fluidRow(
          box(
            title = "Interactive Trend Analysis",
            status = "primary",
            solidHeader = TRUE,
            width = 8,
            chartModuleUI("trend_chart")
          ),
          
          box(
            title = "Quick Actions",
            status = "info",
            width = 4,
            div(class = "glass-card",
              h4("Generate Report"),
              p("Create comprehensive health analysis report"),
              actionButton("generate_report", "Generate", class = "btn-custom", icon = icon("file-pdf"))
            ),
            div(class = "glass-card",
              h4("Export Data"),
              p("Download data in multiple formats"),
              actionButton("export_data", "Export", class = "btn-custom", icon = icon("download"))
            )
          )
        )
      ),
      
      # Advanced Analytics Tab
      tabItem(
        tabName = "analytics",
        fluidRow(
          box(
            title = "Machine Learning Predictions",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(4,
                selectInput("ml_target", "Target Variable:",
                          choices = c("Under-5 Mortality" = "under5_mortality",
                                    "Stunting Prevalence" = "stunting_prevalence"))
              ),
              column(4,
                selectInput("ml_algorithm", "Algorithm:",
                          choices = c("Random Forest" = "rf",
                                    "Gradient Boosting" = "gb",
                                    "Neural Network" = "nn"))
              ),
              column(4,
                br(),
                actionButton("train_model", "Train Model", class = "btn-custom", icon = icon("brain"))
              )
            ),
            hr(),
            withSpinner(plotlyOutput("ml_results", height = "400px"), type = 6)
          )
        )
      ),
      
      # Network Analysis Tab
      tabItem(
        tabName = "network",
        fluidRow(
          box(
            title = "Health Indicators Network",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            p("Interactive D3.js visualization showing relationships between health indicators"),
            div(id = "network-viz", style = "width: 100%; height: 500px;"),
            br(),
            actionButton("update_network", "Update Network", class = "btn-custom", icon = icon("sync"))
          )
        )
      )
    )
  )
)

# ============= SERVER =============
server <- function(input, output, session) {
  # Reactive data
  uganda_data <- reactive({
    generate_uganda_data()
  })
  
  # Initialize particle background
  observe({
    js$createParticles()
  })
  
  # Module servers
  valueBoxModuleServer("mortality", uganda_data, "under5_mortality", 
                       "Under-5 Mortality Rate", "heartbeat", "red")
  valueBoxModuleServer("stunting", uganda_data, "stunting_prevalence", 
                       "Stunting Prevalence", "child", "yellow")
  valueBoxModuleServer("vaccination", uganda_data, "vaccination_coverage", 
                       "Vaccination Coverage", "syringe", "green")
  
  chartModuleServer("trend_chart", uganda_data)
  
  # ML Results
  output$ml_results <- renderPlotly({
    input$train_model
    
    isolate({
      # Simulate ML results
      x <- seq(0, 100, length.out = 100)
      actual <- 80 - 0.5 * x + rnorm(100, 0, 5)
      predicted <- 80 - 0.5 * x + rnorm(100, 0, 3)
      
      plot_ly() %>%
        add_trace(x = x, y = actual, name = "Actual", type = 'scatter', mode = 'markers',
                  marker = list(color = '#667eea', size = 8)) %>%
        add_trace(x = x, y = predicted, name = "Predicted", type = 'scatter', mode = 'lines',
                  line = list(color = '#764ba2', width = 3)) %>%
        layout(title = paste("Model Results:", input$ml_algorithm),
               xaxis = list(title = "Feature"),
               yaxis = list(title = input$ml_target))
    })
  })
  
  # Network visualization
  observeEvent(input$update_network, {
    # Create network data
    nodes <- data.frame(
      id = 0:4,
      name = c("Mortality", "Stunting", "Vaccination", "Malaria", "Water Access"),
      size = runif(5, 10, 30)
    )
    
    links <- data.frame(
      source = c(0, 0, 1, 1, 2, 3),
      target = c(1, 2, 2, 3, 3, 4),
      value = runif(6, 1, 10)
    )
    
    network_data <- list(nodes = nodes, links = links)
    
    js$createNetworkViz(id = "network-viz", data = network_data)
  })
  
  # Initialize network on load
  observe({
    invalidateLater(1000, session)
    js$createNetworkViz(id = "network-viz", 
                       data = list(
                         nodes = data.frame(
                           id = 0:4,
                           name = c("Mortality", "Stunting", "Vaccination", "Malaria", "Water"),
                           size = runif(5, 10, 30)
                         ),
                         links = data.frame(
                           source = c(0, 0, 1, 1, 2),
                           target = c(1, 2, 2, 3, 3),
                           value = runif(5, 1, 10)
                         )
                       ))
  })
}

# Run the app
shinyApp(ui = ui, server = server)