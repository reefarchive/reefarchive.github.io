# Header ----------------------------------------------------------------
# Project: reefarchive.github.io
# File name: download_collection.R
# Last updated: 2026-09-29
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/LewisAJones/reefarchive.github.io

# Load libraries --------------------------------------------------------
library(zen4R)
library(curl)
library(magick)
library(dplyr)
library(glue)
library(readr)

# Setup -------------------------------------------------------------------
collection <- "DiscoveryBay-Jamaica-1966-1968-EileenGraham"
collection_dir <- file.path("collections", collection)
zip_file <- file.path(collection_dir, paste0(collection, ".zip"))
media_dir <- file.path(collection_dir, "media")
web_dir <- file.path(collection_dir, "img")

dir.create(web_dir, showWarnings = FALSE, recursive = TRUE)

# Download data ---------------------------------------------------------
options(timeout = 6000) # 100 minutes, adjust to file size

# Get record metadata (no download yet)
zenodo <- ZenodoManager$new()
rec <- zenodo$getRecordByDOI("10.5281/zenodo.23036655")

# Find the file entry for the zip
file_info <- rec$files[[which(
  sapply(rec$files, function(f) f$filename) ==
    "DiscoveryBay-Jamaica-1966-1968-EileenGraham.zip"
)]]

file_url <- file_info$download
zip_file <- file.path(collection_dir, file_info$filename)

# Resumable, retry-capable download
dir.create(collection_dir, showWarnings = FALSE, recursive = TRUE)

result <- curl::multi_download(
  urls = file_url,
  destfiles = zip_file,
  resume = TRUE, # picks up where it left off if run again
  progress = TRUE
)

print(result)

# Process data ------------------------------------------------------------
# Unzip to collections
unzip(zipfile = zip_file, exdir = "collections")

# Read media file
media <- read.csv(file.path(collection_dir, "media.csv"))

# Convert images to webp for website use
# (light versions, ~100 kb; not for archiving)
for (i in seq_len(nrow(media))) {
  img <- image_read(file.path(media_dir, media$fileName[i]))
  img_web <- image_resize(img, "1000x")

  out_name <- paste0(tools::file_path_sans_ext(media$fileName[i]), ".webp")
  image_write(img_web, path = file.path(web_dir, out_name), format = "webp")
}

# Update file extensions
media$fileName <- sub(".png", ".webp", media$fileName)
write_excel_csv(media, file.path(collection_dir, "media.csv"), na = "")

# Clean up files
unlink(file.path(collection_dir, "media"), recursive = TRUE)
unlink(file.path(
  collection_dir,
  "DiscoveryBay-Jamaica-1966-1968-EileenGraham.zip"
))
# Rename img folder to media
file.rename(
  file.path(collection_dir, "img"),
  file.path(collection_dir, "media")
)
