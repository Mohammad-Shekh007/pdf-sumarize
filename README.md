title: "Shiny App for PDF Summarization and Chatbot Interaction"
author: "Mohammad Wasim Shekh"
output: github_document
---

## Overview

This Shiny app allows users to upload multiple PDF files, display the first few lines of their content, and provide a summary with a click of a button. In addition, it has an integrated chatbot that uses OpenAI's GPT models to answer content-related questions and summarize the files. The app is built using R and leverages libraries such as `shiny`, `httr`, `pdftools`, and `tesseract`.

## Features

- **Upload Multiple PDFs**: Users can upload multiple PDF files through a "Browse" button.
- **View File Content**: Once the files are uploaded, the app displays the first few lines of each PDF to give an initial preview.
- **Summarize Files**: Clicking the "Summarize" button provides a short summary of the file contents using OpenAI's API.
- **Chatbot Interaction**: A chatbot allows you to ask specific questions about the content of the files, and it responds using the same summarization and knowledge provided by OpenAI's models.

## Libraries Used

The following R packages are used in this app:

- **`shiny`**: For building the interactive web application.
- **`httr`**: For making HTTP requests to the OpenAI API.
- **`pdftools`**: For extracting text from the PDF files.
- **`tesseract`**: For extracting text from images within the PDFs if required.

## Prerequisites

To run the app locally, you'll need to install the required libraries and set up an OpenAI API key.

### Install Dependencies

```r
install.packages(c("shiny", "httr", "pdftools", "tesseract"))
Set Up OpenAI API Key
To use the chatbot functionality and get summaries of your PDF files, you'll need an OpenAI API key. You can obtain one by creating an account on the OpenAI platform.

Once you have your API key, simply copy and paste it into the section of the code where it says paste your api key here. There is no need to set it as an environment variable manually.

For example, in the app’s code, find the following line:

r
Copy
Edit
api_key <- ""
Type your actual OpenAI API key in between the quotations "".

How to Run the App
Clone this repository or download the R Markdown file.
Open the file in RStudio.
Run the app by calling the following in your R console:
r
Copy
Edit
shiny::runApp("path_to_the_app_directory")
Usage
Uploading PDF Files
Click on the "Browse" button to select and upload multiple PDF files from your computer. The app will display the first few lines of each PDF so you can get a quick preview.

Summarize PDFs
Once the files are uploaded, click on the "Summarize" button to get a brief summary of the file contents. The app uses OpenAI's GPT models to provide this summary.

Ask the Chatbot
You can interact with the chatbot by typing your questions about the content of the uploaded files in the text box provided. The chatbot will respond based on the file contents and the summary generated earlier.

Important Notes
OpenAI API Usage: The chatbot uses the OpenAI API to generate responses. By interacting with the chatbot, you are submitting data to OpenAI’s servers. Please be mindful of any sensitive or private information you share through the chatbot.
Sensitive Data: The app works by sending data to OpenAI for summarization and answering questions. Be cautious not to upload or share sensitive, confidential, or personal information in the PDFs you upload, as this data may be processed by OpenAI's servers, which are public.
Contributions
Feel free to contribute to this project by opening an issue or submitting a pull request. Suggestions and improvements are welcome!
