# Header ----------------------------------------------------------------
# Project: reefarchive.github.io
# File name: prepare_collection.R
# Last updated: 2026-09-27
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
options(timeout = 6000)  # 100 minutes, adjust to file size

# Get record metadata (no download yet)
zenodo <- ZenodoManager$new()
rec <- zenodo$getRecordByDOI("10.5281/zenodo.22663465")

# Find the file entry for the zip
file_info <- rec$files[[which(sapply(rec$files, function(f) f$filename) ==
                                "DiscoveryBay-Jamaica-1966-1968-EileenGraham.zip")]]

file_url <- file_info$download
zip_file <- file.path(collection_dir, file_info$filename)

# Resumable, retry-capable download
dir.create(collection_dir, showWarnings = FALSE, recursive = TRUE)

result <- curl::multi_download(
  urls = file_url,
  destfiles = zip_file,
  resume = TRUE,     # picks up where it left off if run again
  progress = TRUE
)

print(result)

# Process data ------------------------------------------------------------
# Unzip
unzip(zipfile = zip_file, exdir = collection_dir)

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

# Clean up files
unlink(file.path(collection_dir, "media"), recursive = TRUE)
unlink(file.path(collection_dir, "datapackage.json"))
unlink(file.path(collection_dir, "README.md"))
unlink(file.path(collection_dir, "DiscoveryBay-Jamaica-1966-1968-EileenGraham.zip"))

# Create collection -----------------------------------------------------

# setup -----------------------------------------------------------------
# Media
media <- read.csv(file.path(collection_dir, "media.csv"))
media$fileNameUpdated <- sub(pattern = ".png", replacement = ".webp", x = media$fileName)
# Files
output_qmd_path <- file.path(collection_dir, "index.qmd")
# Yaml
page_title <- "Discovery Bay, Jamaica (1966 to 1968)"
doi <- "[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.22663465.svg)](https://doi.org/10.5281/zenodo.22663465)"
page_description <- paste0(
  "A set of underwater photographs from Discovery Bay, Jamaica (1966 to 1968), taken by Eileen Graham. ", 
  "The photographs capture the north coast reefs in a state of vibrancy now largely lost. ")
page_image <- "img/IMG0058.webp"
page_categories <- "[Jamaica, Discovery Bay, 1960s]"
# Define group for lightbox
lightbox_group <- "discovery-bay-1966"
# Number of columns
gallery_ncol <- 4
# File path
col_filepath <- "filepath"
# Image Description
col_caption <- "caption"
# Alt text
col_alt <- "caption"

# Metadata --------------------------------------------------------------

collection_info <- unique(paste0(
  "**collectionID:** ", media$collectionID, " | ",
  "**collectionName:** ", media$collectionName, " | ",
  "**license:** ", media$license, " | ",
  "**rightsHolder:** ", media$rightsHolder
))

media$filepath <- paste0("img/", media$fileNameUpdated)
media$caption <- paste0(
  "**mediaID: **", media$mediaID, "<br>",
  "**year: **", media$year, "<br>",
  "**waterBody: **", media$waterBody, "<br>",
  "**country: **", media$country, "<br>",
  "**county: **", media$county, "<br>",
  "**municipality: **", media$municipality, "<br>",
  "**location: **", media$LocationShownSublocation, "<br>",
  "**decimalLongitude: **", media$decimalLongitude, "<br>",
  "**decimalLatitude: **", media$decimalLatitude, "<br>",
  "**georeferenceRemarks: **", media$georeferenceRemarks, "<br>",
  "**mediaComments: **", media$mediaComments
)

#-------------------------------------------------------------------
# 3. Build YAML header
#-------------------------------------------------------------------
yaml_header <- glue(
  '---
title: "{page_title}"
subtitle: "{doi}"
description: "{page_description}"
image: "{page_image}"   # thumbnail shown in the listing grid
categories: {page_categories}
page-layout: full
---

  '
)

btn <- '<a href="https://doi.org/10.5281/zenodo.22663464" target="_blank" rel="noopener noreferrer" class="btn-primary">**Download Collection**</a>'

#-------------------------------------------------------------------
# 4. Build the lightbox gallery grid
#-------------------------------------------------------------------
# Each image becomes: ![caption](path){.lightbox group="..." alt="..."}
image_lines <- media |>
  mutate(
    filepath_clean = .data[[col_filepath]],
    caption_clean = ifelse(is.na(.data[[col_caption]]), "", .data[[col_caption]]),
    description = ifelse(is.na(.data[[col_caption]]), "", .data[[col_caption]]),
    alt_clean = ifelse(is.na(.data[[col_alt]]), "", .data[[col_alt]]),
    md_line = glue(
      '![]({filepath_clean}){{.lightbox group="{lightbox_group}" description="{caption_clean}" alt="{alt_clean}"}}',
      "\n",
      "\n"
    )
  ) |>
  pull(md_line)

# Wrap in a Quarto layout grid div
gallery_block <- c(
  glue('::: {{layout-ncol={gallery_ncol}}}'),
  "", 
  image_lines,
  "", 
  ':::'
)

#-------------------------------------------------------------------
# 5. Assemble and write the .qmd file
#-------------------------------------------------------------------
qmd_content <- c(
  yaml_header,
  collection_info,
  "",
  btn,
  "",
  gallery_block
)

writeLines(qmd_content, output_qmd_path)

message("Wrote ", length(image_lines), " image(s) to ", output_qmd_path)

# TODO:
# Update footer
# Fix Atlas 
# Add standards 