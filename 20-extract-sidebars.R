 # 20-extract-sidebars.R
 # 2015.09.25
 require(XML)
 require(stringi)
 
 stxml  <- xmlParse("./ma.xml") # dump file from 2015.07.18
 xmltop <- xmlRoot(stxml) # content of root
 
 sbone    <- list()
 sbtwo    <- list()
 sbthr    <- list()
 sbfou    <- list()
 sbfiv    <- list()
 sbsix    <- list()
 n        <- xmlSize(xmltop)
 for (i in 2:n) {
   # get the text in the revision in the page
   title <- xmlValue(xmltop[[i]][["title"]])
   text  <- xmlValue(xmltop[[i]][["revision"]][["text"]])
   # filter a sidebar
   sidebar <- stri_match_all_regex(text,
                                   pattern    = "\\{\\{[Ss]idebar\\s*(.*?)\\n\\}\\}",
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
     tmp <- stri_match_all_regex(sidebar,
                                 # pattern = "([\\w/]*)\\|(.*)",
                                 pattern = "(.*?)\\|(.*)",
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
       values <- stri_replace_all_regex(tmp[, 3], "(\"|'')", "")
 
       if (sidebar_type == "individual") {
         sbone[["Title"]] <- c(sbone[["Title"]], title)
         for (tag in sort(sidebar_tags[[sidebar_type]])) {
           sbone[[tag]] <- c(sbone[[tag]], 
                                  ifelse(length(values[which(tags == tag)]) == 0,
                                         NA,values[which(tags == tag)]))
         }
       }
       if (sidebar_type == "planet") {
         sbtwo[["Title"]] <- c(sbtwo[["Title"]], title)
         for (tag in sort(sidebar_tags[[sidebar_type]])) {
           sbtwo[[tag]] <- c(sbtwo[[tag]], 
                              ifelse(length(values[which(tags == tag)]) == 0, 
                                     NA,values[which(tags == tag)]))
         }
       }
       if (sidebar_type == "species") {
         sbthr[["Title"]] <- c(sbthr[["Title"]], title)
         for (tag in sort(sidebar_tags[[sidebar_type]])) {
           sbthr[[tag]] <- c(sbthr[[tag]], 
                                ifelse(length(values[which(tags == tag)])  == 0, 
                                       NA,values[which(tags == tag)]))
         }
       }
       if (sidebar_type == "starship") {
         sbfou[["Title"]] <- c(sbfou[["Title"]], title)
         for (tag in sort(sidebar_tags[[sidebar_type]])) {
           sbfou[[tag]] <- c(sbfou[[tag]], 
                                ifelse(length(values[which(tags == tag)])  == 0, 
                                       NA,values[which(tags == tag)]))
         }
       }
       if (sidebar_type == "year") {
         sbfiv[["Title"]] <- c(sbfiv[["Title"]], title)
         for (tag in sort(sidebar_tags[[sidebar_type]])) {
           sbfiv[[tag]] <- c(sbfiv[[tag]], 
                                ifelse(length(values[which(tags == tag)])  == 0, 
                                       NA,values[which(tags == tag)]))
         }
       }
       if (sidebar_type == "trading cards") {
         sbsix[["Title"]] <- c(sbsix[["Title"]], title)
         for (tag in sort(sidebar_tags[[sidebar_type]])) {
           sbsix[[tag]] <- c(sbsix[[tag]], 
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
 sbone <- data.frame(sbone, stringsAsFactors = FALSE)
 sbone <- sbone[!grepl("(Template:|Talk:|User:)", sbone$Title), ]
 write.csv(file = "individual.csv", x = sbone, quote = TRUE, row.names = FALSE)
 
 sbtwo <- data.frame(sbtwo, stringsAsFactors = FALSE)
 sbtwo <- sbtwo[!grepl("(Template:|Talk:)", sbtwo$Title), ]
 write.csv(file = "planet.csv", x = sbtwo, quote = TRUE, row.names = FALSE)
 
 sbthr <- data.frame(sbthr, stringsAsFactors = FALSE)
 sbthr <- sbthr[!grepl("(Template:|Talk:)", sbthr$Title), ]
 write.csv(file = "species.csv", x = sbthr, quote = TRUE, row.names = FALSE)
 
 sbfou <- data.frame(sbfou, stringsAsFactors = FALSE)
 sbfou <- sbfou[!grepl("(Template:|Talk:)", sbfou$Title), ]
 write.csv(file = "starship.csv", x = sbfou, quote = TRUE, row.names = FALSE)
 
 sbfiv <- data.frame(sbfiv, stringsAsFactors = FALSE)
 sbfiv <- sbfiv[!grepl("(Template:|Talk:)", sbfiv$Title), ]
 write.csv(file = "year.csv", x = sbfiv, quote = TRUE, row.names = FALSE)
 
 sbsix <- data.frame(sbsix, stringsAsFactors = FALSE)
 sbsix <- sbsix[!grepl("(Template:|Talk:)", sbsix$Title), ]
 write.csv(file = "trading_cards.csv", x = sbsix, quote = TRUE, row.names = FALSE)
