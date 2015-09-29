 # 10-check-tag-variables.R
 # 2015.09.25
 require(XML)
 require(stringi)
 
 stxml  <- xmlParse("./ma.xml") # dump file from 2015.07.18
 xmltop <- xmlRoot(stxml) # content of root 
 
 sidebar_tags  <- list()
 sidebar_count <- list()
 n             <- xmlSize(xmltop) # number of nodes
 # for all pages (all nodes skipping the first one)
 for (i in 2:n) {
   # get the text in the revision in the page
   text <- xmlValue(xmltop[[i]][["revision"]][["text"]])
   # get the namespace
   ns <- xmlValue(xmltop[[i]][["ns"]])
   # filter a sidebar
   sidebar <- stri_match_all_regex(text,
              pattern    = "\\{\\{[Ss]idebar\\s*(.*?)\\n\\}\\}",
              opts_regex = stri_opts_regex(dotall = TRUE))[[1]][, 2]
   # if found a sidebar in the main namespace
   if (!is.na(sidebar) & ns == "0") {
     # remove the \n
     sidebar <- stri_replace_all_regex(sidebar, "\\n", "", vectorize_all = FALSE)
     # remove links and templates marks
     sidebar <- stri_replace_all_regex(sidebar, "[\\[\\]]", "", vectorize_all = FALSE)
     sidebar <- stri_replace_all_regex(sidebar, "\\{\\{(.*?)\\|(.*?)\\}\\}", "$2", 
                vectorize_all = FALSE)
     sidebar <- stri_replace_all_regex(sidebar, "\\{\\{(.*?)\\}\\}", "$1", 
                vectorize_all =  FALSE)
     # remove html comments
     sidebar <- stri_replace_all_regex(sidebar, "<.*?>", "", vectorize_all = FALSE)
     # split the type of sidebar and the tags
     tmp <- stri_match_all_regex(sidebar,
     #                            pattern    = "([\\w/]*)\\|(.*)",
                                 pattern    = "(.*?)\\|(.*)",
                                 opts_regex = stri_opts_regex(dotall = TRUE))[[1]]
     # collect the sidebar type
     sidebar_type <- tolower(tmp[1, 2])
     if (sidebar_type %in% c("individual", "planet", "species", "starship", "year", "trading cards")) {
       # collect the remaining text
       tmp <- tmp[1, 3]
       # split fields
       tmp <- stri_split_fixed(tmp, pattern    = "|",
                              opts_regex = stri_opts_regex(dotall = TRUE))[[1]]
       # remove empty fields
       tmp <- tmp[tmp != ""]
       # remove leading and trailing spaces
       tmp <- stri_trim(tmp)
       # split the tags and their values
       tmp <- do.call(rbind,stri_match_all_regex(tmp, pattern = "(.*?)\\s*=\\s*(.*)"))
       # collect the tags
       tags <- tmp[, 2]
       # collect the tags' values
       # values <- stri_replace_all_regex(tmp[, 3], "(\"|'')", "")
       # accumulate the tags for a type of sidebar
       sidebar_tags[[sidebar_type]] <- unique(c(sidebar_tags[[sidebar_type]], tags))
     }
     if (is.null(sidebar_count[[sidebar_type]])) {
       sidebar_count[[sidebar_type]] <- 1
     } else {
       sidebar_count[[sidebar_type]] <- sidebar_count[[sidebar_type]] + 1
     }
   }
   if (i %% 5000 == 0) {
     print(sprintf("%d / %d", i, n))
   }
 }
 print(sprintf("%d / %d", i, n))
 print(lapply(sidebar_tags, sort))
 
 cat("{| class=\"grey\"")
 cat("|+ Statistics for the sidebar counts")
 cat("|-")
 cat("! Variable")
 cat("! Count")
 for (tag in sort(names(sidebar_count))) {
   cat("|-", sep = "\n")
   cat(paste0("| ", tag), sep = "\n")
   cat(paste0("| ", sidebar_count[[tag]]), sep = "\n")
 }
 cat("|}")
