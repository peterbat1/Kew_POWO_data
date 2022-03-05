# Automagically extract information on native and non-native distribution of
# plant taxa from the Kew Gardens' World of Plants On-line website.
# 
# The script mimics the actions of a user in a web browser using the resources
# provided by the R package httr.
#
# You will need to supply a taxonomic name to the function defined below.
#
# For a SUCCESSFUL match, the function returns a named list with two elements:
#
#   nativeCodes:     A character vector of TDWG Level 3 region name codes for
#                    native occurrences of the taxon; and,
#
#   non_nativeCodes: A character vector of TDWG Level 3 region codes for
#                    non-native occurrences of the taxon.
#
# For an UNSUCCESSFUL match, the function returns empty character vectors (i.e.
# you can test for an unsuccessful search by testing the content of BOTH list
# elements) and prints a message to the R console.
#
# Peter D. Wilson
# Adjunct Fellow
# Dept. of Natural Sciences
# Faculty of Science and Engineering
# Macquarie University, North Ryde, NSW, Australia 2109
#
# e. peterdonaldwilson@gmail.com
#
# 2022-02-28; 2022-03-01 


library(httr)

### Some test taxa

# A native Australian species with a limited distirbution including a few exotic
# (extra-limital) occurrences
# thisGenus <- "Syzygium"
# thisSpecificEpithet <- "smithii"

# An Australian native now widely distributed across the globe, often present as
# a invasive species
# thisGenus <- "Eucalyptus"
# thisSpecificEpithet <- "globulus"

# A name apparently once recognised by Kew but not longer accepted
# thisGenus <- "Aberema"
# thisSpecificEpithet <- "jupunba"

fetch_POWO_distro <- function(thisTaxon, trace = FALSE)
{
  nameParts <- unlist(strsplit(thisTaxon, " "))
  
  thisURL <- paste0("https://wcsp.science.kew.org/advsearch.do?page=advancedSearch&AttachmentExist=&family=&genus=", nameParts[1],"&species=", nameParts[2], "&infraRank=&infraEpithet=&author=&placeOfPub=&yearPublished=&selectedLevel=are")
  
  # Fetch the packet of stuff from the web service:
  ans <- httr::POST(thisURL)
  
  # Extract the content from the surrounding technical waffle:
  payload <- httr::content(ans, as = "text")
  
  # Further steps are required to extract useful elements from the HTML document.
  #
  # Note: there are alternate methods for extraction from html/xml documents
  # (particularly within the tidyverse collection of R packages), but I have
  # chosen a steam-powered method to give a transparent and tweakable process:
  
  # First, split into lines of text:
  unpacked <- trimws(unlist(strsplit(payload, "\n")))
  
  # Second, have we got any kind of name match?
  if (any(grepl("Your search returned no results, please refine your search criteria", unpacked)))
  {
    cat("Name is not accepted by POWO\n")
    return(list(nativeCodes = "",
                non_nativeCodes = "")
    )
  }
  else
  {
    
    # Third, Have we got a "final" results page or an "intermediate" page?
    if (any(grepl("records retrieved", unpacked)))
    {
      # We have been served an intermediate page and we need to organise a call to the final page
      # First, find the line of the accepted name - assume it is the first line marked in "bold" html text
      #startTaxonLine <- grep("indicate accepted names, plain list indicates non accepted names", unpacked) + 1
      thisEntry <- unpacked[grep("onwardnav", unpacked)[1]]
      speciesPageURL <- paste0("https://wcsp.science.kew.org", gsub("\"", "", strsplit(strsplit(thisEntry, "<p><a href=\"")[[1]][2], " class=")[[1]][1]))
      
      ans <- httr::POST(speciesPageURL)
      
      # Extract the content from the surrounding technical waffle:
      payload <- httr::content(ans, as = "text")
      
      # First, split into lines of text:
      unpacked <- trimws(unlist(strsplit(payload, "\n")))
    }
    
    # Fourth, process the final results page:
    #
    # Find the line numbers marking the start and end of the useful taxonomic info:
    dataStart <- grep("<div class=\"container-fluid\">", unpacked)
    dataEnd <- grep("Original Compiler:", unpacked)
    
    # Condense down to lines which will have meaningful info
    targetItems <- unpacked[(dataStart + 1):(dataEnd - 1)]
    
    # Remove blank lines
    targetItems <- targetItems[-which(targetItems == "")]
    
    # Remove lines starting with markers for a HTML table elements
    targetItems <- targetItems[-grep("^<t|</t", targetItems)]
    
    # Index of the line storing the taxonomic name: not really need at the moment,
    # but we know where it is for future reference:
    taxonNameInd <- grep("plantname", targetItems)
    
    # Find lines marking the block of lines storing the desired TDWG Level 3
    # distribution codes:
    distroStart <- grep("Distribution:", targetItems) + 2
    distroEnd <- grep("Lifeform:", targetItems) - 1
    
    # ...and grab the codes...
    distroCodes <- targetItems[distroStart:distroEnd]
    
    # Now for some sneaky stuff. It appears non-native distributions are
    # represented by the TDWG Level 3 code being shown in lowercase text. We can
    # easily use this to grab only those entries in distroCodes:
    introInd <- grep("[[:lower:]]", distroCodes)
    
    # A bit of a tidy-up as some entries have numeric indices for Level 2 codes and
    # some punctuation i.e. "(51)"
    non_nativeCodes <- toupper(trimws(gsub("[[:punct:]]|[[:digit:]]", "", distroCodes[introInd])))
    
    nativeCodes <- trimws(gsub("[[:punct:]]|[[:digit:]]", "", distroCodes[-introInd]))
    
    if (trace)
    {
      cat("  Search name:", thisTaxon, "\n")
      cat("    Native range TDWG Level 3 codes:", paste(nativeCodes, collapse = ", "), "\n")
      cat("    Non-mnative range TDWG Level 3 codes:", paste(non_nativeCodes, collapse = ", "), "\n")
    }
    
    return(list(nativeCodes = nativeCodes,
                non_nativeCodes = non_nativeCodes))
  }
}
