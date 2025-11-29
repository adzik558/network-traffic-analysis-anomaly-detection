# Analiza i wizualizacja ruchu sieciowego + wykrywanie anomalii  
Projekt: Analiza i wizualizacja ruchu sieciowego (R, Shiny)

Projekt przedstawia kompletną analizę ruchu sieciowego opartą o dane z narzędzi
monitoringu (NetFlow/Wireshark) oraz stworzenie interaktywnej wizualizacji ruchu
w środowisku **R Shiny**.  
Celem projektu było zrozumienie struktury ruchu sieciowego, analiza protokołów,
identyfikacja nietypowych zachowań oraz wykrywanie potencjalnych anomalii.

Projekt został wykonany w ramach studiów (Inżynieria i Analiza Danych) i stanowi
pełny pipeline — od przetwarzania danych, przez analizę statystyczną, po wizualizację.

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

### 2. Analiza czasowa
- aktywność sieci w czasie,
- identyfikacja nietypowych skoków ruchu,
- analiza sezonowości i nagłych zmian.

### 3. Wykrywanie anomalii
Zastosowano:

- wykrywanie wartości odstających (outliers),
- wykrywanie portów/hostów generujących nienaturalnie duży wolumen danych,
- identyfikacja przepływów o ekstremalnym czasie trwania,
- wykrywanie potencjalnie podejrzanych protokołów/połączeń.

---

## Wizualizacja — aplikacja R Shiny

Interaktywna aplikacja umożliwia:

- filtrowanie ruchu po IP, porcie, protokole,
- przeglądanie aktywności w czasie,
- generowanie wykresów ruchu,
- podgląd tabeli pakietów i przepływów,
- analizę rozkładów i identyfikację podejrzanych aktywności.



## Wnioski końcowe

Ruch sieciowy wykazuje jasne wzorce związane z portami i protokołami:

- anomalia zwykle pojawia się przy:
- nagłym wzroście ruchu,
- rzadkich portach/protokołach,IP generujących niestandardowe obciążenie.


