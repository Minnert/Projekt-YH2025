# INLÄMNING – William Minnert – YH2025 – Bokningssystem (Frisör)

Detta projekt innehåller en relationsdatabas för ett bokningssystem till en frisörsalong.

## Tabeller

- Kunder  
- Tjanster  
- Bokningar  
- Bokningslogg  

## Syfte

Databasen lagrar information om kunder, tjänster och bokningar samt loggar händelser kopplade till bokningar.

## Relationer

- Kunder (1) – (N) Bokningar  
- Tjanster (1) – (N) Bokningar  
- Bokningar (1) – (N) Bokningslogg  

## Designval

- Primärnycklar: AUTO_INCREMENT används för unika ID:n  
- Epost: UNIQUE för att undvika dubbletter  
- Status: begränsas till Bokad, Avbokad eller Genomford  
- Constraints: säkerställer rimliga värden (t.ex. pris ≥ 0, längd > 0)  
- Index: används på kund_id, tjanst_id och datum_tid för bättre prestanda  

## Triggers

- Loggar automatiskt när en ny bokning skapas i bokningslogg  

## Stored procedure

- hamta_bokningar_mellan_datum används för att hämta bokningar inom ett visst datumintervall  

## Övrigt

Projektet innehåller även exempel på SELECT, JOIN och index samt användare med olika behörigheter (admin och personal).

## ER-diagram
![bokningssystem](bokningssystem.png)
