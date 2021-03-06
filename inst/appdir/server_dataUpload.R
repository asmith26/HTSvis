################################
## Server part for data input ##
################################

# loaded table is committed to a reactive values object 'feature_table2'
# data input is evaluated using the 'try' function' 
# upon uploading of an input table, the app entire app is reset by changing the 
#   value of several reacitve values objects 

feature_table2 <- reactiveValues()


testInput <- function(toEval) {
    try(toEval,silent=T)
}

observe({
    inFile <- input$file1
    if (is.null(inFile))
        return(NULL)
    if(file_ext(inFile$name) == "RData" |
       file_ext(inFile$name) == "Rdata") {
        feature_table2$data_pre <- testInput(
            data.frame(get(load(inFile$datapath)))
        )
        if(!is.data.frame(feature_table2$data_pre)){
            feature_table2$data_pre <- NULL
        } else {
            return(feature_table2) 
        }
    } else {
        if(file_ext(inFile$name) == "txt" | file_ext(inFile$name) == "tsv"){
            feature_table2$data_pre <-  testInput(
                read.table(inFile$datapath,header=T)
            )
        } else if(file_ext(inFile$name) == "csv") {
            feature_table2$data_pre <-  testInput(
                data.frame(
                    fread(
                        inFile$datapath,
                        na.strings = c("NA","N/A",
                                       "NaN","null","")
                    )
                    ,row.names = NULL)
            )
        } else if(file_ext(inFile$name) == "xlsx" || file_ext(inFile$name) == "xls") {
            file.copy(inFile$datapath,paste(inFile$datapath, ".",file_ext(inFile$name), sep=""))
            feature_table2$data_pre <-  testInput(
                data.frame(
                    readxl::read_excel(
                        paste(inFile$datapath, ".",file_ext(inFile$name), sep=""),
                        na = c("NA","N/A",
                               "NaN","null","")
                    )
                    ,row.names = NULL)
            )
        } else {
            feature_table2$data_pre <- NULL
        }
    }
})


InputStartTables <- reactiveValues()
observeEvent(input$file1,{
    InputStartTables$plate <- NULL
    InputStartTables$well <- NULL
    InputStartTables$experiment <- NULL
    InputStartTables$anno <- NULL
    
    showApp$panels = F
    showApp$dummy = T
    
    getParams$well_input <- NULL
    getParams$plate_input <- NULL
    getParams$experiment_input <- NULL
    getParams$anno_input <- NULL
    getParams$cellHTS_state <- NULL
    getParams$singleExperiment_state <- NULL
    
    params_df <- data.frame(
        c("well_input","plate_input","experiment_input","anno_input","measuredValues_input",
          "cellHTS_state","singleExperiment_state"),
        c(rep(NA,7))
    )
    colnames(params_df) <- NULL
    params$data = params_df
    
})


output$dataInfo <- renderUI({
    validate(need(input$file1, message=FALSE))
    if(is.null(feature_table2$data_pre)){
        h3("Incorrect data format (.RData data frames, .txt, .csv and .xlsx files are supported)")
    } else {
        if(inherits(feature_table2$data_pre,"try-error",which=F)){
            h3("Data input failed due to an unkown reason")
        } else {
            test_cols <- feature_table2$data_pre
            if(any(duplicated(colnames(test_cols)))) {
                h6("Duplicated colnames are not allowed")
            } else {
                HTML(paste0("The uploaded data table has <b>",
                            ncol(feature_table2$data_pre),
                            " columns</b> and <b>",
                            nrow(feature_table2$data_pre),
                            " rows</b>",
                            "<br/> Select columns with the annotation
                            and measured values from the drop down lists.")
                )
            }
            }
        }
    })


