generate_completion <- function(user_prompt, tipe) {
  api_key <- Sys.getenv("KUNCIAPI")
  #    api_endpoint <- "https://aoaiinvestigator.openai.azure.com/openai/deployments/gpt-4o-2/chat/completions?api-version=2024-08-01-preview"
  api_endpoint <- "https://aoaiinvestigator.openai.azure.com/openai/deployments/gpt-4o-3/chat/completions?api-version=2025-01-01-preview"
  if(tipe == 'Regression'){
    sys_prompt <- "Jelaskan Hasil Regression berikut ini beserta kesimpulannya."
  } else if(tipe == 'Clustering'){
    sys_prompt <- "Jelaskan Hasil Clustering berdasarkan cluster yang terbentuk dengan dibuatkan poin tiap cluster dan berikan kesimpulannya serta hilangkan elemen boldnya setiap kalimat agar tidak tampil tanda **."
  } else if(tipe == 'Story'){
    sys_prompt <- "Ringkas cerita berikut ini, dapatkan intinya, termasuk ukuran sentimen dan keakrabannya."
  } else {
    stop("Tipe tidak dikenali.")
  }
  
  
  response <- POST(
    url = api_endpoint,
    add_headers(
      "api-key" = api_key
    ),
    body = list(
      messages = list(
        list(role = "system", content = sys_prompt),
        list(role = "user", content = user_prompt)
      ),
      max_tokens = 1000,
      temperature = 0.7,
      top_p = 1
    ),
    encode = "json"
  )
  print(response)
  response_content <- httr::content(response, as = "parsed", type = "application/json")
  #  response_content <- content(response)
  response_text <- response_content$choices[[1]]$message$content
  
  # Calculate token count
  token_count <- (nchar(sys_prompt) + nchar(user_prompt)) / 4  # Rough estimate of tokens
  
  # return(tibble(
  #   prompt = user_prompt,
  #   response = response_text,
  #   token_count = token_count
  # ))
  return(response_text)
}

ZAndSummationTest <- function(Result) {
  ds <- data.frame()
  for (row in 1:nrow(Result$bfd)){
    ds[row,"digits"] <- Result$bfd[row]$digits
    ds[row,"observed_distribution"] <- Result$bfd[row]$data.dist
    ds[row,"expected_distribution"] <- Result$bfd[row]$benford.dist
    
    ds[row,"observed_frequency"] <- Result$bfd[row]$data.dist.freq
    ds[row,"expected_frequency"] <- Result$bfd[row]$benford.dist.freq
    ds[row,"summation"] <- Result$bfd[row]$data.summation
    ds[row,"excess.summation"] <- Result$bfd[row]$abs.excess.summation
  }
  
  total <- sum(ds$expected_frequency)
  
  for (row in 1:nrow(ds)){
    
    EP <- ds[row, "expected_distribution"] 
    AP <- ds[row, "observed_distribution"]
    Z <- abs(AP-EP)
    fCorrecao <- 1/(2 * total)
    Z <- Z - fCorrecao
    
    if (Z < 0)
      Z <- Z + fCorrecao
    
    
    Z <- Z / sqrt((EP * (1 - EP)) / total)
    Z <- round(Z,4)
    ds[row,"Z"] <- Z
  }
  
  return(ds)
}

myComputeZStatistics <- function(ds) {
  total <- sum(ds$expected_frequency)
  for (row in 1:nrow(ds)){
    
    EP <- ds[row, "expected_distribution"] 
    AP <- ds[row, "observed_distribution"]
    Z <- abs(AP-EP)
    fCorrecao <- 1/(2 * total)
    Z <- Z - fCorrecao
    
    if (Z < 0)
      Z <- Z + fCorrecao
    
    
    Z <- Z / sqrt((EP * (1 - EP)) / total)
    Z <- round(Z,4)
    ds[row,"Z"] <- Z
  }
  
  return(ds)
}


ComputeSummation <- function(ds) {
  total_summation <- sum(ds$summation)
  
  for (row in 1:nrow(ds)){
    summation_test <- ds[row, "summation"] 
    summation_test <- summation_test/total_summation
    ds[row,"summation_test"] <- round(summation_test,4)
  }
  return(ds)
}

gemini_completion <- function(user_prompt,tipe) {
  if(tipe == 'Regression'){
    sys_prompt <- "Jelaskan Hasil Regression berikut ini beserta kesimpulannya."
  } else if(tipe == 'Clustering'){
    sys_prompt <- "Jelaskan Hasil Clustering berdasarkan cluster yang terbentuk dengan dibuatkan poin tiap cluster dan berikan kesimpulannya serta hilangkan elemen boldnya setiap kalimat agar tidak tampil tanda **."
  } else if(tipe == 'Story'){
    sys_prompt <- "Ringkas cerita berikut ini, dapatkan intinya, termasuk ukuran sentimen dan keakrabannya."
  } else {
    stop("Tipe tidak dikenali.")
  }
  gemini.R::setAPI("AIzaSyBzs0SQJtJSwg8pW45Krvl3U9yjxm74njA")
  #print(paste(sys_prompt,'\n', user_prompt))
  hasil <- gemini(paste(sys_prompt,'\n', user_prompt))
  return(hasil)
}
