out <- Sys.getenv("QUARTO_PROJECT_OUTPUT_DIR", unset = "_site")

files <- list.files(
  out,
  pattern = "\\.html$",
  recursive = TRUE,
  full.names = TRUE
)

for (f in files) {
  text <- paste(readLines(f, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  new <- gsub('(href="[^"#?]*/)index\\.html', "\\1", text, perl = TRUE)
  if (!identical(text, new)) {
    writeLines(new, f, useBytes = TRUE)
  }
}
