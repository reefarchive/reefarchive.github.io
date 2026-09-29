# Header ----------------------------------------------------------------
# Project: reefarchive.github.io
# File name: compile-data.R
# Last updated: 2026-09-28
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/LewisAJones/reefarchive.github.io

# Load libraries --------------------------------------------------------
library(dplyr)
library(stringr)

# Process data ----------------------------------------------------------
collections <- list.dirs(path = "collections", full.names = TRUE, recursive = FALSE)
# Load all files
media <- lapply(collections, function(x) {
  tmp <- read.csv(file.path(x, "media.csv"))
  tmp$filePath <- file.path(x, "img", 
                            paste0(tools::file_path_sans_ext(tmp$fileName), ".webp"))
  tmp$collectionPath <- x
  tmp
})
# Bind data
media <- bind_rows(media)
# Save data
write.csv(media, "data/media.csv", row.names = FALSE)
# Summarise
collections <- media |>
  group_by(collectionID) |>
  mutate(numberOfImages = length(mediaID)) |>
  group_by(collectionID, decimalLongitude, decimalLatitude) |>
  mutate(collectionImage = sample(filePath, size = 1)) |>
  mutate(location = str_c(waterBody, country, sep = " | ")) |>
  select(collectionID, collectionName, collectionImage, collectionPath,
         year,
         decimalLongitude, decimalLatitude, location, numberOfImages) |>
  # Add paths
  mutate(collectionPath = paste0("../", collectionPath),
         collectionImage = paste0("../", collectionImage)) |>
  distinct()
# Save data
write.csv(collections, "data/collections.csv", row.names = FALSE)


