# Header ----------------------------------------------------------------
# Project: reefarchive.github.io
# File name: 04_create_collection.R
# Last updated: 2026-07-13
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/LewisAJones/reefarchive.github.io

# Load libraries --------------------------------------------------------
library(dplyr)
library(glue)
library(readr)

# Settings --------------------------------------------------------------
# Files
metadata_path <- "_pipeline/processed/Eileen-Graham-Discovery-Bay/metadata.csv"
output_qmd_path <- "collections/discovery-bay-1966/index.qmd"
# Yaml
page_title <- "Discovery Bay, Jamaica (1966—1968)"
page_description <- "A set of 1966—1968 underwater photographs from Discovery Bay, Jamaica, taken by Eileen Graham, a volunteer photographer working within Professor Thomas Goreau’s coral reef research programme at the University of the West Indies. Graham’s images capture the north coast reefs in a state of vibrancy now largely lost, and form part of a wider historical reef-documentation effort dating back to 1946."
page_image <- "img/db037.webp"
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
# Load meta data
meta <- read_csv(metadata_path, show_col_types = FALSE)
meta$filepath <- paste0("img/", meta$Identifier, ".webp")
meta$caption <- paste0(
  "**UUID: **", meta$ImageUniqueID, "<br>",
  "**Date: **", format(as.Date(meta$DateTimeOriginal, format = "%Y:%m:%d"), "%Y-%m-%d"), "<br>", 
  "**Location: **", meta$LocationShownSublocation, "<br>",
  "**Longitude: **", meta$GPSLongitude, "º", meta$GPSLongitudeRef, "<br>",
  "**Latitude: **", meta$GPSLatitude, "º", meta$GPSLatitudeRef, "<br>",
  "**Photographer: **", meta$Photographer, "<br>",
  "**Copyright: **", meta$Copyright
  )

# Filter rows for photos not available
meta <- meta[-which(file.exists(paste0("collections/discovery-bay-1966/", meta$filepath)) == FALSE), ]

#-------------------------------------------------------------------
# 3. Build YAML header
#-------------------------------------------------------------------
yaml_header <- glue(
  '---
title: "{page_title}"
description: "{page_description}"
image: "{page_image}"   # thumbnail shown in the listing grid
categories: {page_categories}
page-layout: full
---

  '
)

btn <- "[NHM Data Portal Repository](https://data.nhm.ac.uk/dataset/coral-reef-imagery-by-eileen-graham-of-jamaica-in-the-1960s){.btn-primary} [Internet Archive Repository](https://archive.org/details/@reef_archive?and%5B%5D=creator%3A%22eileen+graham%22){.btn-primary}"

#-------------------------------------------------------------------
# 4. Build the lightbox gallery grid
#-------------------------------------------------------------------
# Each image becomes: ![caption](path){.lightbox group="..." alt="..."}
image_lines <- meta |>
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
  btn,
  "",
  gallery_block
)

writeLines(qmd_content, output_qmd_path)

message("Wrote ", length(image_lines), " image(s) to ", output_qmd_path)
