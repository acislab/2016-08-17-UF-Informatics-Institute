# This script require packages, install them once
# install.packages("RSQLite")
# install.packages("ggplot2")
# install.packages("plyr")


# Download database from source if not present
sqlite_url <- "https://acislab.github.io/2016-08-17-UF-Informatics-Institute/survey.sqlite"
sqlite_file <- "data/survey.sqlite"
if (!file.exists(sqlite_file)){
  download.file(url=sqlite_url,
                destfile=sqlite_file,
                mode="wb")
}

# Connect to the database
library(RSQLite)
driver <- dbDriver("SQLite")
con <- dbConnect(drv=driver,
                 dbname=sqlite_file)

# Use this to see the tables
# dbListTables(con)

# Select data in to a dataframe
sql_statement <- "
SELECT Survey.*, Visited.dated
FROM Survey JOIN Visited
ON Survey.taken = Visited.id"

results <- dbSendQuery(con, sql_statement)
readings <- fetch(results)

# Add a year column
readings <- cbind(readings,
                  year=substr(readings$dated, 1, 4))

# Select only salinities
salinities <- readings[which(readings$quant == "sal"),]

# Remove salinities over 1, they are outside the
# valid range for the quantity and must be an
# error
salinities <- salinities[which(salinities$reading <= 1),]

# Make graph
library(ggplot2)
p <- qplot(year, reading, data=salinities)
print(p)

dbClearResult(results)
dbDisconnect(con)
