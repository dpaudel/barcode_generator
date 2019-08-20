shinyServer(function(input, output, session){
  output$contents <- renderTable({
    req(input$file1)
    df <- read.csv(input$file1$datapath,
                   header = input$header,
                   sep = input$sep,
                   quote = input$quote)
    
    if(input$disp == "head") {
      return(head(df))
    }
    else {
      return(dim(df))
    }
  })

  output$downloader <- downloadHandler("results_from_shiny.pdf",
                                       content = 
                                         function(file1)
                                         {
                                           user = "FALSE"
                                           Labels = file1
                                           name = "LabelsOut"
                                           type = "linear"
                                           ErrCorr = "H"
                                           Fsz = 10
                                           Across = TRUE
                                           ERows = 0
                                           ECols = 0
                                           trunc = TRUE
                                           numrow = 1
                                           numcol = 1
                                           page_width = 3
                                           page_height = 2
                                           width_margin = 0.25
                                           height_margin = 0.5
                                           label_width = NA
                                           label_height = NA
                                           x_space = 0
                                           y_space = 0.5
                                           #Labels<-read.csv(file.choose("Select .csv file that contains labels"), header = TRUE, stringsAsFactors = F)
                                           # Make readable directly with excel file
                                           Labels <-     df <- read.csv(input$file1$datapath,
                                                                        header = input$header,
                                                                        sep = input$sep,
                                                                        quote = input$quote)
                                           Labels <- Labels[, 1]
                                           if (any(unlist(lapply(c(numcol, numrow, Fsz, ERows, ECols, trunc, page_width, page_height, height_margin, width_margin, x_space, y_space), class)) != "numeric") == TRUE) {
                                             stop("One or more numerical parameters are not numeric")
                                           }
                                           labelLength <- max(nchar(paste(Labels)))
                                           # clean up any open graphical devices if function fails
                                           #on.exit(grDevices::dev.off())
                                           width_margin <- page_width - width_margin * 2
                                           height_margin <- page_height - height_margin * 2
                                           if(is.na(label_width)){label_width <- width_margin/numcol}
                                           if(is.na(label_height)){label_height <- height_margin/numrow}
                                           if(type == "linear" & label_width / labelLength < 0.03) warning("Linear barcodes created will have bar width smaller than 0.03 inches which may be unreadable by some barcode scanners.")
                                           if(!is.numeric(c(label_width, label_height))) stop("label_width and label_height should be set to NULL or a numeric value.")
                                           # if (cust_spacing == T) {
                                           #   y_space <- x_space - (as.integer(x_space * 0.5)) - 15
                                           # } else {
                                           #   y_space <- 182
                                           # }
                                           column_space <- (width_margin - label_width * numcol)/(numcol - 1)
                                           row_space <- (height_margin - label_height * numrow)/(numrow - 1)
                                           # Viewport Setup
                                           ## grid for page, the layout is set up so last row and column do not include the spacers for the other columns
                                           barcode_layout <- grid::grid.layout(numrow, numcol, widths = grid::unit(c(rep(label_width + column_space, numcol-1), label_width), "in"), heights = grid::unit(c(rep(label_height + row_space, numrow-1), label_height), "in"))
                                           ## change viewport and barcode generator depending on qr or 1d barcodes
                                           if(type == "linear"){
                                             code_vp <- grid::viewport(x=grid::unit(0.05, "npc"), y=grid::unit(0.8, "npc"), width = grid::unit(0.9 *label_width, "in"), height = grid::unit(0.8 * label_height, "in"), just=c("left", "top"))
                                             text_height <- ifelse(Fsz / 72 > label_height * 0.3, label_height * 0.3, Fsz/72)
                                             label_vp <- grid::viewport(x=grid::unit(0.5, "npc"), y = grid::unit(1, "npc"), width = grid::unit(1, "npc"), height = grid::unit(text_height, "in"), just = c("centre", "top"))
                                             Fsz <- ifelse(Fsz / 72 > label_height * 0.3, label_height * 72 * 0.3 , Fsz)
                                             label_plots <- sapply(as.character(Labels), baRcodeR::code_128_make , USE.NAMES = T, simplify = F)
                                           } 
                                           
                                           # File Creation
                                           x_pos <- ERows + 1
                                           y_pos <- ECols + 1
                                           oname <- paste0(name, ".pdf")
                                           grDevices::pdf(oname, width = page_width, height = page_height, onefile = TRUE, family = "Courier") # Standard North American 8.5 x 11
                                           bc_vp = grid::viewport(layout = barcode_layout)
                                           grid::pushViewport(bc_vp)
                                           
                                           for (i in 1:length(label_plots)){
                                             # Split label to count characters
                                             Xsplt <- names(label_plots[i])
                                             if(trunc == TRUE){  # Truncate string across lines if trunc==T
                                               # if(nchar(Xsplt) > 27){Xsplt <- Xsplt[1:27]}
                                               # If remaining string is > 8 characters, split into separate lines
                                               if(nchar(Xsplt) > 15){
                                                 Xsplt <- paste0(substring(Xsplt, seq(1, nchar(Xsplt), 15), seq(15, nchar(Xsplt)+15-1, 15)), collapse = "\n")
                                               }
                                             }
                                             # print(c("in", x_pos, y_pos))
                                             # reset if any of the values are greater than page limits
                                             if (x_pos > numcol | y_pos > numrow){
                                               grid::grid.newpage()
                                               grid::pushViewport(grid::viewport(width = grid::unit(page_width, "in"), height = grid::unit(page_height, "in")))
                                               # barcode_layout=grid.layout(numrow, numcol, widths = widths, heights = heights)
                                               grid::pushViewport(bc_vp)
                                               x_pos = 1
                                               y_pos = 1
                                             }
                                             # print(c(x_pos, y_pos))
                                             # print the label onto the viewport
                                             grid::pushViewport(grid::viewport(layout.pos.row=y_pos, layout.pos.col=x_pos))
                                             # grid::grid.rect()
                                             grid::pushViewport(code_vp)
                                             grid::grid.draw(label_plots[[i]])
                                             grid::popViewport()
                                             grid::pushViewport(label_vp)
                                             if(type =="linear"){
                                               grid::grid.rect(gp = grid::gpar(col = NA, fill = "white"))
                                             }
                                             grid::grid.text(label = Xsplt, gp = grid::gpar(fontsize = Fsz, lineheight = 0.8))
                                             grid::popViewport(2)
                                             if (Across == "T" | Across == TRUE){
                                               x_pos <- x_pos + 1
                                               if (x_pos > numcol) {
                                                 x_pos <- 1
                                                 y_pos <- y_pos + 1
                                               }
                                               
                                             } else {
                                               y_pos <- y_pos + 1
                                               if (y_pos > numrow) {
                                                 y_pos <- 1
                                                 x_pos <- x_pos + 1
                                               }
                                             }
                                             # print(c("out", x_pos, y_pos))
                                           }
                                           grDevices::dev.off()
                                         })
    
  output$working_directory <- renderTable({
    req(input$file1)
    curr_dir <- getwd()
    titlebar <- renderPrint({print("Barcode file LabelsOut.pdf will be available at:")})
    visFun <- renderPrint({print("Barcode file LabelsOut.pdf will be available at:"); getwd() })
    titlebar()
    visFun()
  })
  
  
  
shinyServer(function(input, output, session){
  session$onSessionEnded(function() {
    stopApp()
  })
})

})
  
