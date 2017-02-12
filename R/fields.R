#' S3 Generic to return all GDC fields
#'
#' @param x A character string ('cases','files','projects',
#' 'annotations') or an subclass of \code{\link{GDCQuery}}.
#' @return a character vector of the default fields
#'
#' @examples
#' available_fields('projects')
#' projQuery = query('projects')
#' available_fields(projQuery)
#' 
#' @export
available_fields = function(x) {
    UseMethod('available_fields',x)
}

#' @describeIn available_fields GDCQuery method
#' @export
available_fields.GDCQuery = function(x) {
    return(mapping(entity_name(x))$field)
}

#' @describeIn available_fields character method
#' @export
available_fields.character = function(x) {
    stopifnot(length(x)==1)
    return(mapping(x)$field)
}


#' S3 Generic to return default GDC fields
#'
#' @param x A character string ('cases','files','projects',
#' 'annotations') or an subclass of \code{\link{GDCQuery}}.
#' @return a character vector of the default fields
#'
#' @examples
#' default_fields('projects')
#' projQuery = query('projects')
#' default_fields(projQuery)
#' 
#' @export
default_fields = function(x) {
    UseMethod('default_fields',x)
}

#' @describeIn default_fields character method
#' @export
default_fields.character = function(x) {
    stopifnot(length(x)==1)
    return(subset(mapping(x),defaults)$field)
}

#' @describeIn default_fields GDCQuery method
#' @export
default_fields.GDCQuery = function(x) {
    return(default_fields(entity_name(x)))
}

#' S3 generic to set GDCQuery fields
#'
#' @param x the objects on which to set fields
#' @param fields a character vector specifying the fields
#' 
#' @importFrom assertthat assert_that
#'
#' @examples
#' gProj = projects()
#' gProj$fields
#' head(available_fields(gProj))
#' default_fields(gProj)
#'
#' library(magrittr)
#' gProj %>%
#'   select(default_fields(gProj)[1:2]) %>%
#'   response() %>%
#'   str(max_level=2)
#' 
#' @export
select <- function(x,fields) {
    UseMethod('select',x)
}

#' rectify specified fields with available fields
#'
.gdcRectifyFieldsForEntity <- function(entity,fields) {
    stopifnot(entity %in% .gdc_entities)
    af = available_fields(entity)
    mismatches = fields[!(fields %in% af)]
    if(length(mismatches)>0)
        stop(sprintf('fields specified included fields not available in %s including (%s)',entity,mismatches))
    fields = union(paste0(sub('s$','',entity),"_id"),fields)
    return(fields)
}

#' @describeIn select set fields on a GDCQuery object
#' @export
select.GDCQuery <- function(x,fields) {
    x$fields = .gdcRectifyFieldsForEntity(entity_name(x),fields)
    return(x)
}