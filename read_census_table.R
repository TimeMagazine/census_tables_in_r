# Load CSV files downloaded from the Census FactFinder

# Get basic data about this data: The name, code and sample
read_census_table_info <- function(directory, file_name) {
  output <- data.frame(
    field=character(),
    value=character(),
    stringsAsFactors=FALSE
  )
  
  output[1,] <- list("id", file_name)

  # table info
  con <- file(paste(directory, "/", file_name, "/", file_name, ".txt", sep=""), "r")
  lines <- readLines(con)
  close(con)
  
  for (c in 1:length(lines)) {
    line <- lines[c]
    if (line == "") {
      next
    }
    if (c == 1) {
      output[2,] <- list("code", line)
      next
    }
    if (c == 2) {
      output[3,] <- list("name", line)
      next
    }
    if (grepl("^Source:", line)) {
      output[4,] <- list("sample", sub("Source: +", "", line))
      break
    }
  }

  return(output)  
}

read_census_table <- function(directory, file_name, field_names, ignore_MOE=TRUE) {
  output <- data.frame(
    location=character(),
    fips=character(),
    field=character(),
    code=character(),
    value=numeric(),
    stringsAsFactors=FALSE
  )

  census  <- read.csv(paste(directory, "/", file_name, "/", file_name, "_with_ann.csv", sep=""), header=TRUE, stringsAsFactors=FALSE)
  
  # CLARIFYING THE HEADERS
  # these files come with double headers:
  # --The first row are indecipherable codes, like "HC03_EST_VC01"
  # --The second row are descriptions, like "Foreign born; Estimate; Total population"
  # This is detailed in the file with the suffix "_metadata.csv", but let's do organically
  # with a data frame matching the codes to the descriptions 
  header_codes <- as.data.frame(
    t(rbind(as.character(census[1,]), colnames(census))),
    stringsAsFactors=FALSE
  )
  colnames(header_codes) <- c("field", "code")

  if (ignore_MOE) {
    header_codes <- subset(header_codes, !grepl("Margin of Error", header_codes))
  }
    
  # FWIW, the first three top-line codes, "GEO.id", "GEO.id2" and "GEO.display.label",
  # Typically represent a long Census id, the geographic fips code, and the location name
  
  # eliminate that header row from the actual data
  census <- census[2:NROW(census),]
  
  # rather than track down the exact name of the field you want, you can optionally enter text
  # and we'll hunt down matching descriptions.
  # This will return all matching columns, which sometimes you want. Otherwise, be more specific
  # "field_words" can either be a string or a vector of strings that all must match
  # e.g. "Native; Estimate; Under 5 years" or c("Foreign born", "Naturalized citizen", "5 to 17 years")
  
  match_text_to_field <- function(field_words) {
    field_words_string <- paste(field_words, collapse=" & ")
    print(paste("Searching Census fields for", field_words_string))
    matches <- header_codes
    for (d in field_words) {
      matches <- subset(matches, grepl(d, matches$field))
      #print(paste(d, NROW(matches)))
      if (NROW(matches) == 0) {
        print(paste("Couldn't match", field_words_string, "to a code"))
        return(NULL);
      }
    }
    if (NROW(matches) > 1) {
      print(paste("FYI, multiple results:", field_words_string, "matched to", NROW(matches), "fields:"))
      for (i in 1:NROW(matches)) {
        print(paste("--", paste(matches[i,]$field, "-- code", matches[i,]$code)))
      }
    } else {
      print(paste("Matched", field_words_string, "to", matches$field, "-- code", matches$code))
    }
    return(matches);
  }
  
  for (field_name in field_names) {
    matches <- match_text_to_field(field_name);
    if (!is.null(matches)) {
      for (i in 1:NROW(matches)) {
        match <- matches[i,]
        for (c in 1:NROW(census)) {
          output[NROW(output)+1,] <- list(
            census[c,]$GEO.display.label,
            census[c,]$GEO.id2,
            match$field,
            match$code,
            census[c,][[match$code]]
          )
          #print(paste(match$field, NROW(output)))
        }
      }
    }
  }
  
  return(output)
}