library("shiny")

shinyUI(
  fluidPage(
    
    titlePanel("UDPipe NLP"),  # name the shiny app
    
    sidebarLayout(    # creates a sidebar layout to be filled in
      
      sidebarPanel(   # creates a panel struc in the sidebar layout
        
        # user reads input file into input box here:
        fileInput("file1", 
                  "Upload data (text file)"),
        
        # user selects list of Universal Parts-of-speech tags:
        checkboxGroupInput(inputId ="check_upos", 
                           label = "Parts of speech:",
                           choices =c("Adjective" = "ADJ","Noun"= "NOUN","Proper Noun" = "PROPN","Adverb"="ADV", "Verb"="VERB"),
                           selected = c("ADJ","NOUN","PROPN")),
                           
                           
    sliderInput("wc_freq","Minimum frequency in wordcloud:",min = 0, max = 50, value = 3),
    sliderInput("cooc_freq","Minimum frequency in Co-occurence Graph:", min = 0, max = 50, value = 30)
        
      ),   # end of sidebar panel
      
      ## Main Panel area begins.
      mainPanel(
        
        tabsetPanel(type = "tabs",   # builds tab struc
                    
                    tabPanel("Overview",   # leftmost tab
                             
                             h4(p("Data input")),
                             
                             p("This app supports only text data file (.txt) .", align="justify"),
                             
                             p("Please refer to the link below for Sample text file."),
                             a(href="https://github.com/ankitasaraf/Text-Analytics/blob/master/UDPipe/Shawshank%20Redemption.txt"
                               ,"Sample Input text file"),
                             
                             p("Please refer the link below for English language model."),
                             a(href="https://github.com/ankitasaraf/Text-Analytics/blob/master/UDPipe/english-ud-2.0-170801.udpipe"
                               ,"English language model"),   
                             
                             br(),
                             
                             h4('How to use this App'),
                             
                             p('To use this app, click on', 
                               span(strong("Browse under Upload data (text file)")),
                               'and upload the text data file. You can then select the Parts-of-speech tags based on your requirements. You can also select the minimum frequency of words for the Wordclouds and minimum frequency in co-occurence graphs by using the slider.')),
                    
                    # second tab coming up:
                    tabPanel("Annotated document", 
                             downloadButton("downloadData", "Download the complete dataframe here"),
                             
                             br(),
                             
                              dataTableOutput("table1")
                             
                             
                             ),         
                    
                    # third tab coming up:
                    tabPanel("Wordclouds",
                             h4("Wordcloud for Nouns:"),
                             plotOutput("plot_noun"),
                             h4("Wordcloud for Verbs:"),
                             plotOutput("plot_verb")),
                             
                             # obj 'clust_summary' from server.R
                             #tableOutput('clust_summary')),
                    
                    # fourth tab coming up:
                    tabPanel("Co-occurences",plotOutput("plot_cooc"))
                            
        ) # end of tabsetPanel
      )# end of main panel
    ) # end of sidebarLayout
  )  # end if fluidPage
) # end of UI
