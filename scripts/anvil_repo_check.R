#!/usr/bin/env Rscript

library(optparse)
library(httr)
library(jsonlite)
library(dplyr)
library(readr)

option_list <- list(
  optparse::make_option(
    c("--git_pat"),
    type = "character",
    default = NULL,
    help = "GitHub personal access token",
  )
)

# Read the GH_PAT argument
opt_parser <- optparse::OptionParser(option_list = option_list)
opt <- optparse::parse_args(opt_parser)
git_pat <- opt$git_pat

message(paste("Checking for AnVIL repositories..."))

# Request search results specific to AnVIL within the jhudsl organization
# and provide the appropriate GH token
req <- httr::GET(
  "https://api.github.com/search/repositories?q=GDSCN+user:jhudsl+OR+AnVIL+user:jhudsl",
  httr::add_headers(Authorization = paste("token", git_pat))
)

if (!(httr::http_error(req))) {
  message(paste("API request successful!"))
  
  # Read in and save data
  repo_dat <-
    jsonlite::fromJSON(httr::content(req, as = "text"), flatten = TRUE)
  repo_df <-
    dplyr::tibble(repo_dat$items) %>% dplyr::select(name, html_url)
  
  # Create an artifact file containing the AnVIL repos, else write an empty file
  if (!dir.exists("resources")) {
    dir.create("resources")
  }
  if (nrow(repo_df) > 0) {
    readr::write_tsv(repo_df, file.path('resources', 'AnVIL_repos.tsv'))
  } else {
    readr::write_tsv(tibble(), file.path('resources', 'AnVIL_repos.tsv'))
  }
  
} else {
  message(paste("API request failed!"))
  if (!dir.exists("resources")) {
    dir.create("resources")
  }
  readr::write_tsv(tibble(), file.path('resources', 'AnVIL_repos.tsv'))
}
