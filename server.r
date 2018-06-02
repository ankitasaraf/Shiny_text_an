#Server logic

shinyServer(function(input, output) {
  
  Dataset <- reactive({
    
    file1 = input$file1
    if (is.null(file1$datapath)) {   # locate 'file1' from ui.R
      
      return(NULL) } 
    
    else{
       
        require(stringr)
        data1 = readLines(file1$datapath)
        data1  =  str_replace_all(data1, "<.*?>", "") # get rid of html junk 
        
        return(data1)
      }
  })
  
  
  annotate_model <- reactive({
  english_model = udpipe_load_model("./english-ud-2.0-170801.udpipe")  # file_model only needed
  text1<- udpipe_annotate(english_model, Dataset()) #%>% as.data.frame() %>% head()
  text1 <- as.data.frame(text1)
  text1 <- subset(text1, select = -sentence)
  text1 <- subset( text1,upos %in% input$check_upos)
  return(text1)
  })
  
  
 
  
  
  # Render table containing 100 rows
  
  output$table1 = renderDataTable({
                  
                  tab = annotate_model()
                  return(head(tab,100)) #Showing only 100 rows of the annotated doc
                  # head(table_temp, n=100) },
                  # width = "auto",
                  # rownames = FALSE,
                  # colnames = TRUE
                  }
  )
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$file1,"_Data", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(annotate_model(), file, row.names = FALSE, col.names = FALSE)
    }
  )
  
  
  output$plot_noun <- renderPlot({
    
    english_model = udpipe_load_model("./english-ud-2.0-170801.udpipe")
    text1<- udpipe_annotate(english_model, Dataset()) #%>% as.data.frame() %>% head()
    text1 <- as.data.frame(text1)
    text1 <- subset(text1, select = -sentence)
    
  table(text1$xpos)  # std penn treebank based POStags
  table(text1$upos)  # UD based postags
  
  
  all_nouns = text1 %>% subset(., upos %in% "NOUN"); 
  all_nouns$token[1:20]
  
  top_nouns = txt_freq(all_nouns$lemma)
  head(top_nouns$key, 20) 
  
  
  
  wc_noun = wordcloud(words = top_nouns$key, 
                    freq = top_nouns$freq, 
                    min.freq = input$wc_freq, 
                    max.words = 100,
                    random.order = FALSE, 
                    colors = brewer.pal(6, "Dark2"))
  
  }
  )
  
  
  output$plot_verb <- renderPlot({
    
    english_model = udpipe_load_model("./english-ud-2.0-170801.udpipe")
    text1<- udpipe_annotate(english_model, Dataset()) #%>% as.data.frame() %>% head()
    text1 <- as.data.frame(text1)
    text1 <- subset(text1, select = -sentence)
    
    table(text1$xpos)  # std penn treebank based POStags
    table(text1$upos)  # UD based postags
    
  
  all_verbs = text1 %>% subset(., upos %in% "VERB") 
  top_verbs = txt_freq(all_verbs$lemma)
  head(top_verbs$key, 20)
  
  wc_verb = wordcloud(words = top_verbs$key, 
                      freq = top_verbs$freq, 
                      min.freq = input$wc_freq, 
                      max.words = 100,
                      random.order = FALSE, 
                      colors = brewer.pal(6, "Dark2"))
  
  #wc_noun_rep <- repeatable(wc_noun)
  
  })
      

  ### Collocations and Cooccurrences
  
 
  # Collocation (words following one another)
  
  
  output$plot_cooc <- renderPlot(
    {
      english_model = udpipe_load_model("./english-ud-2.0-170801.udpipe")
      text1<- udpipe_annotate(english_model, Dataset()) #%>% as.data.frame() %>% head()
      text1 <- as.data.frame(text1)
      text1 <- subset(text1, select = -sentence)
      text_cooc <- udpipe::cooccurrence(x = subset( text1,upos %in% input$check_upos), term = "lemma",
                                                    group = c("doc_id", "paragraph_id", "sentence_id"))
      
      wordnetwork <- head(text_cooc, input$cooc_freq)
      wordnetwork <- igraph::graph_from_data_frame(wordnetwork) # needs edgelist in first 2 colms.
      
      ggraph(wordnetwork, layout = "fr") +  
          
          geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
          geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
          
          theme_graph(base_family = "Arial Narrow") +  
          theme(legend.position = "none") +
          
          labs(title = "Cooccurrences within 3 words distance")
      
    }
  )
  
})
