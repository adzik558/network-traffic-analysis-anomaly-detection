######################################################################################################
# Instalacja potrzenych bibliotek
######################################################################################################

#install.packages("tidyverse")
#install.packages("lubridate")
#install.packages("data.table")
#install.packages("ggplot2")
#install.packages("plotly")
#install.packages("shiny")
#install.packages("zoo")
#install.packages("xts")
#install.packages("forecast")
#install.packages("tsoutliers")
#install.packages("DT")
#install.packages("scales")
#install.packages("ggcorrplot")
#install.packages("moments")
#install.packages("isotree")

######################################################################################################
# Wczytanie bibliotek
######################################################################################################

library(tidyverse)
library(lubridate)
library(data.table)
library(ggplot2)
library(plotly)
library(shiny)
library(zoo)
library(xts)
library(forecast)
library(tsoutliers)
library(DT)
library(scales)
library(ggcorrplot)
library(moments)
library(isotree)

######################################################################################################
# Importowanie danych do R
######################################################################################################

dane <- read.csv("C:/Users/adzik/Desktop/Midterm_53_group.csv")

######################################################################################################
# Analiza statystyczna ruchu sieciowego
######################################################################################################

summary(dane)
glimpse(dane)
str(dane)
unique(dane$Source)
unique(dane$Destination)
table(dane$Protocol)

######################################################################################################
# Transformacja danych do szeregu czasowego
######################################################################################################

dane$Time <- as.POSIXct(dane$Time, origin = "2025-01-01")

colSums(is.na(dane))

dane <- dane %>%
  mutate(
    Source = as.factor(Source),
    Destination = as.factor(Destination),
    Protocol = as.factor(Protocol)
  )

######################################################################################################
# Macierz korelacji
######################################################################################################

korelacje <- cor(dane[, c('Length','No.')], use = "complete.obs")

# Wizualizacja macierzy korelacji
ggcorrplot(korelacje, lab = TRUE, lab_size = 3)

#####################################################################################################################
# Rozkład długości pakietów
#####################################################################################################################

ggplot(dane, aes(x = Length)) +
  geom_histogram(binwidth = 1000, boundary = 0, fill = "cyan", color = "black") +
  stat_bin(binwidth = 1000, geom = "text", aes(label = ..count..), vjust = -0.5, color = "black", boundary = 0) +
  labs(title = "Rozkład długości pakietów", x = "Długość pakietu", y = "Liczba wystąpień") +
  theme_minimal() +
  xlim(0, 6000)

#####################################################################################################################
# Rozkład protokołów
#####################################################################################################################

protocol_count <- dane %>%
  group_by(Protocol) %>%
  summarise(Frequency = n()) %>%
  arrange(desc(Frequency))

ggplot(protocol_count, aes(x = reorder(Protocol, -Frequency), y = Frequency)) +
  geom_bar(stat = "identity", fill = "blue") +
  geom_text(aes(label = Frequency), vjust = -0.5, size = 3) + 
  labs(title = "Rozkład protokołów", x = "Protokół", y = "Częstotliwość") +
  scale_y_continuous(labels = label_comma()) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

######################################################################################################
# Liczba protokołów na wykresach dla protokołów o dużej i małej liczbie pakietów
######################################################################################################

# Ze względu na duży rozstrzał pomiędzy liczbą pakietów, tworzymy 2 wykresy dla lepszego zobrazowania
protocol_count <- protocol_count %>%
  mutate(Group = ifelse(Frequency > 1000, "Duże wartości", "Małe wartości"))

ggplot(protocol_count, aes(x = reorder(Protocol, -Frequency), y = Frequency)) +
  geom_bar(stat = "identity", fill = "blue") +
  geom_text(aes(label = Frequency), vjust = -0.5, size = 3) +
  labs(title = "Rozkład protokołów", x = "Protokół", y = "Częstotliwość") +
  scale_y_continuous(labels = label_comma()) +
  facet_wrap(~Group, scales = "free_y") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#############################################################################################################
# Podstawowe parametry
#############################################################################################################

time_analysis <- dane %>%
  group_by(Time = floor_date(Time, "minute")) %>%
  summarise(Packets = n())

srednia <- mean(time_analysis$Packets)
mediana <- median(time_analysis$Packets)
wariancja <- var(time_analysis$Packets)
odchylenie_std <- sd(time_analysis$Packets)
skosnosc <- skewness(time_analysis$Packets)
kurt <- kurtosis(time_analysis$Packets)

cat("Średnia:", srednia, "\nMediana:", mediana, "\nWariancja:", wariancja,
    "\nOdchylenie_std:", odchylenie_std, "\nSkośność:", skosnosc, "\nKurtoza:", kurt, "\n")

#############################################################################################################
# Natężenie ruchu w czasie
#############################################################################################################

ggplot(time_analysis, aes(x = Time, y = Packets)) +
  geom_line(color = "black") +
  labs(title = "Natężenie ruchu w czasie", x = "Czas", y = "Liczba pakietów") +
  geom_text(aes(label = Packets), 
            vjust = -0.5, 
            size = 3)

######################################################################################################
# Średnia długość pakietów dla protokołów
######################################################################################################

protocol_summary <- dane %>%
  group_by(Protocol) %>%
  summarise(Avg_Length = mean(Length, na.rm = TRUE), .groups = "drop")

ggplot(protocol_summary, aes(x = reorder(Protocol, Avg_Length), y = Avg_Length)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Średnia długość pakietów dla protokołów", x = "Protokół", y = "Średnia długość") +
  theme_minimal()

######################################################################################################
# Wykrywanie anomalii
######################################################################################################

# Sposób 1 - z użyciem pakietu do wykrywania wartości odstających w szeregach czasowych
traffic_ts <- ts(time_analysis$Packets, frequency = 60) 

anomalies <- tso(traffic_ts)


observed <- as.numeric(traffic_ts)
fitted <- as.numeric(fitted(anomalies$fit))  
time_index <- seq_along(observed) 

anomalies_indices <- anomalies$outliers$ind 
anomaly_data <- data.frame(
  Time = time_index,
  Observed = observed,
  Fitted = c(fitted, rep(NA, length(observed) - length(fitted))),  
  Anomalies = ifelse(time_index %in% anomalies_indices, "Anomaly", "Normal")
)


ggplot(anomaly_data, aes(x = Time)) +
  geom_line(aes(y = Observed, color = "Obserwacje")) +
  geom_line(aes(y = Fitted, color = "Przewidywanie")) +
  geom_point(
    data = anomaly_data %>% filter(Anomalies == "Anomaly"),
    aes(y = Observed, color = "Anomalie"), size = 2, shape = 16
  ) +
  scale_color_manual(
    values = c("Obserwacje" = "blue", "Przewidywanie" = "green", "Anomalie" = "red"),
    name = "Legenda"
  ) +
  labs(
    title = "Wykrywanie anomalii w ruchu sieciowym",
    x = "Czas",
    y = "Liczba pakietów"
  ) +
  theme_minimal()

######################################################################################################

# Sposób 2 - metoda progowa
mean_observed <- mean(observed, na.rm = TRUE)
sd_observed <- sd(observed, na.rm = TRUE)

upper_threshold <- mean_observed + 2*sd_observed
lower_threshold <- mean_observed - 2*sd_observed


anomaly_data <- anomaly_data %>%
  mutate(
    Threshold_Anomaly = ifelse(Observed > upper_threshold | Observed < lower_threshold, "Anomaly", "Normal")
  )

mean_pred <- mean(anomaly_data$Observed, na.rm = TRUE)

# Dodanie przewidywanych wartości (średnia)
anomaly_data <- anomaly_data %>%
  mutate(
    Predicted = mean_pred
  )

# Wykres z metodą progową i przewidywaniem
ggplot(anomaly_data, aes(x = Time)) +
  # Linia dla obserwacji
  geom_line(aes(y = Observed, color = "Obserwacje"), size = 0.5) +
  
  # Linia dla przewidywań (średnia)
  geom_line(aes(y = Predicted, color = "Średnia"), linetype = 1, size = 0.5) +
  
  # Linia progowa - górny próg
  geom_hline(yintercept = upper_threshold, linetype = "dashed", color = "red", size = 0.8) +
  
  # Linia progowa - dolny próg
  geom_hline(yintercept = lower_threshold, linetype = "dashed", color = "red", size = 0.8) +
  
  # Punkty dla anomalii
  geom_point(
    data = anomaly_data %>% filter(Threshold_Anomaly == "Anomaly"),
    aes(y = Observed, color = "Anomalie"), size = 2, shape = 16
  ) +
  
  # Ustalenie kolorów w legendzie
  scale_color_manual(
    values = c("Obserwacje" = "blue", "Anomalie" = "red", "Średnia" = "green"),
    name = "Legenda"
  ) +
  
  # Opis wykresu
  labs(
    title = "Wykrywanie anomalii w ruchu sieciowym (metoda progowa)",
    x = "Czas",
    y = "Liczba pakietów"
  ) +
  theme_minimal()

######################################################################################################

# Sposób 3 - metoda kwantylowa
prog_min <- quantile(time_analysis$Packets, 0.05, na.rm = TRUE)  # Dolny próg (10%)
prog_max <- quantile(time_analysis$Packets, 0.95, na.rm = TRUE)  # Górny próg (90%)

anomaly_data <- anomaly_data %>%
  mutate(
    Quantile_Anomaly = ifelse(Observed < prog_min | Observed > prog_max, "Anomaly", "Normal")
  )


ggplot(anomaly_data, aes(x = Time)) +
  geom_line(aes(y = Observed, color = "Obserwacje")) +
  geom_line(aes(y = Predicted, color = "Średnia"), linetype = 1, size = 0.5) +
  geom_hline(yintercept = prog_min, linetype = "dashed", color = "red", size = 0.8) +
  geom_hline(yintercept = prog_max, linetype = "dashed", color = "red", size = 0.8) +
  geom_point(
    data = anomaly_data %>% filter(Quantile_Anomaly == "Anomaly"),
    aes(y = Observed, color = "Anomalie"), size = 2, shape = 16
  ) +
  scale_color_manual(
    values = c("Obserwacje" = "blue", "Anomalie" = "red", "Średnia" = "green"),
    name = "Legenda"
  ) +
  labs(
    title = "Wykrywanie anomalii w ruchu sieciowym (metoda kwantylowa)",
    x = "Czas",
    y = "Liczba pakietów"
  ) +
  theme_minimal()

######################################################################################################

# Sposób 4 - metoda isolation forest

model_data <- data.frame(Packets = time_analysis$Packets)

model <- isolation.forest(model_data, ndim = 1)

scores <- predict(model, model_data, type = "score")

anomaly_threshold <- 0.6  
anomaly_data <- data.frame(
  Time = seq_along(time_analysis$Packets),
  Observed = time_analysis$Packets,
  Anomalies = ifelse(scores > anomaly_threshold, "Anomaly", "Normal"),
  Score = scores
)

ggplot(anomaly_data, aes(x = Time)) +
  geom_line(aes(y = Observed, color = "Obserwacje"), size = 1) +  
  geom_line(aes(y = Score * max(Observed), color = "Przewidywanie (Score)"), linetype = 1, size = 1) +  
  geom_point(
    data = anomaly_data %>% filter(Anomalies == "Anomaly"),
    aes(y = Observed, color = "Anomalie"), size = 2, shape = 16  
  ) +
  scale_color_manual(
    values = c("Obserwacje" = "blue", "Anomalie" = "red", "Przewidywanie (Score)" = "green"),
    name = "Legenda"
  ) +
  labs(
    title = "Wykrywanie anomalii w ruchu sieciowym przy użyciu Isolation Forest",
    x = "Czas",
    y = "Liczba pakietów"
  ) +
  theme_minimal()

######################################################################################################
# Heatmapa
######################################################################################################

#Heatmapa protokołów w czasie
heatmap_data <- dane %>%
  group_by(Time = floor_date(Time, "minute"), Protocol) %>%
  summarise(Packets = n())

ggplot(heatmap_data, aes(x = Time, y = Protocol, fill = Packets)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "blue") +
  labs(title = "Heatmapa protokołów w czasie", x = "Czas", y = "Protokół")

######################################################################################################

# Heatmapa ruchu sieciowego
heatmap_data <- dane %>%
  group_by(Source, Destination) %>%
  summarise(Total_Length = sum(Length)) %>%
  ungroup() %>%
  arrange(desc(Total_Length)) %>%
  slice_head(n = 10)

ggplot(heatmap_data, aes(x = Source, y = Destination, fill = Total_Length)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "red") +
  labs(title = "Heatmapa ruchu sieciowego (10 największych wartości)", 
       x = "Source", 
       y = "Destination", 
       fill = "Total_length") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

######################################################################################################

# Dashboard
ui <- fluidPage(
  titlePanel("Dashboard Analizy Ruchu Sieciowego"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("timeRange", "Zakres Czasu:",
                  min = min(dane$Time), max = max(dane$Time),
                  value = c(min(dane$Time), max(dane$Time)), timeFormat = "%Y-%m-%d %H:%M:%S")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Wykres Ruchu", plotlyOutput("timePlot")),
        tabPanel("Tabela Danych", dataTableOutput("dataTable")),
        tabPanel("Heatmapa", plotlyOutput("heatmap"))
      )
    )
  )
)

server <- function(input, output) {
  
  filteredData <- reactive({
    dane %>%
      filter(Time >= input$timeRange[1], Time <= input$timeRange[2])
  })

  output$timePlot <- renderPlotly({
    data <- filteredData() %>%
      group_by(Time = floor_date(Time, "minute")) %>%
      summarise(Packets = n(), .groups = "drop")
    
    ggplotly(
      ggplot(data, aes(x = Time, y = Packets)) +
        geom_line(color = "black") +
        labs(title = "Ruch sieciowy w czasie", x = "Czas", y = "Liczba pakietów")
    )
  })
  
  output$dataTable <- DT::renderDT({
    DT::datatable(filteredData())
  })
  
  output$heatmap <- renderPlotly({
    data <- filteredData() %>%
      group_by(Time = floor_date(Time, "minute"), Protocol) %>%
      summarise(Packets = n(), .groups = "drop")
    
    ggplotly(
      ggplot(data, aes(x = Time, y = Protocol, fill = Packets)) +
        geom_tile() +
        scale_fill_gradient(low = "white", high = "blue") +
        labs(title = "Heatmapa protokołów", x = "Czas", y = "Protokół")
    )
  })
}

shinyApp(ui = ui, server = server)

######################################################################################################