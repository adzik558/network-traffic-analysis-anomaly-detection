# Analiza i wizualizacja ruchu sieciowego + wykrywanie anomalii  
Projekt: Analiza i wizualizacja ruchu sieciowego (R, Shiny)

Projekt przedstawia kompletną analizę ruchu sieciowego opartą o dane z narzędzi
monitoringu (NetFlow/Wireshark) oraz stworzenie interaktywnej wizualizacji ruchu
w środowisku **R Shiny**.  
Celem projektu było zrozumienie struktury ruchu sieciowego, analiza protokołów,
identyfikacja nietypowych zachowań oraz wykrywanie potencjalnych anomalii.

Projekt został wykonany w ramach studiów (Inżynieria i Analiza Danych) i stanowi
pełny pipeline — od przetwarzania danych, przez analizę statystyczną, po wizualizację.

## Struktura repozytorium

```plaintext network-traffic-analysis-anomaly-detection/
├── README.md
├── LICENSE
├── requirements.txt
├── data/
│   └── sample_traffic.csv
├── docs/
│   └── dokumentacja.pdf  
├── src/
│   ├── network-traffic-analysis
├── plots/
    └── example_plot.png

```

---

## Cele projektu

- analiza pakietów ruchu sieciowego oraz struktury protokołów,
- wykrywanie nietypowych zachowań wskazujących na anomalie,
- badanie zależności czasowych i częstości występowania zdarzeń,
- budowa interaktywnej aplikacji w **R Shiny** do przeglądania ruchu,
- identyfikacja podejrzanych hostów / portów / protokołów.

---

## Dane i kontekst

Do analizy wykorzystano dane sieciowe wyeksportowane w postaci CSV.  
Zawierały one m.in.:

- adresy IP źródłowe i docelowe,
- porty źródłowe i docelowe,
- rozmiar pakietów,
- liczba pakietów w przepływie,
- czas trwania połączeń,
- używany protokół (TCP/UDP/ICMP),
- timestamp każdego przepływu.

---

## Technologie i biblioteki

W projekcie wykorzystano:

- **R / RStudio**
- tidyverse
- dplyr
- ggplot2
- lubridate
- shiny (interaktywna aplikacja webowa)
- plotly (interaktywne wykresy)
- data.table

---

## Zakres analizy

### 1. Analiza statyczna ruchu
- rozkład protokołów (TCP / UDP / ICMP),
- najaktywniejsze adresy IP,
- analiza kierunków ruchu (SOURCE → DEST),
- porty o najwyższej aktywności,
- statystyki przepływów (bytes, packets).

<img width="866" height="665" alt="image" src="https://github.com/user-attachments/assets/32af0444-f37d-4da5-8b15-d18fa2a446bf" />


<img width="912" height="781" alt="image" src="https://github.com/user-attachments/assets/fd8d0f88-510e-42c6-afc7-7b706d3ab251" />


<img width="818" height="603" alt="image" src="https://github.com/user-attachments/assets/0247f84b-3563-4603-966f-ff5dc8084fac" />


### 2. Analiza czasowa
- aktywność sieci w czasie,
- identyfikacja nietypowych skoków ruchu,
- analiza sezonowości i nagłych zmian.


<img width="745" height="619" alt="image" src="https://github.com/user-attachments/assets/d7800422-7dbb-4d98-a48f-aba2022a9682" />



### 3. Wykrywanie anomalii
Zastosowano:

- wykrywanie wartości odstających (outliers),
- wykrywanie portów/hostów generujących nienaturalnie duży wolumen danych,
- identyfikacja przepływów o ekstremalnym czasie trwania,
- wykrywanie potencjalnie podejrzanych protokołów/połączeń.

<img width="797" height="608" alt="image" src="https://github.com/user-attachments/assets/1bdb421f-57eb-48d7-88f5-020730e4c024" />


<img width="938" height="715" alt="image" src="https://github.com/user-attachments/assets/5ef51b9b-a822-4919-a623-010cf2955429" />


---

## Wizualizacja — aplikacja R Shiny

Interaktywna aplikacja umożliwia:

- filtrowanie ruchu po IP, porcie, protokole,
- przeglądanie aktywności w czasie,
- generowanie wykresów ruchu,
- podgląd tabeli pakietów i przepływów,
- analizę rozkładów i identyfikację podejrzanych aktywności.

<img width="950" height="571" alt="image" src="https://github.com/user-attachments/assets/3bb3c349-17b8-4f0e-80bd-7878d1a69b92" />


<img width="931" height="614" alt="image" src="https://github.com/user-attachments/assets/7fe0815a-72e9-4681-86a7-2602cab8ace8" />


<img width="959" height="577" alt="image" src="https://github.com/user-attachments/assets/f1087442-8a79-4808-a758-7962eba29403" />



## Wnioski końcowe

Ruch sieciowy wykazuje jasne wzorce związane z portami i protokołami:

- anomalia zwykle pojawia się przy:
- nagłym wzroście ruchu,
- rzadkich portach/protokołach,IP generujących niestandardowe obciążenie.



## Jak uruchomić projekt (krok po kroku)
1. Pobierz R oraz RStudio **data/sample.csv**
2. Pobierz plik **data/sample.csv**
3. Pobierz plik **src/network-traffic-analysis.R**
4. Otwórz plik **src/network-traffic-analysis.R**
5. Zainstaluj wymagane biblioteki
6. W kodzie (linijka 45) ustaw ścieżkę pliku z danymi pochodzącymi z Wireshark'a: 
    np. **dane <- read.csv("C:/Users/adzik/Desktop/sample.csv")**
7. Skompiluj kod
8. W Interfejsie RStudio pojawią sie wygenerowane wykresy oraz otworzy się aplikacja Shiny.
