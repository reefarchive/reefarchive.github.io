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
library(tidyverse)

# Process data ----------------------------------------------------------
collections <- list.dirs(
  path = "collections",
  full.names = TRUE,
  recursive = FALSE
)
# Load all files
media <- lapply(collections, function(x) {
  tmp <- read.csv(file.path(x, "media.csv"))
  tmp$filePath <- file.path(x, "media", tmp$fileName)
  tmp$collectionPath <- x
  tmp
})
# Bind data
media <- bind_rows(media)
# Save data
write.csv(media, "data/all-media.csv", row.names = FALSE)
# Summarise
collections <- media |>
  group_by(collectionID) |>
  mutate(numberOfImages = length(mediaID)) |>
  group_by(collectionID, decimalLongitude, decimalLatitude) |>
  mutate(collectionImage = sample(filePath, size = 1)) |>
  mutate(
    location = pmap_chr(
      pick(waterBody, country, stateProvince, county, municipality, locality),
      \(...) {
        x <- c(...)
        x <- x[!is.na(x) & x != ""]
        if (length(x) == 0) NA_character_ else str_flatten(x, collapse = " | ")
      }
    )
  ) |>
  select(
    collectionID,
    collectionName,
    collectionImage,
    collectionPath,
    year,
    decimalLongitude,
    decimalLatitude,
    location,
    numberOfImages
  ) |>
  # Add paths
  mutate(
    collectionPath = paste0("../", collectionPath),
    collectionImage = paste0("../", collectionImage)
  ) |>
  distinct()
# Save data
write.csv(collections, "data/all-collections.csv", row.names = FALSE)
