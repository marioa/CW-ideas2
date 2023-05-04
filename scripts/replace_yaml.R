# script to replace existing YAML with new YAML

# load packages
library(jsonlite)
library(yaml)
library(ymlthis)

# read in new yaml from JSON
json <- jsonlite::read_json("data/metadata-tidied.txt")[[1]]

# helper function to reformat authors/tags
split_items <- function(x){
  if (is.null(x)) return()
  strsplit(x, "|", fixed = TRUE)[[1]]
}

# update old yaml with new yaml
yml <- lapply(json, as_yml)
for (i in seq_along(yml)){
  # remove filename and draft if "~"
  yml[[i]] <- yml_discard(yml[[i]], "filename")
  if (is.null(yml[[i]]$draft)) yml[[i]] <- yml_discard(yml[[i]], "draft")
  
  # reformat authors and tags
  yml[[i]] <- yml_replace(yml[[i]], 
                          author = split_items(yml[[i]]$author),
                          tags = split_items(yml[[i]]$tags))
  
  # get original content and find end of yaml header
  all_content <- readLines(json[[i]]$filename)
  end_yaml <- grep("^---$", all_content)[2]
  
  # write back to markdown
  use_rmarkdown(.yml = yml[[i]], json[[i]]$filename,
                body = all_content[-seq_len(end_yaml)],
                open_doc = FALSE, overwrite = TRUE)
}
