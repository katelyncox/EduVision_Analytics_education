library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)
library(DT)
library(readr)
library(gt)
library(lubridate)
library(stringr)

# Load data function
load_education_data <- function() {
  # Check if data exists, generate if needed
  if(!file.exists("data/synthetic-schools.csv")) {
    source("data/generate_data.R")
  }
  
  # Load synthetic data - read after comment header lines
  schools <- read_csv("data/synthetic-schools.csv", skip = 4, 
                     col_names = c("school_id", "school_name", "region", "school_type", 
                                  "funding_type", "total_enrollment", "established_year", 
                                  "latitude", "longitude"),
                     show_col_types = FALSE)
  enrollment <- read_csv("data/synthetic-enrollment.csv", skip = 6,
                        col_names = c("School_ID", "Academic_Year", "Total_Students", 
                                     "Kindergarten", "Grade_1", "Grade_2", "Grade_3", "Grade_4", 
                                     "Grade_5", "Grade_6", "Grade_7", "Grade_8", "Grade_9", 
                                     "Grade_10", "Grade_11", "Grade_12", "Special_Needs_Students", 
                                     "English_Learners"),
                        show_col_types = FALSE)
  performance <- read_csv("data/synthetic-performance.csv", skip = 4,
                         col_names = c("school_id", "academic_year", "math_proficiency", 
                                      "reading_proficiency", "science_proficiency", "overall_rating",
                                      "graduation_rate", "attendance_rate", "teacher_retention"),
                         show_col_types = FALSE)
  phonics <- read_csv("data/synthetic-phonics-tests.csv", skip = 4,
                     col_names = c("school_id", "student_id", "test_date", "grade_level",
                                  "phonics_score", "letter_sounds", "word_recognition", 
                                  "reading_fluency", "comprehension"),
                     show_col_types = FALSE)
  initiatives <- read_csv("data/synthetic-initiatives.csv", skip = 4,
                         col_names = c("initiative_id", "initiative_name", "start_date", 
                                      "planned_duration_months", "status", "budget_allocated",
                                      "schools_participating", "target_students", "primary_focus"),
                         show_col_types = FALSE)
  
  # Data preparation
  current_year <- "2024-2025"
  performance_current <- performance |> filter(academic_year == current_year)
  enrollment_current <- enrollment |> filter(academic_year == current_year)
  
  # Join datasets for analysis
  school_performance <- schools |>
    left_join(performance_current, by = "school_id") |>
    left_join(enrollment_current, by = "school_id")
  
  list(
    schools = schools,
    enrollment = enrollment,
    performance = performance,
    phonics = phonics |> mutate(test_date = as.Date(test_date)),
    initiatives = initiatives |> mutate(start_date = as.Date(start_date)),
    school_performance = school_performance
  )
}

# Load data at startup
data <- load_education_data()

# UI
ui <- page_sidebar(
  title = "EduVision Analytics - National Education Performance Dashboard",
  theme = bs_theme(brand = "_brand.yml"),
  
  sidebar = sidebar(
    width = 300,
    h4("🎯 Dashboard Controls"),
    
    selectInput("region_filter", 
                "Select Region(s):",
                choices = c("All Regions" = "all", unique(data$schools$region)),
                selected = "all",
                multiple = TRUE),
    
    selectInput("funding_filter",
                "Funding Type:",
                choices = c("All Types" = "all", unique(data$schools$funding_type)),
                selected = "all"),
    
    selectInput("metric_select",
                "Performance Metric:",
                choices = list(
                  "Mathematics" = "math_proficiency",
                  "Reading" = "reading_proficiency", 
                  "Science" = "science_proficiency",
                  "Attendance Rate" = "attendance_rate",
                  "Teacher Retention" = "teacher_retention"
                ),
                selected = "math_proficiency"),
    
    hr(),
    
    div(class = "alert alert-info",
        p(strong("📊 Current Data:"), br(),
          paste("Academic Year 2024-2025"), br(),
          paste(nrow(data$schools), "Schools"), br(),
          paste(format(sum(data$school_performance$total_students, na.rm = TRUE), big.mark = ","), "Students"))
    ),
    
    div(class = "alert alert-warning",
        p(strong("⚠️ Disclaimer:"), br(),
          "This project contains synthetic data and analysis created for demonstration purposes only."))
  ),
  
  # Main content
  navset_card_pill(
    nav_panel("📊 Overview",
      div(class = "row",
        div(class = "col-12",
          h2("National Education Performance Overview"),
          p("Real-time dashboard for monitoring school performance, initiatives, and student outcomes across all regions.")
        )
      ),
      
      layout_columns(
        value_box(
          title = "Total Schools",
          value = textOutput("total_schools"),
          theme = "primary"
        ),
        value_box(
          title = "Total Students", 
          value = textOutput("total_students"),
          theme = "info"
        ),
        value_box(
          title = "Average Performance",
          value = textOutput("avg_performance"),
          theme = "success"
        ),
        value_box(
          title = "Schools Needing Support",
          value = textOutput("needs_improvement"),
          theme = "warning"
        ),
        col_widths = c(3, 3, 3, 3)
      ),
      
      br(),
      
      card(
        card_header("📈 Regional Performance Comparison"),
        plotlyOutput("regional_performance", height = "400px")
      )
    ),
    
    nav_panel("🏫 School Explorer",
      div(class = "row",
        div(class = "col-12",
          h3("School Performance Explorer"),
          p("Detailed view of individual school performance metrics and comparisons.")
        )
      ),
      
      layout_columns(
        card(
          card_header("Performance Distribution"),
          plotlyOutput("performance_scatter", height = "500px")
        ),
        card(
          card_header("Top Performers"),
          div(style = "height: 460px; overflow-y: auto;",
              DT::dataTableOutput("top_schools"))
        ),
        col_widths = c(8, 4)
      ),
      
      br(),
      
      card(
        card_header("School Performance Data Table"),
        DT::dataTableOutput("school_table")
      )
    ),
    
    nav_panel("📚 Phonics Assessment",
      div(class = "row",
        div(class = "col-12",
          h3("Phonics Testing Results Analysis"),
          p("Monitor early literacy development through phonics assessment outcomes.")
        )
      ),
      
      layout_columns(
        card(
          card_header("Phonics Scores by Grade Level"),
          plotlyOutput("phonics_by_grade", height = "400px")
        ),
        card(
          card_header("Assessment Trends Over Time"),
          plotlyOutput("phonics_timeline", height = "400px")
        ),
        col_widths = c(6, 6)
      ),
      
      br(),
      
      card(
        card_header("Detailed Phonics Assessment Data"),
        DT::dataTableOutput("phonics_table")
      )
    ),
    
    nav_panel("🚀 Initiatives",
      div(class = "row",
        div(class = "col-12",
          h3("Education Initiative Tracking"),
          p("Monitor the effectiveness and progress of educational initiatives across the system.")
        )
      ),
      
      layout_columns(
        value_box(
          title = "Active Initiatives",
          value = textOutput("active_initiatives"),
          theme = "primary"
        ),
        value_box(
          title = "Schools Participating",
          value = textOutput("participating_schools"),
          theme = "info"
        ),
        value_box(
          title = "Total Investment",
          value = textOutput("total_investment"),
          theme = "success"
        ),
        col_widths = c(4, 4, 4)
      ),
      
      br(),
      
      card(
        card_header("Initiative Status and Budget Overview"),
        DT::dataTableOutput("initiatives_table")
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Reactive data filtering
  filtered_data <- reactive({
    df <- data$school_performance
    
    # Apply region filter
    if(!"all" %in% input$region_filter && !is.null(input$region_filter)) {
      df <- df |> filter(region %in% input$region_filter)
    }
    
    # Apply funding filter  
    if(input$funding_filter != "all") {
      df <- df |> filter(funding_type == input$funding_filter)
    }
    
    df
  })
  
  # Overview outputs
  output$total_schools <- renderText({
    format(nrow(filtered_data()), big.mark = ",")
  })
  
  output$total_students <- renderText({
    format(sum(filtered_data()$total_students, na.rm = TRUE), big.mark = ",")
  })
  
  output$avg_performance <- renderText({
    metric_col <- input$metric_select
    avg_val <- mean(filtered_data()[[metric_col]], na.rm = TRUE)
    paste0(round(avg_val, 1), 
           if(metric_col %in% c("math_proficiency", "reading_proficiency", "science_proficiency", 
                               "attendance_rate", "teacher_retention")) "%")
  })
  
  output$needs_improvement <- renderText({
    count <- sum(filtered_data()$overall_rating == "Needs Improvement", na.rm = TRUE)
    format(count, big.mark = ",")
  })
  
  # Regional performance chart
  output$regional_performance <- renderPlotly({
    regional_data <- filtered_data() |>
      group_by(region) |>
      summarise(
        Schools = n(),
        Math = mean(math_proficiency, na.rm = TRUE),
        Reading = mean(reading_proficiency, na.rm = TRUE),
        Science = mean(science_proficiency, na.rm = TRUE),
        .groups = 'drop'
      ) |>
      tidyr::pivot_longer(cols = c(Math, Reading, Science), 
                         names_to = "Subject", values_to = "Score")
    
    p <- ggplot(regional_data, aes(x = region, y = Score, fill = Subject)) +
      geom_col(position = "dodge", alpha = 0.8) +
      scale_fill_manual(values = c("#1B4B76", "#2E7BC6", "#4A8B3B")) +
      labs(title = "Academic Performance by Region",
           x = "Region", y = "Average Proficiency (%)",
           fill = "Subject") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p) |> config(displayModeBar = FALSE)
  })
  
  # Performance scatter plot
  output$performance_scatter <- renderPlotly({
    p <- ggplot(filtered_data(), 
                aes(x = math_proficiency, y = reading_proficiency, 
                    color = funding_type, size = total_students,
                    text = paste("School:", school_name, "<br>",
                               "Region:", region, "<br>",
                               "Math:", round(math_proficiency, 1), "%<br>",
                               "Reading:", round(reading_proficiency, 1), "%<br>",
                               "Students:", total_students))) +
      geom_point(alpha = 0.6) +
      scale_color_manual(values = c("#1B4B76", "#E17D2E", "#4A8B3B")) +
      labs(title = "School Performance: Mathematics vs Reading",
           x = "Mathematics Proficiency (%)", 
           y = "Reading Proficiency (%)",
           color = "Funding Type", size = "Enrollment") +
      theme_minimal()
    
    ggplotly(p, tooltip = "text") |> config(displayModeBar = FALSE)
  })
  
  # Top schools table
  output$top_schools <- renderDT({
    top_data <- filtered_data() |>
      filter(!is.na(math_proficiency)) |>
      arrange(desc(.data[[input$metric_select]])) |>
      select(school_name, region, funding_type, !!sym(input$metric_select)) |>
      slice_head(n = 10)
    
    colnames(top_data)[4] <- "Score"
    
    datatable(top_data, 
              options = list(
                dom = 't',
                pageLength = 10,
                scrollY = "400px",
                columnDefs = list(list(className = 'dt-center', targets = "_all"))
              ),
              rownames = FALSE) |>
      formatRound("Score", digits = 1)
  })
  
  # School performance table
  output$school_table <- renderDT({
    table_data <- filtered_data() |>
      select(school_name, region, funding_type, total_students, 
             math_proficiency, reading_proficiency, science_proficiency, 
             overall_rating, teacher_retention) |>
      filter(!is.na(math_proficiency))
    
    datatable(table_data,
              options = list(
                pageLength = 15,
                scrollX = TRUE,
                columnDefs = list(list(className = 'dt-center', targets = 4:8))
              ),
              rownames = FALSE) |>
      formatRound(c("math_proficiency", "reading_proficiency", "science_proficiency", "teacher_retention"), 1)
  })
  
  # Phonics analysis
  output$phonics_by_grade <- renderPlotly({
    phonics_grade <- data$phonics |>
      group_by(grade_level) |>
      summarise(
        avg_phonics = mean(phonics_score),
        avg_fluency = mean(reading_fluency),
        avg_comprehension = mean(comprehension),
        .groups = 'drop'
      ) |>
      tidyr::pivot_longer(cols = -grade_level, names_to = "metric", values_to = "score")
    
    p <- ggplot(phonics_grade, aes(x = grade_level, y = score, fill = metric)) +
      geom_col(position = "dodge", alpha = 0.8) +
      scale_fill_manual(values = c("#1B4B76", "#2E7BC6", "#4A8B3B"),
                       labels = c("Comprehension", "Phonics Score", "Reading Fluency")) +
      labs(title = "Phonics Assessment Performance by Grade Level",
           x = "Grade Level", y = "Average Score",
           fill = "Assessment Type") +
      theme_minimal()
    
    ggplotly(p) |> config(displayModeBar = FALSE)
  })
  
  output$phonics_timeline <- renderPlotly({
    phonics_monthly <- data$phonics |>
      mutate(month = floor_date(test_date, "month")) |>
      group_by(month, grade_level) |>
      summarise(avg_score = mean(phonics_score), .groups = 'drop')
    
    p <- ggplot(phonics_monthly, aes(x = month, y = avg_score, color = grade_level)) +
      geom_line(size = 1.2) +
      geom_point(size = 2) +
      scale_color_manual(values = c("#1B4B76", "#2E7BC6", "#4A8B3B", "#E17D2E")) +
      labs(title = "Phonics Performance Trends Throughout the Year",
           x = "Month", y = "Average Phonics Score",
           color = "Grade Level") +
      theme_minimal()
    
    ggplotly(p) |> config(displayModeBar = FALSE)
  })
  
  output$phonics_table <- renderDT({
    phonics_summary <- data$phonics |>
      group_by(school_id, grade_level) |>
      summarise(
        tests_conducted = n(),
        avg_phonics_score = round(mean(phonics_score), 1),
        avg_fluency = round(mean(reading_fluency), 1),
        avg_comprehension = round(mean(comprehension), 1),
        .groups = 'drop'
      ) |>
      left_join(data$schools |> select(school_id, school_name, region), by = "school_id") |>
      select(school_name, region, grade_level, tests_conducted, 
             avg_phonics_score, avg_fluency, avg_comprehension)
    
    datatable(phonics_summary,
              options = list(pageLength = 15, scrollX = TRUE),
              rownames = FALSE) |>
      formatRound(c("avg_phonics_score", "avg_fluency", "avg_comprehension"), 1)
  })
  
  # Initiative outputs
  output$active_initiatives <- renderText({
    count <- sum(data$initiatives$status == "Active")
    format(count, big.mark = ",")
  })
  
  output$participating_schools <- renderText({
    total <- sum(data$initiatives$schools_participating[data$initiatives$status == "Active"], na.rm = TRUE)
    format(total, big.mark = ",")
  })
  
  output$total_investment <- renderText({
    total <- sum(data$initiatives$budget_allocated[data$initiatives$status == "Active"], na.rm = TRUE)
    paste0("$", format(total / 1e6, digits = 1), "M")
  })
  
  output$initiatives_table <- renderDT({
    init_data <- data$initiatives |>
      select(initiative_name, primary_focus, status, schools_participating,
             budget_allocated, start_date) |>
      arrange(desc(budget_allocated))
    
    datatable(init_data,
              options = list(pageLength = 15, scrollX = TRUE),
              rownames = FALSE) |>
      formatCurrency("budget_allocated", digits = 0) |>
      formatDate("start_date")
  })
}

# Run the application
shinyApp(ui = ui, server = server)