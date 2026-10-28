# Synthetic Education Data Generation Script
# This script generates realistic but artificial data for demonstration purposes
# All data is synthetic and created through AI for educational demonstration only

library(dplyr)
library(readr)
library(lubridate)

set.seed(42)  # For reproducible synthetic data

# Generate school data
generate_schools <- function(n_schools = 500) {
  
  regions <- c("North", "South", "East", "West", "Central")
  school_types <- c("Primary", "Secondary", "Combined")
  funding_types <- c("Public", "Charter", "Private")
  
  schools <- tibble(
    school_id = sprintf("SCH%04d", 1:n_schools),
    school_name = paste("Example School", sample(c("Elementary", "Middle", "High", "Academy", "Institute"), n_schools, replace = TRUE)),
    region = sample(regions, n_schools, replace = TRUE, prob = c(0.2, 0.25, 0.2, 0.15, 0.2)),
    school_type = sample(school_types, n_schools, replace = TRUE, prob = c(0.4, 0.35, 0.25)),
    funding_type = sample(funding_types, n_schools, replace = TRUE, prob = c(0.7, 0.2, 0.1)),
    total_enrollment = sample(200:1200, n_schools, replace = TRUE),
    established_year = sample(1950:2020, n_schools, replace = TRUE),
    latitude = runif(n_schools, 35.0, 49.0),
    longitude = runif(n_schools, -125.0, -66.0)
  )
  
  return(schools)
}

# Generate student enrollment data
generate_enrollment <- function(schools, years = 2020:2024) {
  
  enrollment_data <- tibble()
  
  for(school in schools$school_id) {
    base_enrollment <- schools$total_enrollment[schools$school_id == school]
    
    for(year in years) {
      # Add some year-over-year variation
      variation <- rnorm(1, 0, 0.05)
      current_enrollment <- max(50, round(base_enrollment * (1 + variation)))
      
      enrollment_data <- bind_rows(enrollment_data, tibble(
        School_ID = school,
        Academic_Year = paste0(year, "-", year + 1),
        Total_Students = current_enrollment,
        Kindergarten = round(current_enrollment * 0.08),
        Grade_1 = round(current_enrollment * 0.08),
        Grade_2 = round(current_enrollment * 0.08),
        Grade_3 = round(current_enrollment * 0.08),
        Grade_4 = round(current_enrollment * 0.08),
        Grade_5 = round(current_enrollment * 0.08),
        Grade_6 = round(current_enrollment * 0.08),
        Grade_7 = round(current_enrollment * 0.08),
        Grade_8 = round(current_enrollment * 0.08),
        Grade_9 = round(current_enrollment * 0.09),
        Grade_10 = round(current_enrollment * 0.09),
        Grade_11 = round(current_enrollment * 0.09),
        Grade_12 = round(current_enrollment * 0.09),
        Special_Needs_Students = round(current_enrollment * runif(1, 0.05, 0.15)),
        English_Learners = round(current_enrollment * runif(1, 0.02, 0.25))
      ))
    }
  }
  
  return(enrollment_data)
}

# Generate performance data
generate_performance <- function(schools, years = 2020:2024) {
  
  performance_data <- tibble()
  
  for(school in schools$school_id) {
    school_info <- schools[schools$school_id == school, ]
    
    # Base performance influenced by school characteristics
    base_math <- ifelse(school_info$funding_type == "Private", 
                       rnorm(1, 75, 8), 
                       rnorm(1, 65, 10))
    base_reading <- ifelse(school_info$funding_type == "Private", 
                          rnorm(1, 78, 7), 
                          rnorm(1, 68, 9))
    base_science <- ifelse(school_info$funding_type == "Private", 
                          rnorm(1, 72, 8), 
                          rnorm(1, 62, 10))
    
    for(year in years) {
      # Add year-over-year variation and trends
      year_effect <- (year - 2020) * runif(1, -0.5, 1.5)
      
      performance_data <- bind_rows(performance_data, tibble(
        school_id = school,
        academic_year = paste0(year, "-", year + 1),
        math_proficiency = pmax(0, pmin(100, base_math + rnorm(1, year_effect, 5))),
        reading_proficiency = pmax(0, pmin(100, base_reading + rnorm(1, year_effect, 4))),
        science_proficiency = pmax(0, pmin(100, base_science + rnorm(1, year_effect, 6))),
        overall_rating = sample(c("Excellent", "Good", "Satisfactory", "Needs Improvement"), 1, 
                               prob = c(0.15, 0.35, 0.35, 0.15)),
        graduation_rate = ifelse(school_info$school_type != "Primary", 
                                runif(1, 75, 95), NA),
        attendance_rate = runif(1, 85, 98),
        teacher_retention = runif(1, 70, 95)
      ))
    }
  }
  
  return(performance_data)
}

# Generate phonics test data
generate_phonics_tests <- function(schools, n_tests_per_school = 20) {
  
  phonics_data <- tibble()
  
  for(school in schools$school_id) {
    school_info <- schools[schools$school_id == school, ]
    
    # Focus on elementary grades for phonics testing
    if(school_info$school_type %in% c("Primary", "Combined")) {
      
      for(i in 1:n_tests_per_school) {
        
        grade <- sample(c("K", "1", "2", "3"), 1, prob = c(0.3, 0.3, 0.25, 0.15))
        
        # Performance varies by grade level
        base_score <- case_when(
          grade == "K" ~ rnorm(1, 45, 15),
          grade == "1" ~ rnorm(1, 60, 12),
          grade == "2" ~ rnorm(1, 75, 10),
          grade == "3" ~ rnorm(1, 85, 8)
        )
        
        phonics_data <- bind_rows(phonics_data, tibble(
          school_id = school,
          student_id = paste0("STU", sprintf("%06d", sample(100000:999999, 1))),
          test_date = sample(seq(as.Date("2024-01-01"), as.Date("2024-12-31"), by = "day"), 1),
          grade_level = grade,
          phonics_score = pmax(0, pmin(100, base_score)),
          letter_sounds = pmax(0, pmin(26, round(base_score * 0.26))),
          word_recognition = pmax(0, pmin(50, round(base_score * 0.50))),
          reading_fluency = pmax(0, pmin(100, base_score + rnorm(1, 0, 5))),
          comprehension = pmax(0, pmin(100, base_score + rnorm(1, -5, 8)))
        ))
      }
    }
  }
  
  return(phonics_data)
}

# Generate initiative trial data
generate_initiatives <- function(schools, n_initiatives = 25) {
  
  initiative_names <- c(
    "Digital Learning Enhancement", "STEM Accelerator Program", "Literacy First Initiative",
    "Social-Emotional Learning", "Teacher Development Program", "Parent Engagement Initiative",
    "Technology Integration", "Arts Education Expansion", "Health & Wellness Program",
    "Community Partnership", "Early Childhood Development", "Advanced Mathematics",
    "Science Lab Modernization", "Library Resource Enhancement", "Special Needs Support",
    "English Language Support", "Career Readiness Program", "Environmental Education",
    "Music Education Program", "Physical Education Enhancement", "Mental Health Support",
    "Nutrition Education", "Safety & Security Program", "Transportation Improvement",
    "Facilities Upgrade Initiative"
  )
  
  initiatives <- tibble()
  
  for(i in 1:n_initiatives) {
    
    # Random selection of participating schools
    participating_schools <- sample(schools$school_id, sample(10:50, 1))
    
    initiative_data <- tibble(
      initiative_id = sprintf("INIT%03d", i),
      initiative_name = sample(initiative_names, 1),
      start_date = sample(seq(as.Date("2023-01-01"), as.Date("2024-06-30"), by = "day"), 1),
      planned_duration_months = sample(6:24, 1),
      status = sample(c("Active", "Completed", "Planning", "On Hold"), 1, prob = c(0.4, 0.3, 0.2, 0.1)),
      budget_allocated = sample(seq(50000, 500000, 10000), 1),
      schools_participating = length(participating_schools),
      target_students = sum(schools$total_enrollment[schools$school_id %in% participating_schools]),
      primary_focus = sample(c("Academic Achievement", "Student Wellness", "Teacher Development", 
                              "Technology", "Infrastructure", "Community"), 1)
    )
    
    initiatives <- bind_rows(initiatives, initiative_data)
    
    # Generate school-level initiative participation data
    for(school_id in participating_schools) {
      school_participation <- tibble(
        initiative_id = sprintf("INIT%03d", i),
        school_id = school_id,
        participation_start = sample(seq(initiative_data$start_date, 
                                        initiative_data$start_date + months(3), by = "day"), 1),
        baseline_metric = runif(1, 40, 80),
        current_metric = baseline_metric + rnorm(1, 5, 10),
        participation_level = sample(c("High", "Medium", "Low"), 1, prob = c(0.4, 0.4, 0.2))
      )
      
      if(i == 1) {
        initiative_participation <- school_participation
      } else {
        initiative_participation <- bind_rows(initiative_participation, school_participation)
      }
    }
  }
  
  return(list(initiatives = initiatives, participation = initiative_participation))
}

# Main data generation function
main <- function() {
  
  cat("Generating synthetic education data...\n")
  
  # Generate all datasets
  schools <- generate_schools(500)
  enrollment <- generate_enrollment(schools)
  performance <- generate_performance(schools)
  phonics <- generate_phonics_tests(schools)
  initiative_data <- generate_initiatives(schools)
  
  # Add headers indicating synthetic data
  header_comment <- paste0(
    "# SYNTHETIC DATA - Generated for demonstration purposes only\n",
    "# All data is artificial and created through AI\n",
    "# Generated on: ", Sys.Date(), "\n",
    "# This data does not represent real schools or students\n"
  )
  
  # Write data to CSV files with proper headers
  cat("Writing school data...\n")
  writeLines(c(header_comment, ""), "data/synthetic-schools.csv")
  write_csv(schools, "data/synthetic-schools.csv", append = TRUE)
  
  cat("Writing enrollment data...\n")
  writeLines(c(header_comment, ""), "data/synthetic-enrollment.csv")
  write_csv(enrollment, "data/synthetic-enrollment.csv", append = TRUE)
  
  cat("Writing performance data...\n")
  writeLines(c(header_comment, ""), "data/synthetic-performance.csv")
  write_csv(performance, "data/synthetic-performance.csv", append = TRUE)
  
  cat("Writing phonics test data...\n")
  writeLines(c(header_comment, ""), "data/synthetic-phonics-tests.csv")
  write_csv(phonics, "data/synthetic-phonics-tests.csv", append = TRUE)
  
  cat("Writing initiative data...\n")
  writeLines(c(header_comment, ""), "data/synthetic-initiatives.csv")
  write_csv(initiative_data$initiatives, "data/synthetic-initiatives.csv", append = TRUE)
  
  cat("Writing initiative participation data...\n")
  writeLines(c(header_comment, ""), "data/synthetic-initiative-participation.csv")
  write_csv(initiative_data$participation, "data/synthetic-initiative-participation.csv", append = TRUE)
  
  cat("Data generation complete!\n")
  cat("Generated files:\n")
  cat("- synthetic-schools.csv (", nrow(schools), " schools)\n")
  cat("- synthetic-enrollment.csv (", nrow(enrollment), " records)\n") 
  cat("- synthetic-performance.csv (", nrow(performance), " records)\n")
  cat("- synthetic-phonics-tests.csv (", nrow(phonics), " records)\n")
  cat("- synthetic-initiatives.csv (", nrow(initiative_data$initiatives), " initiatives)\n")
  cat("- synthetic-initiative-participation.csv (", nrow(initiative_data$participation), " participation records)\n")
}

# Execute main function if script is run directly
if(!interactive()) {
  main()
}