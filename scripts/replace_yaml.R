# script to replace existing YAML with new YAML

# load packages
library(jsonlite)
library(ymlthis)

# read in new yaml from JSON
json <- jsonlite::read_json("data/metadata-tidied.txt")[[1]]

# helper function to reformat authors/tags
split_items <- function(x){
  if (is.null(x)) return()
  strsplit(x, "|", fixed = TRUE)[[1]]
}

# update old yaml with new yaml
for (i in seq_along(json)){
  message("Idea ", i, ": ", json[[i]]$filename)
  # convert json to yaml
  yml <- as_yaml(json[[i]])
  
  # remove filename and draft if "~"
  yml <- yml_discard(yml, "filename")
  if (is.null(yml$draft)) yml <- yml_discard(yml, "draft")
  
  # reformat authors and tags
  yml <- yml_replace(yml, 
                     author = list(split_items(yml$author)),
                     tags = list(split_items(yml$tags)))
  
  # get original content and find end of yaml header
  all_content <- readLines(json[[i]]$filename)
  end_yaml <- grep("^---$", all_content)[2]
  
  # write back to markdown
  use_rmarkdown(.yml = yml, yml$filename,
                body = all_content[-seq_len(end_yaml)],
                open_doc = FALSE, overwrite = TRUE, quiet = TRUE)
}
