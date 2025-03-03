library(shiny)
library(pdftools)
library(httr)
library(tesseract)

# OpenAI API Key (Directly defined in the script)
api_key <- ""
options(shiny.maxRequestSize = 100*1024^2)  # Set max file upload size to 100MB

ui <- fluidPage(
  titlePanel("PDF Chatbot with OpenAI"),
  sidebarLayout(
    sidebarPanel(
      fileInput("pdf_files", "Upload PDF Files", accept = ".pdf", multiple = TRUE),
      actionButton("summarize", "Summarize"),
      textInput("user_question", "Ask a question about the PDF", ""),
      actionButton("ask_question", "Ask Question")
    ),
    mainPanel(
      h4("Preview of First Few Lines"),
      uiOutput("preview"),
      h4("Summaries"),
      uiOutput("summaries"),
      h4("Chatbot Response"),
      verbatimTextOutput("chat_response")
    )
  )
)

server <- function(input, output) {
  
  extract_text <- function(pdf_path) {
    text <- tryCatch({
      pdf_text(pdf_path)
    }, error = function(e) {
      tryCatch({
        message("Trying OCR for scanned PDF: ", pdf_path)
        ocr_text <- ocr(pdf_path)
        return(ocr_text)
      }, error = function(e2) {
        return(NA)
      })
    })
    return(text)
  }
  
  text_reactive <- reactive({
    req(input$pdf_files)
    texts <- lapply(seq_along(input$pdf_files$datapath), function(i) {
      list(name = input$pdf_files$name[i], text = extract_text(input$pdf_files$datapath[i]))
    })
    texts
  })
  
  output$preview <- renderUI({
    req(input$pdf_files)
    previews <- lapply(text_reactive(), function(file) {
      tagList(
        h5(strong(file$name)),
        verbatimTextOutput(paste0("preview_", file$name))
      )
    })
    do.call(tagList, previews)
  })
  
  observe({
    lapply(text_reactive(), function(file) {
      local({
        file_name <- file$name
        output[[paste0("preview_", file_name)]] <- renderText({
          paste(head(unlist(strsplit(paste(file$text, collapse = "\n"), "\n")), 10), collapse = "\n")
        })
      })
    })
  })
  
  observeEvent(input$summarize, {
    req(input$pdf_files)
    summaries <- lapply(text_reactive(), function(file) {
      text_processed <- substr(paste(file$text, collapse = "\n"), 1, 30000)  # Limit text size
      prompt <- "Summarize the following text:"
      
      response <- POST(
        url = "https://api.openai.com/v1/chat/completions",
        add_headers(.headers = c(Authorization = paste("Bearer", api_key))),
        content_type_json(),
        encode = "json",
        body = list(
          model = "gpt-3.5-turbo",
          messages = list(
            list(role = "system", content = "You are a helpful assistant."),
            list(role = "user", content = paste(prompt, text_processed))
          )
        )
      )
      
      content <- content(response, "parsed")
      summary_text <- content$choices[[1]]$message$content
      
      list(name = file$name, summary = summary_text)
    })
    
    output$summaries <- renderUI({
      summary_outputs <- lapply(summaries, function(summary) {
        tagList(
          h5(strong(summary$name)),
          verbatimTextOutput(paste0("summary_", summary$name))
        )
      })
      do.call(tagList, summary_outputs)
    })
    
    lapply(summaries, function(summary) {
      local({
        file_name <- summary$name
        output[[paste0("summary_", file_name)]] <- renderText({
          paste(strwrap(summary$summary, width = 80), collapse = "\n\n")
        })
      })
    })
  })
  
  observeEvent(input$ask_question, {
    req(input$pdf_files, input$user_question)
    question <- input$user_question
    texts <- text_reactive()
    
    # Extract text from the PDFs and prepare it for the API
    text_processed <- substr(paste(sapply(texts, function(file) file$text), collapse = "\n"), 1, 30000)  # Limit text size
    
    prompt <- paste("Answer the following question based on the PDF text:\n", question)
    
    response <- POST(
      url = "https://api.openai.com/v1/chat/completions",
      add_headers(.headers = c(Authorization = paste("Bearer", api_key))),
      content_type_json(),
      encode = "json",
      body = list(
        model = "gpt-3.5-turbo",
        messages = list(
          list(role = "system", content = "You are a helpful assistant."),
          list(role = "user", content = paste(prompt, text_processed))
        )
      )
    )
    
    content <- content(response, "parsed")
    chat_response <- content$choices[[1]]$message$content
    
    output$chat_response <- renderText({
      paste(strwrap(chat_response, width = 80), collapse = "\n\n")
    })
  })
}

shinyApp(ui, server)
