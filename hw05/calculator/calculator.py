def scitani(a, b):
    return a + b

def nasobeni(a, b):
    return a * b

def main():
    # Automatické hodnoty
    a = 5  # První číslo
    b = 3  # Druhé číslo

    vysledek_scitani = scitani(a, b)
    print(f"Výsledek sčítání: {vysledek_scitani}")
    
    vysledek_nasobeni = nasobeni(a, b)
    print(f"Výsledek násobení: {vysledek_nasobeni}")

if __name__ == "__main__":
    main()