# Header ----------------------------------------------------------------
# Project: workflows
# File name: upload_images.R
# Last updated: 2026-07-10
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/LewisAJones/workflows

# Load libraries --------------------------------------------------------
library(httr2)

# Define function -------------------------------------------------------
ia_upload <- function(
    file_path, # Where is the photograph located
    identifier, # Unique ID of item
    file_name = NULL, # name to use on IA; defaults to basename of file_path
    validate_identifier = "True",
    access_key = Sys.getenv("IA_ACCESS_KEY"), # Secret keys (must define in enviornment)
    secret_key = Sys.getenv("IA_SECRET_KEY"), # Secret keys (must define in enviornment)
    metadata = list( # Define metadata to upload
      title = identifier,
      mediatype = "image"
    )
) {
  if (is.null(file_name)) file_name <- basename(file_path)
  # Build metadata headers: x-archive-meta-<field>:<value>
  meta_headers <- setNames(
    as.character(metadata),
    paste0("x-archive-meta-", names(metadata))
  )
  
  req <- request("https://s3.us.archive.org") |>
    req_url_path(paste0("/", identifier, "/", file_name)) |>
    req_method("PUT") |>
    req_headers(
      Authorization             = paste0("LOW ", access_key, ":", secret_key),
      `x-archive-auto-make-bucket` = "1",
      `x-archive-queue-derive`  = "0",  # skip derive step for speed
      !!!meta_headers
    ) |>
    req_body_file(file_path) |>
    req_retry(max_tries = 3, backoff = ~ 30)  # IA sometimes returns 503
  
  resp <- req_perform(req)
  resp_status(resp)
}

# Run script ------------------------------------------------------------
# Pull in data
dat <- read.csv("_pipeline/processed/Eileen-Graham-Discovery-Bay/metadata.csv")
# Run function
i <- 1
ia_upload(
  file_path = paste0("_pipeline/processed/Eileen-Graham-Discovery-Bay/png/", dat$Identifier[i], ".png"),
  identifier = paste0("ReefArchive-", dat$ImageUniqueID[i]),
  metadata = list(
    file = dat$Identifier[i],
    description = dat$ImageDescription[i],
    creator = dat$Photographer[i],
    contributor = dat$Contributor[i],
    date = format(as.Date(dat$DateTimeOriginal[i], format = "%Y:%m:%d"), "%Y-%m-%d"),
    scandate = format(as.Date(dat$DateTimeDigitized[i], format = "%Y:%m:%d"), "%Y-%m-%d"),
    country = dat$LocationShownCountryName[i],
    location = dat$LocationShownSublocation[i],
    decimallongitude = if (dat$GPSLongitudeRef[i] == "W") dat$GPSLongitude[i] * -1 else dat$GPSLongitude[i],
    decimallatitude = if (dat$GPSLatitudeRef[i] == "S") dat$GPSLatitude[i] * -1 else dat$GPSLatitude[i],
    depth = if (is.na(dat$WaterDepth[i])) "" else dat$WaterDepth[i],
    copyright = dat$Copyright[i],
    source = dat$Source[i],
    notes = dat$UserComment[i],
    mediatype = "image"
  )
)

