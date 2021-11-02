# PP3 - Team024 - application Rscript final

# automated load/install packages: 
packageList = c("DBI","DT","dplyr","devtools","plyr","Rcpp","RPostgres","shiny","shinyjs","shinydashboard","shinyWidgets","stringr")
newPackages = packageList[!(packageList %in% installed.packages()[,"Package"])]
if(length(newPackages)) install.packages(newPackages)
lapply(packageList, require, character.only = TRUE, quietly = TRUE)

options(stringsAsFactors = FALSE) #other settings

# github sourced packages (installed from CRAN instead) 
# devtools::install_github("RcppCore/Rcpp")
# devtools::install_github("rstats-db/DBI")
# devtools::install_github("rstats-db/RPostgres")


# --------------------------------------------------------------------------------------- 
getwd()
setwd('C:/Users/norri/Desktop')

# I. connect to the db
dr <<- RPostgres::Postgres()
cn <<- dbConnect(dr,
                 host = "ingeshelter.cqnrn3vp9iji.us-east-1.rds.amazonaws.com",
                 port = "5432",
                 user = "postgres",
                 password = "newbaby123",
                 dbname = "ingeshelter")
# test <- dbGetQuery(cn, paste0("SELECT * FROM breeds"))
# test2 = dbListTables(cn)


# II. load any intial data
## species options
speciesOptions = function(){
  colList = as.data.frame(colnames(dbGetQuery(cn, paste0("SELECT * FROM breeds"))))
  breedlist = str_replace(colList[,1], "_breeds","")
  return(breedlist)
}
so <<- speciesOptions()

## species limit 
speciesLimit = function(){
  # speciesLimit = data.frame(species=c("cat","dog"), capacity=c(30,15))
  speciesLimit = data.frame(species=c("Cat","Dog"), capacity=c(50,50))
  return(speciesLimit)
}
sl <<- speciesLimit()

## breed options
breedOptions = function(){
  breeds = dbGetQuery(cn, paste0("SELECT * FROM breeds"))
  return(dbGetQuery(cn, "SELECT * FROM breeds"))
  c("unknown", "mixed")
}
bo <<- breedOptions() # species, breed # for add animal 
bo2 <<- breedOptions() # for edit animal

## vaccine options
vaccineOptions = function(){
  vaccs = dbGetQuery(cn, "SELECT * FROM vaccine_types")
  vaccsList = vaccs[,1:2]
  vaccOpt = apply(vaccsList[,1:2], 1, paste, collapse = '-')
  return(list("vaccOptions" = vaccOpt, "fullVacc" = vaccs))
}
vo <<- vaccineOptions() # get a setDiff of this and an animal's list of vaccines given the same species col val & required_adopt col
# vo$fullVacc

# Note: global variables = empUn; empStatCode; petIdNum; appNum

# --------------------------------------------------------------------------------------------------------------------------------------------
# UI
# --------------------------------------------------------------------------------------------------------------------------------------------
ui <- dashboardPage(
  dashboardHeader(title = "Inge's Animal Haven"),
  
  # sidebar menu
  # dashboardSidebar(collapsed = TRUE, disable = TRUE, sidebarMenu(id = "tabs", 
  dashboardSidebar(collapsed = TRUE, disable = TRUE, sidebarMenu(id = "tabs",                                                                
                                                                 h4("Welcome!"),
                                                                 menuItem("Go To Login", tabName = "loginTab", icon = icon("dashboard")),
                                                                 menuItem("Settings", tabName = "settings",
                                                                          menuSubItem("Animal Dashboard", tabName = "dashTab"), 
                                                                          menuSubItem("Add Animal", tabName = "addAnimal"), 
                                                                          menuSubItem("Animal Detail", tabName = "displayUpdateAnimal"), 
                                                                          menuSubItem("Add Adopt App", tabName = "addAdoptApp"), 
                                                                          menuSubItem("Review Adopt App", tabName = "reviewAdoptApp"), 
                                                                          menuSubItem("Add Adoption", tabName = "addAdoption"),
                                                                          menuSubItem("Reports", tabName = "runReports"))
  )),
  
  # dashboard body for collecting input and of output 
  dashboardBody(tabItems(
    
    # 1. tab to login (all)
    tabItem(tabName = "loginTab",
            h2("Please Enter Login Details:"),
            textInput("username", "Enter Username: ", value = ""),
            textInput("password", "Enter Password: ", value = ""),
            actionButton('enterLogin', "Enter"), actionButton('cancelLogin', "Cancel")
    ),
    
    
    # 2. tab to show the animal dashboard (all)
    tabItem(tabName = "dashTab",
            h2("Welcome: Animal Dashboard"),
            tags$hr(style="border-color: black;"),
            DT::DTOutput('currentDashView'),    # , width = "80%"),  #render table output
            tags$hr(style="border-color: black;"),
            numericInput("animalIdNo", "Pet ID: ", ""),
            actionButton('animalIdChosen', "View Animal"), 
            tags$hr(style="border-color: black;"),
            h4("Employee Options: "), 
            actionButton('jumpToAddAnimal', "Add Animal"), 
            actionButton('jumpToAddApp', "Add Adoption Application"), # jump to add animal or adoption app
            h4("Owner Options: "), 
            actionButton('jumpToReviewApps', "Review Adoption Applications"), 
            actionButton('jumpToReports', "Run Reports"), # jump to review apps or reports
            tags$br(),
            
            h4("Current Capacity:"),
            DT::DTOutput('animalCap', width = "70%")  #render table output
    ),
    
    
    # 3. tab for adding a new animal (employee only)
    tabItem(tabName = "addAnimal",
            h2("Add Animal"),
            tags$hr(style="border-color: black;"),
            textInput("animalName", "Animal Name: ", ""), 
            numericInput("animalAge", "Animal Age: ", "Enter approx. months old"),
            radioButtons("sex", "Sex: ", choices = c("male","female","unknown")), 
            radioButtons("altStatus", "Alteration Status: ", choices = c("neutered","spayed","unknown")),
            selectizeInput("breed", "Breed: ", choices=bo, multiple=TRUE, options=list('plugins' = list('remove_button'),'create' = TRUE,'persist' = FALSE)),
            selectizeInput("species", "Species: ", choices=so, multiple=TRUE, options=list('plugins' = list('remove_button'),'create' = TRUE,'persist' = FALSE)),
            textInput("description", "Animal Description: ", "Enter short description..."), 
            dateInput("dateOfSurrender", "Date of Surrender: "), 
            radioButtons("surrControl", "Animal Control Surrender?: ", choices = c("Yes","No")),
            textInput("surrReason", "Surrender Reason: ", "Enter short description..."),
            textInput("microchipId", "Microchip ID: ", "Optional"),
            actionButton("submitAddAnimal", "Submit"), actionButton("cancelAddAnimal", "Delete"), #submit button
            actionButton("dashFromAddAnimal", "Back To Dashboard") # jump to animal dash
    ),
    
    # 4. tab for viewing an animal, changing details, adding vaccines, adding a new adoption; (all)
    tabItem(tabName = "displayUpdateAnimal",
            ## a: display animal details:
            h2("Animal Details"),
            actionButton('jumpToAddAdopt', "Add Adoption"),
            actionButton('dashFromAddAdopt', "Back To Dashboard"), 
            tags$br(),
            DT::DTOutput('currentAnimalDetail', width = "80%"), #show current animal detail screen
            tags$hr(style="border-color: black;"),
            
            ## b: edit animal details:
            h2("Edit Animal Details:"), # edit all attr ?
            radioButtons("sex1", "Sex: ", choices = c("male","female")),  # sex: only if unknown
            actionButton('addSex1', "Enter"), 
            radioButtons("altStatus1", "Alteration Status: ", choices = c("neutered","spayed")),    # alt status: if unaltered; 0 vs 1 data entry in sql insert
            actionButton('addAltStatus1', "Enter"),
            selectizeInput("breed1", "Breed: ", choices=bo2, multiple=TRUE, options=list('plugins' = list('remove_button'),'create' = TRUE,'persist' = FALSE)), # breed: if unknown/mixed
            actionButton('addBreed1', "Enter"),
            textInput("microchipId1", "Microchip ID: ", "Optional"), # microchip
            actionButton('addMicrochipId1', "Enter"),
            actionButton("cancelDetail", "Cancel"), #submit button
            tags$hr(style="border-color: black;"),
            tags$br(),
            h2("Animal's Vaccines:"),
            DT::DTOutput('currentAnimalVacc', width = "85%"),  #show current animal vaccines
            tags$hr(style="border-color: black;"),
            
            ## c: add vaccine:
            h2("Add Vaccine:"),
            dateInput("dateAdmin", "Date Administered: "),
            dateInput("dateExp", "Date of Expiration: "),
            selectInput("vaccineType", "Vaccine Name: ", choices=vo$vaccOptions, multiple=FALSE), # split value selected by '-' to do query 
            numericInput("vaccineNum", "Vaccine #: ", "Optional: vacc/tag #"),
            actionButton("addVacc", "Add"), actionButton("cancelVacc", "Cancel") #submit button
    ),
    
    # 5. tab to add a new adoption application (all)
    tabItem(tabName = "addAdoptApp",
            h2("Add New Adoption Application"),
            textInput("fName", "Applicant First Name: ", ""), textInput("lName", "Applicant Last Name: ", ""),
            textInput("cfName", "CoApp. First Name: ", "Optional"), textInput("clName", "CoApp. Last Name: ", "Optional"),
            textInput("add1", "Address - Street: ", ""), textInput("add2", "City: ", ""), textInput("add3", "State: ", ""),  numericInput("add4", "Zip: ", "00000"),
            numericInput("phone", "Phone Number: ", "##########"),
            textInput("email", "Email Address: ", ""),
            dateInput("dateOfAppAdd", "Date of Application: "),
            actionButton("checkApp", "Check Application Number"),
            verbatimTextOutput("addedAppNo"), # ( out** 3)
            actionButton("addApp", "Submit"), actionButton("cancelApp", "Cancel"), #submit button
            actionButton("dashFromAddAdoptApp", "Back To Dashboard") # jump to animal dash
    ),
    
    # 6. tab to review pending adoption applications (owner only)
    tabItem(tabName = "reviewAdoptApp",
            h2("Approve/Reject Adoption Applications"),
            tags$hr(style="border-color: black;"),
            h4("Pending:"),
            DT::DTOutput('currentPendingApps', width="85%"), # output current pending applications 
            numericInput('appAdoptNoD',"Application No: ", ""), # app no to approve or reject
            actionButton("approveApp", "Approve"), actionButton("rejectApp", "Reject"), #submit button
            actionButton("dashFromAppReview", "Back To Dashboard") # jump to animal dash
    ),
    
    # 7. tab to add a new adoption (employee only)
    tabItem(tabName = "addAdoption",
            h2("Add New Adoption"),
            tags$hr(style="border-color: black;"),
            h4("Search for Adoption Application:"),
            textInput("alnSearch", "Search - Applicant or Co.App. Last Name: ", ""),
            actionButton("submitLnSearch", "Submit"),
            tags$hr(style="border-color: black;"),
            DT::DTOutput('approvedAdoptApps', width = "85%"), # output approved adoption applications 
            tags$hr(style="border-color: black;"),
            tags$br(),
            
            # submit the adoption details:
            h2("Submit Adoption:"),
            numericInput("appNoForAdopt", "Enter Adoption App. No. from search: ", ""),
            dateInput("dateOfAdoption", "Date of Adoption: "),
            numericInput("adoptFee", "Adoption Fee: ($)", "Enter as X.XX - XXX.XX"),
            actionButton("submitAdopt", "Submit"), actionButton("cancelAdopt", "Cancel"),
            actionButton("dashFromAddAdoption", "Back To Dashboard") # jump to animal dash
    ),
    
    #8. Reports(5): all reports are owner only
    tabItem(tabName = "runReports",
            actionButton("dashFromReports", "Back To Dashboard"), # jump to animal dash
            tags$hr(style="border-color: black;"),
            h2("1. Animal Control Report"), actionButton("runReport1", "Run: Animal Control Report"),
            h2("Animal Control Report - 1"), actionButton("runReport1_1", "Run: Animal Control Report - Drill Down 1"),
            h2("Animal Control Report - 2"), actionButton("runReport1_2", "Run: Animal Control Report - Drill Down 2"),
            DT::DTOutput('report1', width = "85%"),
            DT::DTOutput('report1_1', width = "85%"),
            DT::DTOutput('report1_2', width = "85%"),
            
            tags$hr(style="border-color: black;"),
            h2("2. Volunteer of the Month"), actionButton("runReport2", "Run: Volunteer of the Month"),
            DT::DTOutput('report2', width = "85%"),
            
            tags$hr(style="border-color: black;"),
            h2("3. Monthly Adoption Report"), actionButton("runReport3", "Run: Monthly Adoption Report"),
            DT::DTOutput('report3', width = "85%"),
            
            tags$hr(style="border-color: black;"),
            h2("4. Volunteer Profile"), 
            textInput("vlnSearch", "Search - Volunteer Last Name: ", ""),
            # actionButton("submitVln", "Submit"),
            # tags$br(),
            # h2("Volunteer search result: "),
            # DT::DTOutput('report4search',width = "85%"),
            actionButton("runReport4", "Run: Volunteer Profile"),
            DT::DTOutput('report4', width = "85%"),
            
            tags$hr(style="border-color: black;"),
            h2("5. Vaccine Reminder Report"), actionButton("runReport5", "Run: Vaccine Reminder Report"),
            DT::DTOutput('report5', width = "85%")
            
    )
  )))

# --------------------------------------------------------------------------------------------------------------------------------------------
# SERVER
# --------------------------------------------------------------------------------------------------------------------------------------------
server <- function(input, output, session){
  
  # default global variables are empty strs
  empStatCode <<- ""
  empUn <<- ""
  petIdNum <<- 0
  
  # I. login to animal dash
  observeEvent(input$enterLogin, { 
    un = input$username
    pw = input$password
    
    # a. if login button selected, get un/pw and validate by obtaining employee status (empStat) - volunteer:tff, employee:fft, owner:ftt
    empStat = dbGetQuery(cn, paste0("SELECT (is_volunteer,is_owner,is_employee) FROM users WHERE username = ",paste0("'",un,"'")," AND password = ",paste0("'",pw,"'")))
    
    # if wrong combo, will return empty df
    if(nrow(empStat) == 1){
      empStatCode <<- empStat[1,1]
      empUn <<- un                                                          
      newtab = switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    } else {
      showNotification("Error username or password not found, press cancel to refresh.", type = "warning")
    }
  })
  
  #c. if cancel button selected
  observeEvent(input$cancelLogin, {
    session$reload() #reset app
  })
  
  #------------------------------------------------------------------------------------------------------------------------------------------------------------
  # II.  all actions for all users
  
  # A. View/output dashboard
  # show only animals that are elligible for adoption: animal is altered; animal has >=1 for all req vaccinations for its species; dates are irrelevant)
  animalDashQuery <<- dbGetQuery(cn, paste(readLines('SQL/view_animalDash.sql'), collapse=' \n '))
  adq_keep = animalDashQuery[,c(1:6)]
  colnames(adq_keep) = c("ID","Name","Species","Breed","Sex","Alt.Status")
  adq_age = data.frame(Age = paste(animalDashQuery[,7],animalDashQuery[,8], sep = '.'))
  
  # check adoptability status & format output table 
  adoptStat = animalDashQuery[,10]
  as2 = data.frame(adoptStat[1:nrow(animalDashQuery)])
  colnames(as2)<- c("Adoptability")
  as2$AdoptabilityStatus <- ifelse(as2$Adoptability == "(t,)", "Yes", "No")
  adoptFinal <<- cbind(adq_keep, adq_age, Adoptability=as2$AdoptabilityStatus)
  adtFinal = datatable(adoptFinal, selection = list(mode="single", target="row")) #formatted output table
  output$currentDashView <- renderDT({ adtFinal })
  
  # calculate max capacity ------------
  
  maxCapT = data.frame()
  for(i in 1:length(sl$species)){
    sn = sl[i,1] #species name
    sc = sl[i,2] #species cap
    currentSpeciesNo = length(which(animalDashQuery[,3]==sn))
    if((as.numeric(sc)-as.numeric(currentSpeciesNo)) > 0){
      maxCap = c(sn, (sc-currentSpeciesNo))
      maxCapT = rbind(maxCapT,maxCap)
      currentSpaces = datatable(maxCapT, rownames = FALSE, colnames = "", options = list(dom='tip'))
    }
  }
  output$animalCap <- renderDT({ currentSpaces })
  
  # ---------------------------------------------------  
  #B. if an animal is selected, go to animal detail screen and view/output animal information
  observeEvent(input$animalIdChosen, {
    newtab <- switch(input$tabs,"displayUpdateAnimal")
    updateTabItems(session, "tabs", newtab)
    petIdNum <<- input$animalIdNo
    animalDetailQuery <<- dbGetQuery(cn, paste("SELECT * FROM animals WHERE pet_id = ",petIdNum))
    animalVaccQuery <<- dbGetQuery(cn, paste("SELECT * FROM vaccinations WHERE pet_id = ",petIdNum))
    output$currentAnimalDetail <- renderDT({ animalDetailQuery }, options = list(dom='tip'))
    output$currentAnimalVacc <- renderDT({ animalVaccQuery }, options = list(dom='tip'))
  })
  
  # return to dashboard from animal detail
  observeEvent(input$dashFromAddAdopt, {
    if(empStatCode != ""){
      newtab <- switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # ----------------------------------------------------------------------------------------------------
  
  #C. if animal detail edited
  observeEvent(input$addSex1, {
    if(empStatCode != ""){
      sex1 = input$sex1 # sex: only if unknown
      if(animalDetailQuery[,3]=='unknown'){
        tryCatch({
          dbSendQuery(cn, paste0("UPDATE animals (sex) VALUES (","'",sex1,"') WHERE (pet_id) = ",petIdNum,";"))
        }, error = function(e){
          showNotification("Error: please check 'sex' entry and try again", type = "warning")
        })
      } else {
        showNotification("Error: please check 'sex' entry and try again", type = "warning")
      }
    }
  })
  
  observeEvent(input$addAltStatus1, {
    if(empStatCode != ""){
      alt1 = input$altStatus1 # alt status: if unalt
      if(animalDetailQuery[,4]==0){
        if(alt1=="neutered"){
          statVal = "True"
        } else if(alt1 =='spayed'){
          statVal = "True"
        } else {
          statVal = "False"
        }
        tryCatch({
          dbExecute(cn, paste0("UPDATE animals (alt_status) VALUES ('",statVal,"') WHERE (pet_id) = '",petIdNum,"';"))
        }, error = function(e){
          showNotification("Error: please check 'alt_status' entry and try again", type = "warning")
        })
      }
    }
  })
  
  observeEvent(input$addBreed1, {
    if(empStatCode != ""){
      breed1 = input$breed1
      
      # breed: if unknown/mixed
      if(length(breed1)>1){
        breedList = paste(breed1, sep=",")
      } else {
        breedList = aBreed
      }
      
      tryCatch({
        dbExecute(cn, paste0("UPDATE animals (group_concat(hb.breed_name)) VALUES (","'",breedList,"') WHERE (pet_id) = ",petIdNum,";"))
      }, error = function(e){
        showNotification("Error: please check 'breed' entry and try again", type = "warning")
      })
    }
  })
  
  observeEvent(input$addMicrochipId1, {
    if(empStatCode != ""){
      microchipId1 = input$microchipId  # microchip
      if(length(microchipId1)>1){
        tryCatch({
          dbExecute(cn, paste0("INSERT INTO animals (microchip) VALUES (","'",microchipId1,"') WHERE (pet_id) = ",petIdNum,";"))
        }, error = function(e){
          showNotification("Error: please check 'microchip' entry and try again", type = "warning")
        })
      } else {
        showNotification("Error: please check 'microchip' entry and try again", type = "warning")
      }
    }
  })
  
  # if cancel edit animal detail
  observeEvent(input$cancelDetail, {
    if(empStatCode != ""){
      newtab <- switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # ----------------------------------------------------------------------------------------------------
  
  #D. if animal vaccine added
  observeEvent(input$addVacc, {
    if(empStatCode != ""){
      vaccNew = input$vaccType
      vaccDate = input$dateAdmin
      vaccExp = input$dateExp
      vaccNum = input$vaccineNum
      # vaccName = str_split(vaccNew, '-')[[1]][2]
      
      tryCatch({
        dbExecute(cn, paste0("INSERT INTO vaccinations (pet_id, vaccine_name, date_adm, date_exp, vaccination_number, username) VALUES (",
                             petIdNum,",'",vaccName,"',",vaccDate,",",vaccExp,",'",vaccNum,"','",empUn,"');"))
      }, error = function(e){ 
        showNotification("Error: please check entries and try again", type = "warning")
      })
    }
  })
  
  # if cancel add vaccine
  observeEvent(input$cancelVacc, {
    if(empStatCode != ""){
      newtab <- switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # ----------------------------------------------------------------------------------------------------
  
  #E. if adoption application added
  observeEvent(input$addApp, {
    if(empStatCode != ""){
      appFn = input$fName
      appLn = input$lName
      appCfn = input$cfName
      appFln = input$clName
      appA1 = input$add1
      appA2 = input$add2
      appA3 = input$add3
      appA4 = input$add4
      appPhone = input$phone
      appEmail = input$email
      appDate = input$dateOfAppAdd
      
      #insert to two tables
      tryCatch({
        dbExecute(cn, paste0("INSERT INTO applications(app_date, coapp_f_name, coapp_l_name, a_email, is_approved, is_rejected) VALUES (",
                             appDate,",'",appCfn,"','",appFln,"','",appEmail,"',",0,",",0,");"))
      }, error = function(e){ 
        showNotification("Error: please check application entries and try again", type = "warning")
      })
      
      #second insert
      tryCatch({
        dbExecute(cn, paste0("INSERT INTO adopter(a_email,a_f_name,a_l_name, a_street_addr, a_city,	a_state, a_postal_code, a_phone) VALUES ('",
                             appEmail,"','",appFn,"','",appLn,"','",appA1,"','",appA2,"','",appA3,"','",appA4,"',",appPhone,");"))
      }, error = function(e){ 
        showNotification("Error: please check application entries and try again", type = "warning")
      })
    }
  })
  
  observeEvent(input$checkApp, {
    req(input$email)
    # get app number if successfully added 
    appNum = dbGetQuery(cn, paste0("SELECT app_num FROM applications WHERE a_email = ",input$email,";"))
    if(appNum > 0){
      outNum = appNum
      output$acceptedNum = renderPrint({paste0("New application added: ,",appNum)})
    } else{
      showNotification("Error: please check application entries and try again", type = "warning")
    }
  })
  
  # if add adoption app canceled 
  observeEvent(input$cancelApp, {
    if(empStatCode != ""){
      newtab <- switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # if back to dash from add adoption app
  observeEvent(input$dashFromAddAdoptApp, {
    if(empStatCode != ""){
      newtab <- switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # ------------------------------------------------------------------------------------------------------------------------------------
  # II. actions for employees only
  # from B- animal dash, if employee, can use add animal button from animal dashboard
  observeEvent(input$jumpToAddAnimal,{
    if(empStatCode %in% c("(f,f,t)","(f,t,t)")){
      newtab = switch(input$tabs,"addAnimal")
      updateTabItems(session, "tabs", newtab)
    }  
  })
  
  # from B- animal dash, if employee, can use add adoption app button from animal dashboard
  observeEvent(input$jumpToAddApp,{
    if(empStatCode %in% c("(f,f,t)","(f,t,t)")){
      newtab = switch(input$tabs,"addAdoptApp")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # from C- animal detail screen, if employee, can use add adoption from this animal detail screen
  observeEvent(input$jumpToAddAdopt,{
    if(empStatCode %in% c("(f,f,t)","(f,t,t)")){
      rowNum = which(adoptFinal[,1]==petIdNum)
      if(rowNum != 0){
        if(adoptFinal[rowNum,8] == "Yes"){ 
          newtab = switch(input$tabs,"addAdoption")
          updateTabItems(session, "tabs", newtab)
        } else {
          showNotification("Error: please check pet_id selected and try again", type = "warning")
        }
      } else {
        showNotification("Error: please check pet_id selected and try again", type = "warning")
      }
    }
  })
  
  # #F. if add animal button selected
  observeEvent(input$submitAddAnimal, {
    if(empStatCode %in% c("(f,f,t)","(f,t,t)")){
      aName = 'matt'
      aAge = 11
      aSex = 'Male'
      addAlt = 'false'
      aBreed = 'Abyssinian'
      aSpecies = 'cat'
      aDesc = 'mean'
      aSurrD = "'2018-07-02'"
      addSurrC = 'false'
      aSurrR = 'money'
      aMicro = 123 
      empun = 'inge'
      
      # convert to 0 vs 1  for data entry in sql insert --> altStatus & surrControl
     if(addAlt %in% c("neutered","spayed")){ addAlt = 'True' } else { addAlt = 'False' }
     if(aSurrC == "Yes"){ addSurrC = 'True' } else { addSurC = 'False' }
     if(length(aBreed)>1){
       addBreed = paste(aBreed, sep=",")
     } else {
       addBreed = aBreed
     }
      
      # send query 
      tryCatch({
        dbSendStatement(cn, paste0("INSERT INTO animals (pet_id, animal_name, sex, alt_status, local_control, surrender_date, surrender_reason, description, age_months, microchip, username, ",
                             "species_name, group_concathbbreed_name) VALUES ('",aName,"','",aSex,"',",addAlt,",",addSurC,",",aSurrD,",'",aSurrR,"','",aDesc,"',",aAge,
                             ",'",aMicro,"','",empUn,"','",aBreed,"');"))
      }, error = function(e){ 
        showNotification("Error: please check entries and try again", type = "warning")
      })
    }
  })
  pet_id = 1000
  aName = 'matt'
  aAge = 11
  aSex = 'Male'
  addAlt = 'false'
  aBreed = 'Abyssinian'
  aSpecies = 'cat'
  aDesc = 'mean'
  aSurrD = "'2018-07-02'"
  addSurrC = 'false'
  aSurrR = 'money'
  aMicro = 123 
  empun = 'inge'
  
 test <-        dbSendStatement(cn, paste0("INSERT INTO animals (pet_id, animal_name, sex, alt_status, local_control, surrender_date, surrender_reason, description, age_months, microchip, username, ",
                                           "species_name, group_concathbbreed_name) VALUES ('",pet_id,"','",aName,"','",aSex,"',",addAlt,",",addSurrC,",",aSurrD,",'",aSurrR,"','",aDesc,"',",aAge,
                                           ",'",aMicro,"','",empUn,"','",aSpecies,"','",aBreed,"');"))
    
  # if cancel add animal button selected
  observeEvent(input$cancelAddAnimal, {
    if(empStatCode %in% c("(f,f,t)","(f,t,t)")){
      newtab <- switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # if return from add animal to dash
  observeEvent(input$dashFromAddAnimal, {
    if(empStatCode %in% c("(f,f,t)","(f,t,t)")){
      newtab <- switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # ----------------------------------------------------------------------------------------------------
  # G. If add adoption selected
  
  # allow last name or co last name of application to be search, identifies app# (global var)
  observeEvent(input$submitLnSearch, {
    req(length(input$alnSearch)>0)
    if(empStatCode %in% c("(f,f,t)","(f,t,t)")){
      appSearchLn <<- dbGetQuery(cn, paste0("SELECT Ap.app_num, Ap.app_date, Ad.a_email, Ad.a_f_name, Ad.a_l_name, Ap.coapp_f_name, Ap.coapp_l_name, Ad.a_street_addr,",
                                            "Ad.a_city, Ad.a_state, Ad.a_postal_code, Ad.a_phone FROM adopter AS Ad INNER JOIN applications AS Ap ON Ad.a_email = Ap.a_email",
                                            " WHERE (Ap.is_approved) = True AND (Ad.a_l_name LIKE '%",input$alnSearch,"%' OR Ap.coapp_l_name LIKE '%",input$alnSearch,"%');"))
    }
    output$approvedAdoptApps <- renderDT({ appSearchLn }, options = list(dom='tip'))
  })
  
  # add this above: appNoForAdopt to get the appNum from the above search, output a table there since there can be multiple 
  observeEvent(input$submitAdopt, {
    if(empStatCode %in% c("(f,f,t)","(f,t,t)")){
      req(input$appNoForAdopt)
      adoptDate = input$dateOfAdoption
      adoptCost = input$adoptFee
      # petIdNum is global from navigation to this page from animal detail screen
      
      # INSERT statement to Adoptions for the given app number and petId
      tryCatch({
        dbExecute(cn, paste0("INSERT INTO adoption (pet_id, app_num, adoption_date, fee) VALUES (",petIdNum,",",input$appNoForAdopt,",",adoptDate,",",adoptCost,");"))
      }, error = function(e){ 
        showNotification("Error: please check entries and try again", type = "warning")
      })
    }
  })
  
  # if add adoption cancelled
  observeEvent(input$cancelAdopt, {
    if(empStatCode %in% c("(f,f,t)","(f,t,t)")){
      newtab <- switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # if back to dash from add adoption
  observeEvent(input$dashFromAddAdoption, {
    if(empStatCode %in% c("(f,f,t)","(f,t,t)")){
      newtab <- switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # ------------------------------------------------------------------------------------------------------------------------------------
  # III. actions for owners only
  
  observeEvent(input$jumpToReviewApps, {
    if(empStatCode == "(f,t,t)"){
      newtab <- switch(input$tabs,"reviewAdoptApp")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  observeEvent(input$jumpToReports, {
    if(empStatCode == "(f,t,t)"){
      newtab <- switch(input$tabs,"runReports")
      updateTabItems(session, "tabs", newtab)
    }    
  })
  
  # H. If review adoption applications selected
  pendAppQuery = dbGetQuery(cn, paste("SELECT * FROM applications WHERE is_approved = False AND is_rejected = False;"))
  output$currentPendingApps <- renderDT({ pendAppQuery }, options = list(dom='tip'))
  
  observeEvent(input$approveApp, {
    if(empStatCode == "0,1,1"){
      req(input$appAdoptNoD)
      tryCatch({
        dbExecute(cn, paste0("UPDATE applications SET is_approved = True WHERE (app_num) = ",input$appAdoptNoD,";"))
      }, error = function(e){ 
        showNotification("Error: please check entry and try again", type = "warning")
      })
    }
  })
  
  # if rejecting an application
  observeEvent(input$rejectApp, {
    if(empStatCode == "0,1,1"){
      req(input$appAdoptNoD)
      tryCatch({
        dbExecute(cn, paste0("UPDATE applications SET is_rejected = True WHERE (app_num) = ",input$appAdoptNoD,";"))
      }, error = function(e){ 
        showNotification("Error: please check entry and try again", type = "warning")
      })
    }
  })
  
  # if return from dash from application review
  observeEvent(input$dashFromAppReview, {
    if(empStatCode == "(f,t,t)"){
      newtab <- switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # ----------------------------------------------------------------------------------------------------
  
  # I. If reports selected run that report, if return to dash selected then go to dashTab
  observeEvent(input$dashFromReports, {
    if(empStatCode == "(f,t,t)"){
      newtab <- switch(input$tabs,"dashTab")
      updateTabItems(session, "tabs", newtab)
    }
  })
  
  # report1 - animal control report
  observeEvent(input$runReport1, {
    if(empStatCode == "(f,t,t)"){
      #run the query and output resulting table?:
      report1 = dbGetQuery(cn, paste(readLines('SQL/report1.sql'), collapse=' \n '))
      output$report1 <- renderDT({ report1 }, options = list(dom='tip'))
    } else{
      showNotification("Error: please try again", type = "warning")
    }
  })
  
  # report1 - drill down 1, animal information
  observeEvent(input$runReport1_1, {
    if(empStatCode == "(f,t,t)"){
      report1_1 = dbGetQuery(cn, paste(readLines('SQL/report1_1.sql'), collapse=' \n '))
      output$report1_1 <- renderDT({ report1_1 }, options = list(dom='tip'))
    } else{
      showNotification("Error: please try again", type = "warning")
    }
  })
  
  # report1 - driil down 2, animals rescued over 60 days adopted in that month
  observeEvent(input$runReport1_2, {
    if(empStatCode == "(f,t,t)"){
      report1_2 = dbGetQuery(cn, paste(readLines('SQL/report1_2.sql'), collapse=' \n '))
      output$report1_2 <- renderDT({ report1_2 }, options = list(dom='tip'))
    } else{
      showNotification("Error: please try again", type = "warning")
    }
  })
  
  # report2 - volunteer of the month
  observeEvent(input$runReport2, {
    if(empStatCode == "(f,t,t)"){
      report2 = dbGetQuery(cn, paste(readLines('SQL/report2.sql'), collapse=' \n '))
      output$report2 <- renderDT({ report2 }, options = list(dom='tip'))
    } else{
      showNotification("Error: please try again", type = "warning")
    }
  })
  
  # report3 - monthly adoption report
  observeEvent(input$runReport3, {
    if(empStatCode == "(f,t,t)"){
      report3 = dbGetQuery(cn, paste(readLines('SQL/report3.sql'), collapse=' \n '))
      output$report3 <- renderDT({ report3 }, options = list(dom='tip'))
    }else{
      showNotification("Error: please try again", type = "warning")
    }
  })
  
  # report4 - volunteer lookup & get last name for search
  observeEvent(input$runReport4, {
    req(input$vlnSearch)
    if(empStatCode == "(f,t,t)"){
      r4seach = dbGetQuery(cn, paste0("SELECT (u_f_name, u_l_name, email, phone) FROM users WHERE is_volunteer=True AND (u_l_name LIKE '%",input$vlnSearch,"%') ORDER BY u_l_name ASC;"))
      output$report4 <- renderDT({ r4seach }, options = list(dom='tip'))
    }else{
      showNotification("Error: please try again", type = "warning")
    }
  })
  
  #report5 - vaccine reminder
  observeEvent(input$runReport5, {
    if(empStatCode == "(f,t,t)"){
      report5 = dbGetQuery(cn, paste(readLines('SQL/report_5.sql'), collapse=' \n '))
      output$report5 <- renderDT({ report5 }, options = list(dom='tip'))
    }else{
      showNotification("Error: please try again", type = "warning")
    }
  })
}


# --------------------------------------------------------------------------------------------------------------------------------------------
shinyApp(ui = ui, server = server) #keep here
# --------------------------------------------------------------------------------------------------------------------------------------------
