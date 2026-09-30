#' Print a Quarto lightbox gallery from a media table
#'
#' Designed for a chunk with `results: asis`.
#'
#' @param media           Data frame with one row per media.
#' @param fileName        Column containing media file names.
#' @param mediaDir          Directory prefix for media links (relative to the .qmd).
#' @param caption_fields  Columns for the lightbox caption: unnamed vector of column
#'                        names, or named `c(label = "column")`. NA/empty values are dropped.
#' @param group           Lightbox group name.
#' @param ncol            Number of gallery columns.
#'
#' @return Invisibly, the markdown string (it is also printed).
add_gallery <- function(
  media,
  fileName = "fileName",
  mediaDir = "media",
  caption_fields = NULL,
  group = "gallery",
  ncol = 4
) {
  paths <- file.path(mediaDir, as.character(media[[fileName]]))

  labels <- names(caption_fields)
  if (is.null(labels)) {
    labels <- unname(caption_fields)
  }
  labels[labels == ""] <- unname(caption_fields)[labels == ""]

  captions <- vapply(
    seq_len(nrow(media)),
    function(i) {
      vals <- vapply(
        unname(caption_fields),
        function(f) as.character(media[[f]][i]),
        character(1)
      )
      keep <- !is.na(vals) & nzchar(vals)
      paste0("**", labels[keep], ": **", vals[keep], collapse = "<br>")
    },
    character(1)
  )
  captions <- gsub('"', "&quot;", captions, fixed = TRUE)

  md <- paste(
    c(
      sprintf("::: {layout-ncol=%s .gallery}", ncol),
      "",
      sprintf(
        '![](%s){.lightbox group="%s" description="%s" alt="%s"}\n',
        paths,
        group,
        captions,
        captions
      ),
      "",
      ":::"
    ),
    collapse = "\n"
  )

  cat(md, "\n")
  invisible(md)
}
