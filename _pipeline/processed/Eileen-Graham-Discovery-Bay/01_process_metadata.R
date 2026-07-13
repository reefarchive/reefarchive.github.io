# Header ----------------------------------------------------------------
# Project: reefarchive.github.io
# File name: process_metadata.R
# Last updated: 2026-07-09
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/LewisAJones/reefarchive.github.io

# Load libraries --------------------------------------------------------
library(readr)
library(dplyr)
library(uuid)
library(lubridate)
library(stringr)

# Load data -------------------------------------------------------------
# Path to original collection metadata
meta <- read.csv("_pipeline/source/Eileen-Graham-Discovery-Bay/Graham_collection.csv")

# Process data ----------------------------------------------------------
meta <- meta |>
  # Drop index column
  select(-X) |>
  # Add collection name
  mutate(CollectionName = "The Eileen Graham Collection (Discovery Bay, Jamaica, 1966 to 1968)") |>
  # Drop extension from file name
  mutate(filename = tools::file_path_sans_ext(meta$filename)) |>
  # Add unique ID numbers (currently these are non-unique)
  mutate(ImageUniqueID = UUIDgenerate(n = nrow(meta))) |>
  # Format time
  mutate(DateTimeOriginal = paste0(format(as.POSIXct(DateTimeOriginal, 
                                                     format = "%Y-%m-%dT%H:%M:%S", 
                                                     tz = "UTC"), 
                                          "%Y:%m:%d %H:%M:%S"))) |>
  mutate(DateTimeOriginal = if_else(is.na(DateTimeOriginal) | DateTimeOriginal == "NA", 
                                    "", 
                                    DateTimeOriginal)) |>
  # Format DateTimeDigitized to follow DateTimeOriginal
  mutate(DateTimeDigitized = paste0(format(as.POSIXct(DateTimeDigitized, 
                                                      format = "%d/%m/%Y %H:%M", 
                                                      tz = "UTC"), 
                                           "%Y:%m:%d %H:%M:%S"))) |>
  # Modify ImageDescription to be a little more verbose
  mutate(ImageDescription = "Photograph from the Eileen Graham Collection (Discovery Bay, Jamaica, 1966 to 1968).") |>
  # Modify copyright description to specify which Natural History Museum
  mutate(Copyright = "Trustees of the Natural History Museum (London, UK), CC-BY-4.0") |>
  # Set to empty character string (currently populated with NA)
  mutate(Depth = "",
         Notes = "") |>
  # Set Note flags (missing dates)
  mutate(Notes = if_else(is.na(DateTimeOriginal) | DateTimeOriginal == "", 
                         "Exact date unknown, likely between 1966 and 1968. ", 
                         Notes)) |>
  # Set Note flags (We don't want this in coordinate columns as they're numeric)
  mutate(Notes = if_else(GPSLongitude == 0 | is.na(GPSLongitude), 
                         # Combines any existing notes
                         paste0(Notes, "Exact coordinates unknown. Discovery Bay Marine Lab used as point of reference."), 
                         Notes)) |>
  # Remove any empty white space around notes
  mutate(Notes = str_trim(Notes)) |>
  # Set invalid coordinates to match location of Discovery Bay Marine Lab
  mutate(GPSLongitude = if_else(GPSLongitude == 0 | is.na(GPSLongitude), -77.41543, GPSLongitude),
         GPSLatitude = if_else(GPSLatitude == 0 | is.na(GPSLatitude), 18.468618, GPSLatitude)) |>
  # EXIF doesn't handle negative numbers, must specify N/S and E/W
  mutate(GPSLongitudeRef = if_else(sign(GPSLongitude) == 1, "E", "W"),
         GPSLatitudeRef = if_else(sign(GPSLatitude) == 1, "N", "S")) |>
  mutate(GPSLongitude = abs(GPSLongitude),
         GPSLatitude = abs(GPSLatitude)) |>
  # Build full locality name with " | " seperator (ignore any NAs e.g. in locality)
  mutate(Locality = apply(cbind(Country, Region, Locality), 1, function(x) {
    paste(x[!is.na(x)], collapse = " | ")
  })) |>
  # Drop region (region can often represent an area larger than a country and is not a standard unit)
  # It is also not a consistent field in any standards
  select(-Region) |>
  # Standardise to EXIF/IPTC tags where possible
  # Rename country (IPTC; http://iptc.org/std/photometadata/specification/IPTC-PhotoMetadata-2025.1.html#location-shown-in-the-image)
  rename(LocationShownCountryName = Country) |>
  # Rename locality (IPTC; http://iptc.org/std/photometadata/specification/IPTC-PhotoMetadata-2025.1.html#location-shown-in-the-image)
  rename(LocationShownSublocation = Locality) |>
  # Rename Depth (EXIF: WaterDepth; https://exiv2.org/tags.html)
  rename(WaterDepth = Depth) |>
  # Rename Notes (EXIF: UserComment; https://exiv2.org/tags.html)
  rename(UserComment = Notes) |>
  # Rename file name (XMP-dc:Identifier; https://exiv2.org/tags-xmp-dc.html)
  rename(Identifier = filename) |>
  # There is no equivalent in EXIF, so we can use Dublin Core (see link above)
  # Mutate/Rename digitizer (doesn't exist in EXIF), but we can use contributor 
  # from dublin core (XMP-dc:Contributor)
  mutate(Contributor = paste0(Digitizer, " (digitising) | ", "Lewis A. Jones (image processing)")) |>
  # Drop digitizer
  select(-Digitizer) |>
  # Rename link (XMP-dc:Source; https://exiv2.org/tags-xmp-dc.html)
  rename(Source = Link) |>
  # Filter non-uploads
  filter_out(Upload == FALSE) |>
  # Drop column
  select(-Upload) |>
  # Reorder columns
  relocate(
    CollectionName,
    Identifier, 
    ImageUniqueID,
    ImageDescription,
    Photographer, 
    Contributor,
    DateTimeOriginal, 
    DateTimeDigitized,
    LocationShownCountryName, 
    LocationShownSublocation,
    GPSLongitude,
    GPSLongitudeRef,
    GPSLatitude,
    GPSLatitudeRef,
    WaterDepth,
    Copyright, 
    Source,
    UserComment
  )

# Save data -------------------------------------------------------------
write.csv(meta, "_pipeline/processed/Eileen-Graham-Discovery-Bay/metadata.csv", row.names = FALSE)
