% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gdcdata.R
\name{gdcdata}
\alias{gdcdata}
\title{Download GDC files}
\usage{
gdcdata(
  uuids,
  use_cached = TRUE,
  progress = interactive(),
  token = NULL,
  access_method = "api",
  transfer_args = character(),
  ...
)
}
\arguments{
\item{uuids}{character() of GDC file UUIDs.}

\item{use_cached}{logical(1) default TRUE indicating that,
if found in the cache, the file will not be downloaded
again. If FALSE, all supplied uuids will be re-downloaded.}

\item{progress}{logical(1) default TRUE in interactive sessions,
FALSE otherwise indicating whether a progress par should be
produced for each file download.}

\item{token}{(optional) character(1) security token allowing access
to restricted data. See
\url{https://gdc-docs.nci.nih.gov/API/Users_Guide/Authentication_and_Authorization/}.}

\item{access_method}{character(1), either 'api' or 'client'. See details.}

\item{transfer_args}{character(1), additional arguments to pass to
the gdc-client command line. See \code{\link{gdc_client}} and
\code{\link{transfer_help}} for details.}

\item{...}{further arguments passed to files}
}
\value{
a named vector with file uuids as the names and paths as
the value
}
\description{
Download one or more files from GDC. Files are downloaded using the
UUID and renamed to the file name on the remote system. By default,
neither the uuid nor the file name on the remote system can exist.
}
\details{
This function is appropriate for one or several files; for large
downloads use \code{\link{manifest}} to create a manifest for and
the GDC Data Transfer Tool.

When access_method is "api", the GDC "data" endpoint is the
    transfer mechanism used. The alternative access_method, "client", will
    utilize the \code{gdc-client} transfer tool, which must be
    downloaded separately and available. See
    \code{\link{gdc_client}} for details on specifying the location
    of the gdc-client executable.
}
\examples{
# get some example file uuids
uuids <- files() |>
    filter(~ access == 'open' & file_size < 100000) |>
    results(size = 3) |>
    ids()

# and get the data, placing it into the gdc_cache() directory
gdcdata(uuids, use_cached=TRUE)

}
\seealso{
\code{\link{manifest}} for downloading large data.
}
