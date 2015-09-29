# 20-extract-sidebars.R
 # 2015.09.25
 require(XML)
 require(stringi)
 
 stxml  <- xmlParse("./enmemoryalpha_pages_current.xml")
 xmltop <- xmlRoot(stxml) # content of root
 
 individual <- list()
 planet     <- list()
 species    <- list()
 starship   <- list()
 n          <- xmlSize(xmltop)
 for (i in 2:n) {
   # get the text in the revision in the page
   title <- xmlValue(xmltop[[i]][["title"]])
   text  <- xmlValue(xmltop[[i]][["revision"]][["text"]])
   # filter a sidebar
   sidebar <- stri_match_all_regex(text,
                                   pattern    = "\\{\\{[Ss][Ii][Dd][Ee][Bb][Aa][Rr]\\s*(.*?)\\n\\}\\}",
                                   opts_regex = stri_opts_regex(dotall = TRUE))[[1]][, 2]
   # if found a sidebar
   if (!is.na(sidebar)) {
     # remove the \n
     sidebar <- stri_replace_all_regex(sidebar, "\\n", "", vectorize_all = FALSE)
     # remove links and templates
     sidebar <- stri_replace_all_regex(sidebar, "[\\[\\]]", "", vectorize_all = FALSE)
     sidebar <- stri_replace_all_regex(sidebar, "\\{\\{(.*?)\\|(.*?)\\}\\}", "$2", 
                                       vectorize_all = FALSE)
     sidebar <- stri_replace_all_regex(sidebar, "\\{\\{(.*?)\\}\\}", "$1", 
                                       vectorize_all = FALSE)
     # remove html comments
     sidebar <- stri_replace_all_regex(sidebar, "<.*?>", "", vectorize_all = FALSE)
     # split the type of sidebar and the tags
     tmp <- stri_match_all_regex(sidebar, pattern = "([\\w/]*)\\|(.*)",
                                 opts_regex = stri_opts_regex(dotall = TRUE))[[1]]
     # collect the sidebar type
     sidebar_type <- tolower(tmp[1, 2])
     if (sidebar_type %in% c("individual", "planet", "species", "starship")) {
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
       values <- stri_replace_all_regex(tmp[, 3], "(\"|'')", "")
 
       if (sidebar_type == "individual") {
         individual[["Title"]] <- c(individual[["Title"]], title)
         for (tag in sort(sidebar_tags[[sidebar_type]])) {
           individual[[tag]] <- c(individual[[tag]], 
                                  ifelse(length(values[which(tags == tag)]) == 0,
                                         NA,values[which(tags == tag)]))
         }
       }
       if (sidebar_type == "planet") {
         planet[["Title"]] <- c(planet[["Title"]], title)
         for (tag in sort(sidebar_tags[[sidebar_type]])) {
           planet[[tag]] <- c(planet[[tag]], 
                              ifelse(length(values[which(tags == tag)]) == 0, 
                                     NA,values[which(tags == tag)]))
         }
       }
       if (sidebar_type == "species") {
         species[["Title"]] <- c(species[["Title"]], title)
         for (tag in sort(sidebar_tags[[sidebar_type]])) {
           species[[tag]] <- c(species[[tag]], 
                              ifelse(length(values[which(tags == tag)]) == 0, 
                                     NA,values[which(tags == tag)]))
         }
       }
       if (sidebar_type == "starship") {
         starship[["Title"]] <- c(starship[["Title"]], title)
         for (tag in sort(sidebar_tags[[sidebar_type]])) {
           starship[[tag]] <- c(starship[[tag]], 
                                ifelse(length(values[which(tags == tag)])  == 0, 
                                       NA,values[which(tags == tag)]))
         }
       }
     }
   }
   if (i %% 5000 == 0) {
     print(sprintf("%d / %d", i, n))
   }
 }
 print(sprintf("%d / %d", i, n))
 individual <- data.frame(individual, stringsAsFactors = FALSE)
 individual <- individual[!grepl("(Template:|Talk:|User:)", individual$Title), ]
 write.csv(file = "individual.csv", x = individual, quote = TRUE, row.names = FALSE)
 
 planet <- data.frame(planet, stringsAsFactors = FALSE)
 planet <- planet[!grepl("(Template:|Talk:)", planet$Title), ]
 write.csv(file = "planet.csv", x = planet, quote = TRUE, row.names = FALSE)
 
 species <- data.frame(species, stringsAsFactors = FALSE)
 species <- species[!grepl("(Template:|Talk:)", species$Title), ]
 write.csv(file = "species.csv", x = species, quote = TRUE, row.names = FALSE)
 
 starship <- data.frame(starship, stringsAsFactors = FALSE)
 starship <- starship[!grepl("(Template:|Talk:)", starship$Title), ]
 write.csv(file = "starship.csv", x = starship, quote = TRUE, row.names = FALSE)
