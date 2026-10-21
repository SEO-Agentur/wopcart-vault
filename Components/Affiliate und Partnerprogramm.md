# Affiliate: was WopCart kann und was nicht

**Stand:** 2026-10-21 · **Verwandt:** [[Components/Monetisation]] · [[Planning/Roadmap-Status]]

## Kurzantwort

WopCart hat **kein eigenes Affiliate-System**. Es bindet fremde an, und es gibt eine
Ankündigungsseite für ein eigenes Partnerprogramm, das noch nicht existiert.

## 1. Anbindung an fremde Affiliate-Plugins — vorhanden

`src/Integrations/Providers/AffiliateWp.php` und `src/Integrations/Providers/SliceWp.php`
melden abgeschlossene Verkäufe an **AffiliateWP** bzw. **SliceWP**, die dann die
Provisionen der Partner des Händlers berechnen und auszahlen. WopCart liefert das
Ereignis, die Provisionslogik liegt im fremden Plugin.

Heißt für Händler: Wer mit WopCart verkauft, kann Partner vergüten, braucht dafür aber
eines der beiden Plugins.

## 2. Eigenes Partnerprogramm für wopcart.com — offen

`/affiliates/` kündigt ein Programm für Urheber und Agenturen an, die WopCart empfehlen,
Stand „coming soon", Konditionen nicht festgelegt. In der Roadmap steht „Partner and
affiliate program" unter **Planned**.

Wenn das kommt, hängt es an WopCart Direct: Empfehler würden am Verkauf des Add-ons
beteiligt, nicht an den Umsätzen der Händlershops.

## 3. Was dafür fehlen würde

- Partnerkonten, Empfehlungs-Links und Zuordnung des Kaufs zum Partner
- Provisionssatz und Auszahlungsweg, inklusive Steuerfragen (Malta, Reverse Charge)
- Abgrenzung zur 14-Tage-Widerrufsfrist: Provision erst nach deren Ablauf
- Entscheidung, ob das über AffiliateWP im eigenen Shop läuft oder eigener Code wird —
  der eigene Shop nutzt WopCart selbst, AffiliateWP wäre also der kürzeste Weg
