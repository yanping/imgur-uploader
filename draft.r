#' Upload a image to imgur.com
#'
#' This function uses the \pkg{RCurl} package to upload a image to
#' \url{imgur.com}, and parses the XML response to a list with \pkg{XML} which
#' contains information about the image in the Imgur website.
#'
#' When the output format from \code{\link{knit}()} is HTML or Markdown, this
#' function can be used to upload local image files to Imgur, e.g. set the
#' package option \code{opts_knit$get(upload.fun = imgur_upload)}, so the output
#' document is completely self-contained, i.e. it does not need external image
#' files any more, and it is ready to be published online.
#' @param file the path to the image file to be uploaded
#' @param key the API key for Imgur (by default uses a key created by Yihui Xie,
#' which allows 50 uploads per hour per IP address)
#' @return A character string of the link to the image; this string carries an
#' attribute named \code{XML} which is a list converted from the response XML
#' file; see Imgur API in the references.
#' @author Yihui Xie, adapted from the \pkg{imguR} package by Aaron Statham
#' @note Please register your own Imgur application to get your API key; you can
#' certainly use mine, but this key is in the public domain so everyone has
#' access to all images associated to it.
#' @references Imgur API: \url{http://api.imgur.com/}; a demo:
#' \url{http://yihui.name/knitr/demo/upload/}
#' @export
#' @examples f = tempfile(fileext = '.png')
#' png(f); plot(rnorm(100), main = R.version.string); dev.off()
#' \dontrun{
#' res = imgur_upload(f)
#' res # link to original URL of the image
#' attr(res, 'XML') # all information
#' if (interactive()) browseURL(res$links$imgur_page) # imgur page
#'
#' ## to use your own key
#' opts_knit$set(upload.fun = function(file) imgur_upload(file, key = 'your imgur key'))
#' }
imgur_upload = function(file, key = '60e9e47cff8483c6dc289a1cd674b40f') {
  if (is.null(key) || nchar(key) != 32L)
    stop('The Imgur API Key must be a character string of length 32!')
  if (!file.exists(file)) stop(file, 'does not exist!')
  params = list(key = key, image = RCurl::fileUpload(file))
  res = XML::xmlToList(RCurl::postForm("http://api.imgur.com/2/upload.xml", .params = params))
  if (is.null(res$links$original)) stop('failed to upload ', file)
  structure(res$links$original, XML = res)
}


choose.files(default = "", caption = "Select files",
             multi = TRUE, filters = Filters,
             index = nrow(Filters))
			 
imgur_upload(choose.files())
uri <- attr(pic,"XML")$links$original
imageHtml <- paste("<img src=\"",uri,"\" alt=\"",alt.string,"\" />",sep="")
writeLines(imageHtml, 'clipboard')



# > attr(pic,"XML")$links
# $original
# [1] "http://i.imgur.com/L0kCa.jpg"

# $imgur_page
# [1] "http://imgur.com/L0kCa"

# $delete_page
# [1] "http://imgur.com/delete/mjG8wBcSzG9N8mF"

# $small_square
# [1] "http://i.imgur.com/L0kCas.jpg"

# $large_thumbnail
# [1] "http://i.imgur.com/L0kCal.jpg"

# 例子请看 http://bioinf.wehi.edu.au/~wettenhall/RTclTkExamples/
require(tcltk)
tt <- tktoplevel()
tkwm.title(tt,"imgur uploader")
select.file <- function(){
	fileName<-tclvalue(tkgetOpenFile())
	Name <- tclVar(fileName)
	entlbl <- tklabel(tt,text="文件名称")
	entry.Name <-tkentry(tt,width="20",textvariable=Name)
	tkgrid(entlbl,entry.Name)
}

imgur_upload = function() {
	key = '60e9e47cff8483c6dc289a1cd674b40f'
	fileName<-tclvalue(tkgetOpenFile())
	Name <- tclVar(fileName)
	if (is.null(fileName)) stop('请先选择文件')
	params = list(key = key, image = RCurl::fileUpload(fileName))
	res = XML::xmlToList(RCurl::postForm("http://api.imgur.com/2/upload.xml", .params = params))
	if (is.null(res$links$original)) stop('failed to upload ', fileName)
	fileInfo <- structure(res$links$original, XML = res)
	uri <- attr(fileInfo,"XML")$links$original
	imageHtml <- tclVar(paste("<img src=\"",uri,"\" />",sep=""))
	entlb2 <- tklabel(tt,text="图片HTML")
	entry.imgHtml <-tkentry(tt,width="120",textvariable = imageHtml)
	tkgrid(entlb2,entry.imgHtml)
}

# btn1 <- tkbutton(tt,text="选择文件",command = select.file)
btn2 <- tkbutton(tt,text="关闭",command=function()tkdestroy(tt))
btn3 <- tkbutton(tt,text="上传",command= imgur_upload )
tkgrid(btn2,btn3)



