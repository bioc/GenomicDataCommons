#' Start a query of GDC metadata
#'
#' The basis for all functionality in this package
#' starts with constructing a query in R. The GDCQuery
#' object contains the filters, facets, and other
#' parameters that define the returned results. A token
#' is required for accessing certain datasets.
#'
#' @aliases GDCQuery
#' 
#' @param entity character vector of 'cases','files','annotations',
#' or 'projects'
#' @param filters a filter list
#' @param facets a facets list
#' @param token a character string reprenting the token
#' @param archive one of either 'default' or 'legacy'. See \url{https://docs.gdc.cancer.gov/Data_Portal/Users_Guide/Legacy_Archive/} and \url{https://gdc-portal.nci.nih.gov/legacy-archive/search/f} for details.
#' @param fields a character vector of fields to return
#' @param expand a character vector of "expands" to include in returned data
#' 
#' @return An S3 object, the GDCQuery object. This is a list
#' with the following members.
#' \itemize{
#' \item{filters}
#' \item{facets}
#' \item{fields}
#' \item{expand}
#' \item{archive}
#' \item{token}
#' }
#'
#' @examples
#' qcases = query('cases')
#' # equivalent to:
#' qcases = cases()
#' 
#' @export
query = function(entity,
                 token=NULL,
                 filters=NULL,
                 facets=NULL,
                 archive = 'default',
                 expand = NULL,
                 fields=default_fields(entity)) {
    stopifnot(entity %in% .gdc_entities)
    ret = structure(
        list(
            fields    = fields,
            filters   = filters,
            facets    = facets,
            archive   = archive,
            expand    = expand,
            token     = token),
        class = c(paste0('gdc_',entity),'GDCQuery','list')
    )
    return(ret)
}


#' @describeIn query convenience contructor for a GDCQuery for cases
#'
#' @param ... passed through to \code{\link{query}}
#' 
#' @export
cases = function(...) {return(query('cases',...))}

#' @describeIn query convenience contructor for a GDCQuery for cases
#' @export
files = function(...) {return(query('files',...))}

#' @describeIn query convenience contructor for a GDCQuery for cases
#' @export
projects = function(...) {return(query('projects',...))}

#' @describeIn query convenience contructor for a GDCQuery for annotations
#' @export
annotations = function(...) {return(query('annotations',...))}

