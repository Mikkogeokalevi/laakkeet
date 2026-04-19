# AI Rules - Lääkemuistio

## 1) Projektin tarkoitus
- Tämä on selainpohjainen React + Firebase -sovellus lääkkeiden muistamiseen, kirjaamiseen ja varastoseurantaan.
- Päätoiminnot:
  - lääkkeiden lisäys/muokkaus/arkistointi/poisto
  - aikataulutetut annokset (aamu/päivä/ilta/yö + viikonpäivät)
  - annoskirjaus (myös manuaalinen ja pikalisäys)
  - historia + raportin generointi ja kopiointi
  - varastoseuranta + ostoslista
  - dosetit (yhdistelmälääkkeet, jotka vähentävät alilääkkeiden saldoja)
  - Firebase Auth (kirjautuminen/rekisteröinti)

## 2) Tekninen toteutus
- Ei bundleria tai Node build pipelinea tässä kansiossa.
- Sovellus ajetaan suoraan selaimessa:
  - `laakkeet.html` lataa Tailwind CDN:n, Babel Standalone:n ja importmapin.
  - `laakkeet.js` ladataan `type="text/babel"` + `data-type="module"`.
- React 18, lucide-react ikonit, Firebase (app/auth/firestore) tulevat CDN/ESM URL:ista.

## 3) Tiedostokartta (mitä mikäkin tekee)
- `laakkeet.html`
  - appin entrypoint, `<div id="root">`, importmapit, script-lataus.
- `laakkeet.js`
  - **pääsovellus** ja käytännössä koko toiminnallisuus yhdessä tiedostossa.
  - sisältää myös AuthScreenin, HelpViewn, kaikki modaalit, datalogiikan ja renderöinnin.
- `laakkeet.css`
  - kevyt global-tyyli (tausta, fontti, scrollbar, mobiili-overscroll).
- `manifest.json`
  - PWA metadata (standalone/start_url/ikonit).
- `ohjeet.js`
  - käyttöohjeiden sisältö `ohjeData`-taulukkona (HTML-stringit).
- `firebase.js`
  - erillinen Firebase-initialisointi + `auth`, `db`, `APP_ID` export.
- `AuthScreen.js`, `HelpView.js`, `components.js`, `utils.js`
  - näyttävät vanhemmalta/modulaariselta rakenteelta,
  - mutta nykyinen `laakkeet.js` sisältää vastaavat toiminnallisuudet sisäisesti.
  - **Tällä hetkellä ei näytä olevan aktiivisessa käytössä appin entryssä.**
- `laakkeet_logo.png`
  - logo UI:ssa.

## 4) Data- ja polkurakenne Firestoressa
- Sovellus käyttää käyttäjäkohtaista rakennetta:
  - `artifacts/{APP_ID}/users/{uid}/medications`
  - `artifacts/{APP_ID}/users/{uid}/logs`
- `APP_ID = "laakemuistio"`.
- Medikaatiodokumentit sisältävät mm. kenttiä:
  - `name, dosage, stock, trackStock, lowStockLimit, isCourse`
  - `colorKey, schedule[], scheduleTimes{}, weekdays[]`
  - `ingredients[]` (dosetti), `showOnDashboard`, `alertEnabled`, `isArchived`, `order`, `createdAt`
- Logidokumentit sisältävät mm. kenttiä:
  - `medId, medName, medColor, slot, timestamp, reason, ingredients`

## 5) Ydinkäytös (muista ennen muutoksia)
- Auth:
  - `onAuthStateChanged` määrää näytetäänkö kirjautuminen vai app.
- Data:
  - `onSnapshot` kuuntelee lääkkeet + logit reaaliaikaisesti.
- Aikataulut:
  - `TIME_SLOTS` (aamu/päivä/ilta/yö) + viikonpäiväfiltteri.
- Dosetti:
  - kun dosetti kirjataan otetuksi, myös koostumuksen lääkkeiden varastoa vähennetään.
- Myöhästymislogiikka:
  - lääkkeet tunnistetaan myöhästyneiksi ajan perusteella,
  - voidaan merkitä "UNOHDUS"-logiksi.
- Raportti:
  - valittu aikaväli + valitut lääkkeet => tekstiraportti, joka kopioidaan leikepöydälle.

## 6) Tärkeät huomiot kehittäjälle (AI)
1. **Single source of truth on tällä hetkellä `laakkeet.js`.**
   - Älä tee muutoksia ensin `components.js`/`AuthScreen.js` jne. ilman että varmistat, että niitä oikeasti käytetään render-polussa.
2. `laakkeet.js`:ssä oli aiemmin duplikaattimodaaleja; perussiivouksessa ylimääräiset poistettiin.
   - Jos lisäät uusia modaaliblokkeja, varmista ettei samaa statea renderöidä kahdessa kohdassa.
3. Tämä on "no-build" selaintoteutus.
   - Vältä Node/bundler-oletuksia.
4. Tailwind on CDN:stä.
   - Luokkien pitää olla suoraan JSX:ssä (ei build-aikaista purgea tms.).
5. Pidä muutokset pieninä ja testattavina.
   - Erityisesti Firestore-kirjoitukset (add/update/delete) kannattaa tarkistaa virhetilanteissa.
6. Firebase-konfiguraation lähde on `firebase.js`.
   - Älä kopioi firebaseConfigia uudestaan muihin tiedostoihin.

## 7) AI:n työskentelysäännöt tässä repossa
- Ennen muutosta:
  1. paikanna toiminto `laakkeet.js`:stä
  2. tarkista ettei samaa UI:ta ole duplikaattina alempana tiedostossa
  3. tee minimaalinen korjaus
- Muutoksen jälkeen:
  1. varmista että home-tab, history-tab ja modaalit edelleen avautuvat
  2. varmista että lääkkeen otto vähentää varastoa vain odotetusti
  3. varmista ettei auth- tai Firestore-polku muuttunut vahingossa

## 8) Nopeat referenssit
- Entry: `laakkeet.html`
- Päälogiikka: `laakkeet.js`
- Ohjetekstit: `ohjeet.js`
- Firebase setup: `firebase.js`
- Perustyylit: `laakkeet.css`

## 9) Valmiit ylläpitotyökalut
1. `sw.js`
   - perus offline-cache app shellille toteutettu
   - rekisteröinti lisätty `laakkeet.html`:ään
2. `varmuuskopio.bat`
   - luo aikaleimatun varmuuskopion hakemistoon `c:\Users\Tompe\Documents\backupit\laakkeet\...`
3. `vie_githubiin.bat`
   - force-push-pohjainen GitHub-päivitys (`main`)
   - `errorlevel`-tarkistukset korjattu luotettavaan muotoon

## 10) Käytännön tila
- `vie_githubiin.bat` on testattu ajamalla ja meni läpi onnistuneesti.
- PWA-metadataa on kovennettu mobiilikäyttöä varten (`manifest.json`, `laakkeet.html`, `sw.js`).
