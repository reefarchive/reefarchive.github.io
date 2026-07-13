# Header ----------------------------------------------------------------
# Project: reefarchive.github.io
# File name: 01_convert_to_png.R
# Last updated: 2026-07-10
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/reefarchive/reefarchive.github.io

# Load libraries --------------------------------------------------------
# install.packages("readr", "magick", "exiftoolr", "uuid")
library(magick)
library(exiftoolr)

# First-time setup: downloads ExifTool if not already installed
# This should work (but I had to use a manual, local installation, L17)
# install_exiftool()
# install_exiftool(local_exiftool = "path/to/downloaded/exiftool-13.59.zip")
# Verify ExifTool is working
#exiftoolr::exif_version()

# Load metadata
meta <- read.csv("_pipeline/processed/Eileen-Graham-Discovery-Bay/metadata.csv")

# 1. Settings -----------------------------------------------------------
# Collection name
collection <- "Eileen-Graham-Discovery-Bay"
# Input directory
input_dir <- paste0("_pipeline/source/", collection, "/")
# Output directory
output_dir <- paste0("_pipeline/processed/", collection, "/")
# Create new directory
dir.create(output_dir)
# PNG files
dir.create(paste0(output_dir, "png"))
# WEBP files
dir.create(paste0(output_dir, "webp"))

# 2. Find all files -----------------------------------------------------
# Add extension to file names
meta$Identifier <- paste0(meta$Identifier, ".tif")
# Report number of files to process
message(length(meta$Identifier), " file(s) to process.")

# 3. Process image ------------------------------------------------------
# Run across metadata
for (i in seq_len(nrow(meta))) {
  
  # Get file name
  fn <- tools::file_path_sans_ext(meta$Identifier[i])
  # Get file path
  fp <- paste0(input_dir, meta$Identifier[i])
  
  # If file doesn't exist, go to next image 
  # Some images are missing from the NHM repository. Cross referencing 
  # these with the sharepoint repository, these are mostly
  # completely dark images (assuming discarded for lack of use)
  if ( !file.exists(fp) ) next
  
  # Create image paths
  png_path  <- paste0(output_dir, "/png/", fn, ".png")
  webp_path <- paste0(output_dir, "/webp/", fn, ".webp")
  
  # --- Build image derivatives first (metadata-free) ---
  # Load image
  img <- image_read(fp)
  # Remove existing metadata
  img <- image_strip(img)
  # Convert image depth, results in size reduction by ~75% without
  # notable changes in image quality
  img <- image_convert(img, colorspace = "sRGB", depth = 8)
  # Save as PNG
  image_write(img, path = png_path, format = "png")
  # Create light, website versions of images (~100 kb in size)
  # These are not for archiving, simply for visualising on website
  img_web <- image_resize(img, "1000x")
  image_write(img_web, path = webp_path, format = "webp")
  
  # --- Build the full tag argument set ---
  tag_args <- c(
    "-all=",  # clear all existing metadata first
    paste0("-XMP-mwg-coll:CollectionName=", meta$CollectionName[i]),
    paste0("-XMP-dc:Identifier=", fn),
    paste0("-ImageUniqueID=", meta$ImageUniqueID[i]),
    paste0("-DateTimeOriginal=", meta$DateTimeOriginal[i]),
    paste0("-DateTimeDigitized=", meta$DataTimeDigitized[i]),
    paste0("-ImageDescription=", meta$ImageDescription[i]),
    paste0("-Copyright=", meta$Copyright[i]),
    paste0("-XMP-iptcExt:LocationShownCountryName=", meta$LocationShownCountryName[i]),
    paste0("-XMP-iptcExt:LocationShownSublocation=", meta$LocationShownSublocation[i]),
    paste0("-GPSLatitude=", abs(meta$GPSLatitude[i])),
    paste0("-GPSLatitudeRef=", meta$GPSLatitudeRef[i]),
    paste0("-GPSLongitude=", abs(meta$GPSLongitude[i])),
    paste0("-GPSLongitudeRef=", meta$GPSLongitudeRef[i]),
    paste0("-WaterDepth=", if (!is.na(meta$WaterDepth[i])) meta$WaterDepth[i] else ""),
    paste0("-UserComment=", meta$UserComment[i]),
    paste0("-Photographer=", meta$Photographer[i]),
    paste0("-XMP-dc:Contributor=", meta$Contributor[i]),
    paste0("-XMP-dc:Source=", meta$Source[i]),
    "-overwrite_original"
  )
  
  # --- Apply tags to each output file (one exiftool call per file) ---
  exif_call(path = png_path,  args = tag_args)
  exif_call(path = webp_path, args = tag_args)
}

# Report
message("Done. ", length(meta$Identifier), " file(s) processed.")
