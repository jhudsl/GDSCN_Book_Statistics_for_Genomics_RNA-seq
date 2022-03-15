library(dplyr)
library(stringr)

make_anvil_repo_table <- function(exclude = NULL) {
  # Read in AnVIL repos found by GHA
  df <- tryCatch(
    # Check for the file created by GHA
    expr = {
      df <-
        readr::read_tsv("resources/AnVIL_repos.tsv")
    },
    # Will error out if file doesn't exist - provides a blank tibble instead
    error = function(e) {
      df <- tibble(name = "none", html_url = "none")
    }
  )
  
  # Filter out any user specified repos (could be some that are in progress,
  # templates, etc)
  df <-
    df %>%
    filter(!(name %in% exclude)) %>%
    rename(`Book Name` = name,
           `Link` = html_url) %>%
    arrange(`Book Name`)
  
  # Do some cleaning of strings
  df$`Book Name` <-
    df$`Book Name` %>%
    stringr::str_replace_all("_Book_", ": ") %>%
    stringr::str_replace_all("_", " ")
  
  # Replace github url with DaSL url
  df$Link <-
    stringr::str_replace_all(df$Link,
                             "https://github.com/jhudsl",
                             "https://jhudatascience.org")
  
  return(df)
}
