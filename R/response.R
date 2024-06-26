#' Fetch \code{\link{GDCQuery}} metadata from GDC
#'
#' @aliases GDCResponse
#' 
#' @param x a \code{\link{GDCQuery}} object
#' @param from integer index from which to start returning data
#' @param size number of records to return
#' @param ... passed to httr (good for passing config info, etc.)
#' @param response_handler a function that processes JSON (as text)
#' and returns an R object.  Default is \code{\link[jsonlite]{fromJSON}}.
#' 
#' @rdname response
#'
#' @return A \code{GDCResponse} object which is a list with the following
#' members:
#' \itemize{
#' \item{results}
#' \item{query}
#' \item{aggregations}
#' \item{pages}
#' }
#' 
#' 
#' @examples
#'
#' # basic class stuff
#' gCases = cases()
#' resp = response(gCases)
#' class(resp)
#' names(resp)
#'
#' # And results from query
#' resp$results[[1]]
#' 
#' @export
response = function(x,...) {
    UseMethod('response',x)
}

#' provide count of records in a \code{\link{GDCQuery}}
#'
#' @param x a \code{\link{GDCQuery}} object
#' @param ... passed to httr (good for passing config info, etc.)
#'
#' @return integer(1) representing the count of records that will
#'  be returned by the current query
#' 
#' @examples
#' # total number of projects
#' projects() |> count()
#'
#' # total number of cases
#' cases() |> count()
#' 
#' @export
count = function(x,...) {
    UseMethod('count',x)
}

#' @describeIn count
#'
#' @export
count.GDCQuery = function(x,...) {
    resp = x |> response(size=1)
    return(resp$pages$total)
}    

#' @describeIn count
#'
#' @export
count.GDCResponse = function(x,...) {
    x$pages$total
}


#" (internal) prepare "results" for return
#"
#" In particular, this function sets
#" entity_ids for every element so that
#" one does not loose track of the relationships
#" given the nested nature of GDC returns
.prepareResults <- function(res,idfield) {
    for(i in names(res)) {
        if(inherits(res[[i]],'data.frame'))
            rownames(res[[i]]) = res[[idfield]]
        else
            names(res[[i]]) = res[[idfield]]}
    return(res)
}

#' @rdname response
#' 
#' @importFrom jsonlite fromJSON
#' 
#' @export
response.GDCQuery = function(x, from = 0, size = 10, ...,
                             response_handler = jsonlite::fromJSON) {
    body = Filter(function(z) !is.null(z),x)
    body[['facets']]=paste0(body[['facets']],collapse=",")
    body[['fields']]=paste0(body[['fields']],collapse=",")
    body[['expand']]=paste0(body[['expand']],collapse=",")
    body[['from']]=from
    body[['size']]=size
    body[['format']]='JSON'
    body[['pretty']]='FALSE'
    tmp = response_handler(httr::content(
      .gdc_post(entity_name(x),body=body, token=NULL,...),
                                         as="text", encoding = "UTF-8"))
    res = tmp$data$hits
    idfield = paste0(sub('s$','',entity_name(x)),'_id')
    ## the following code just sets names on the 
    structure(
        list(results = .prepareResults(res,idfield),
             query   = x,
             pages   = tmp$data$pagination,
             aggregations = lapply(tmp$data$aggregations,function(x) {x$buckets})),
        class = c(paste0('GDC',entity_name(x),'Response'),'GDCResponse','list')
    )
}

#' @rdname response
#' 
#' @export
response_all = function(x,...) {
    count = count(x)
    return(response(x=x,size=count,from=0,...))
}


#' aggregations
#'
#' @param x a \code{\link{GDCQuery}} object
#'
#' @return a \code{list} of \code{data.frame} with one
#' member for each requested facet. The data frames
#' each have two columns, key and doc_count.
#' 
#' @examples
#' # Number of each file type
#' res = files() |> facet(c('type','data_type')) |> aggregations()
#' res$type
#'
#' @export
aggregations = function(x) {
    UseMethod('aggregations',x)
}


#' @describeIn aggregations
#'
#'
#' @export
aggregations.GDCQuery = function(x) {
    if(is.null(x$facets))
        x = x |> facet()
    return(response(x)$aggregations)
}

#' @describeIn aggregations
#'
#'
#' @export
aggregations.GDCResponse = function(x) {
    x$aggregations
}


#' results
#'
#' @param x a \code{\link{GDCQuery}} object
#' @param ... passed on to \code{\link{response}}
#' 
#' @return A (typically nested) \code{list} of GDC records
#' 
#' @examples
#' qcases = cases() |> results()
#' length(qcases)
#'
#' @export
results = function(x,...) {
    UseMethod('results',x)
}

#' results_all
#'
#' @param x a \code{\link{GDCQuery}} object
#'
#' @return A (typically nested) \code{list} of GDC records
#' 
#' @examples
#' # details of all available projects
#' projResults = projects() |> results_all()
#' length(projResults)
#' count(projects())
#'
#' 
#' @export
results_all = function(x) {
    UseMethod('results_all',x)
}


#' @describeIn results
#'
#'
#' @export
results.GDCQuery = function(x,...) {
    results(response(x,...))
}

#' @describeIn results_all
#'
#'
#' @export
results_all.GDCQuery = function(x) {
    results(response_all(x))
}

#' @describeIn results
#'
#'
#' @export
results.GDCResponse = function(x,...) {
    structure(
        x$results,
        class=c(sub('Response','Results',class(x)))
    )
}

#' @describeIn results_all
#'
#'
#' @export
results_all.GDCResponse = function(x) {
    structure(
        x$results,
        class=c(sub('Response','Results',class(x)))
    )
}




#' @importFrom xml2 xml_find_all
.response_warnings <- function(warnings, endpoint)
{
    warnings <- vapply(warnings, as.character, character(1))
    if (length(warnings) && nzchar(warnings))
        warning("'", endpoint, "' query warnings:\n", .wrapstr(warnings))
    NULL
}

.response_json_as_list <- function(json, endpoint)
{
    type <- substr(endpoint, 1, nchar(endpoint) - 1L)
    type_id <- sprintf("%s_id", type)
    type_list <- sprintf("%ss_list", type)

    hits <- json[["data"]][["hits"]]
    names(hits) <- vapply(hits, "[[", character(1), type_id)
    hits <- lapply(hits, "[[<-", type_id, NULL)
    hits <- lapply(hits, lapply, unlist) # collapse field elt 'list'
    class(hits) <- c(type_list, "gdc_list", "list")
    hits
}   

#' @importFrom stats setNames
#' @importFrom xml2 xml_find_all xml_text
.response_xml_as_data_frame <- function(xml, fields)
{
    xpaths <- setNames(sprintf("/response/data/hits/item/%s", fields), fields)

    columns <- lapply(xpaths, function(xpath, xml) {
        nodes <- xml_find_all(xml, xpath)
        vapply(nodes, xml_text, character(1))
    }, xml=xml)
    columns <- Filter(length, columns)

    dropped <- fields[!fields %in% names(columns)]
    if (length(dropped))
        warning("fields not available:\n", .wrapstr(dropped))
    if (length(columns)==0) {
      warning("No records found. Check on filter criteria to ensure they do what you expect. ")
      return(NULL)
    }
    if (!length(unique(lengths(columns)))) {
        lens <- paste(sprintf("%s = %d", names(columns), lengths(columns)),
                      collapse=", ")
        stop("fields are different lengths:\n", .wrapstr(lens))
    }

    as.data.frame(columns, stringsAsFactors=FALSE)
}

