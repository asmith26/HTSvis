#### Function to define specific drop down lists on 'data input' tab via renderUI 
DropDownInput <- function(identifier,input,label,multiState,sel){

    renderUI({
      if(is.null(input)) return()
      
      if(!isTRUE(multiState) )    
        selectizeInput(identifier,
                      label = label,
                      choices = input,
                      multiple = T,
                      options = list(maxItems=1, placeholder = 'not defined'),
                      selected=sel)
        else 
          selectizeInput(identifier,
                         label = label,
                         choices = input,
                         multiple = T,
                         options = list(placeholder = 'not defined'),
                         selected=sel)
    })
}
