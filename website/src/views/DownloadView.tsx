import type { Locale } from "@/lib/locale";
import { APK_DOWNLOAD_URL, APK_DRIVE_VIEW_URL } from "@/lib/site";
import { breadcrumbList, faqPage } from "@/lib/jsonld";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";
import { Breadcrumbs } from "@/components/Breadcrumbs";
import { Faqs } from "@/components/Faqs";
import { JsonLd } from "@/components/JsonLd";

const COPY: Record<Locale, {
  home: string;
  title: string;
  intro: string;
  downloadBtn: string;
  fallback: string;
  openDrive: string;
  details: string[];
  whatsNewHeading: string;
  whatsNew: string[];
  stepsHeading: string;
  steps: string[];
  dataHeading: string;
  dataText: string;
  faqs: { q: string; a: string }[];
}> = {
  en: {
    home: "Home",
    title: "Download Jugaadi for Android (early access)",
    intro: "Jugaadi version 1.0.0 is available as an early-access APK for Android while we prepare a Play Store listing.",
    downloadBtn: "Download for Android (APK)",
    fallback: "If the download doesn't start,",
    openDrive: "open the file on Google Drive",
    details: ["Version: 1.0.0 (1)", "Platform: Android. iOS is not available yet.", "Hosted on Google Drive — the button downloads directly; the backup link opens the Drive page."],
    whatsNewHeading: "What's in this build",
    whatsNew: [
      "Post tasks (single or multiple workers needed) and manage who's responded",
      "Browse nearby tasks by skill and location, and respond",
      "In-app profile, reviews, and admin tools",
    ],
    stepsHeading: "Install steps",
    steps: [
      "Open the download link on your Android phone. If Drive warns the file can't be scanned for viruses, tap Download anyway.",
      "When the download finishes, open the file. If Android asks, allow your browser or Files app to install unknown apps, then go back and tap Install.",
      "If Play Protect warns about an app not from the Play Store, tap More details, then Install anyway — this happens because it's installed outside a store.",
      "Open Jugaadi and sign in with your phone number.",
    ],
    dataHeading: "Your data",
    dataText: "This is a real pilot build — accounts, tasks, and responses are live, not sample data. See the privacy policy for what's collected and how to delete your account.",
    faqs: [
      { q: "Is this APK safe to install?", a: "It's the same build we're preparing for the Play Store. Android warns about any app installed outside a store — that's expected, not a sign of a problem." },
      { q: "Is this a demo or the real app?", a: "It's a real early-access build connected to the live Jugaadi backend. Tasks and accounts you create are real." },
      { q: "Is there an iOS version?", a: "Not yet — Android only for now." },
    ],
  },
  hi: {
    home: "होम",
    title: "Jugaadi एंड्रॉइड के लिए डाउनलोड करें (अर्ली एक्सेस)",
    intro: "Jugaadi वर्शन 1.0.0 अभी अर्ली-एक्सेस APK के तौर पर एंड्रॉइड के लिए उपलब्ध है, जब तक हम Play Store लिस्टिंग तैयार करते हैं।",
    downloadBtn: "एंड्रॉइड के लिए डाउनलोड करें (APK)",
    fallback: "अगर डाउनलोड शुरू नहीं होता, तो",
    openDrive: "Google Drive पर फ़ाइल खोलें",
    details: ["वर्शन: 1.0.0 (1)", "प्लेटफ़ॉर्म: एंड्रॉइड। iOS अभी उपलब्ध नहीं है।", "Google Drive पर होस्टेड — बटन सीधे डाउनलोड करता है; बैकअप लिंक Drive पेज खोलता है।"],
    whatsNewHeading: "इस बिल्ड में क्या है",
    whatsNew: [
      "टास्क पोस्ट करें (एक या कई वर्कर चाहिए) और रिस्पॉन्ड करने वालों को मैनेज करें",
      "स्किल और लोकेशन के हिसाब से पास के टास्क देखें और रिस्पॉन्ड करें",
      "इन-ऐप प्रोफ़ाइल, रिव्यू, और एडमिन टूल्स",
    ],
    stepsHeading: "इंस्टॉल स्टेप्स",
    steps: [
      "अपने एंड्रॉइड फ़ोन पर डाउनलोड लिंक खोलें। अगर Drive वायरस स्कैन की चेतावनी दे, तो Download anyway टैप करें।",
      "डाउनलोड पूरा होने पर फ़ाइल खोलें। अगर एंड्रॉइड पूछे, तो अपने ब्राउज़र या Files ऐप को install unknown apps की अनुमति दें, फिर वापस जाकर Install टैप करें।",
      "अगर Play Protect चेतावनी दे, तो More details फिर Install anyway टैप करें — यह इसलिए होता है क्योंकि यह स्टोर के बाहर इंस्टॉल हो रहा है।",
      "Jugaadi खोलें और अपने फ़ोन नंबर से साइन इन करें।",
    ],
    dataHeading: "आपका डेटा",
    dataText: "यह एक असली पायलट बिल्ड है — अकाउंट्स, टास्क, और रिस्पॉन्स असली हैं, सैंपल डेटा नहीं। क्या कलेक्ट होता है और अकाउंट कैसे डिलीट करें, यह जानने के लिए प्राइवेसी पॉलिसी देखें।",
    faqs: [
      { q: "क्या यह APK इंस्टॉल करना सुरक्षित है?", a: "यह वही बिल्ड है जो हम Play Store के लिए तैयार कर रहे हैं। स्टोर के बाहर इंस्टॉल किसी भी ऐप के लिए एंड्रॉइड चेतावनी देता है — यह सामान्य है।" },
      { q: "क्या यह डेमो है या असली ऐप?", a: "यह लाइव Jugaadi बैकएंड से जुड़ा असली अर्ली-एक्सेस बिल्ड है। आपके बनाए टास्क और अकाउंट असली हैं।" },
      { q: "क्या iOS वर्शन है?", a: "अभी नहीं — फ़िलहाल सिर्फ़ एंड्रॉइड।" },
    ],
  },
  hinglish: {
    home: "Home",
    title: "Jugaadi Android ke liye download karo (early access)",
    intro: "Jugaadi version 1.0.0 abhi early-access APK ke taur pe Android ke liye available hai, jab tak hum Play Store listing tayyar karte hain.",
    downloadBtn: "Android ke liye download karo (APK)",
    fallback: "Agar download start nahi hota, toh",
    openDrive: "Google Drive pe file kholo",
    details: ["Version: 1.0.0 (1)", "Platform: Android. iOS abhi available nahi hai.", "Google Drive pe hosted — button seedha download karta hai; backup link Drive page kholta hai."],
    whatsNewHeading: "Is build mein kya hai",
    whatsNew: [
      "Task post karo (ek ya multiple workers chahiye) aur jinhone respond kiya unhe manage karo",
      "Skill aur location ke hisaab se nearby tasks dekho aur respond karo",
      "In-app profile, reviews, aur admin tools",
    ],
    stepsHeading: "Install steps",
    steps: [
      "Apne Android phone pe download link kholo. Agar Drive virus-scan warning de, toh Download anyway tap karo.",
      "Download complete hone par file kholo. Agar Android poochhe, toh apne browser ya Files app ko install unknown apps allow karo, phir wapas jaake Install tap karo.",
      "Agar Play Protect warning de, toh More details phir Install anyway tap karo — yeh isliye hota hai kyunki yeh store ke bahar install ho raha hai.",
      "Jugaadi kholo aur apne phone number se sign in karo.",
    ],
    dataHeading: "Aapka data",
    dataText: "Yeh ek real pilot build hai — accounts, tasks, aur responses real hain, sample data nahi. Kya collect hota hai aur account kaise delete karein, yeh jaanne ke liye privacy policy dekho.",
    faqs: [
      { q: "Kya yeh APK install karna safe hai?", a: "Yeh wahi build hai jo hum Play Store ke liye tayyar kar rahe hain. Store ke bahar install kisi bhi app ke liye Android warning deta hai — yeh normal hai." },
      { q: "Kya yeh demo hai ya real app?", a: "Yeh live Jugaadi backend se connected real early-access build hai. Aapke banaye tasks aur accounts real hain." },
      { q: "Kya iOS version hai?", a: "Abhi nahi — filhaal sirf Android." },
    ],
  },
};

export function DownloadView({ locale }: { locale: Locale }) {
  const t = COPY[locale];
  const prefix = locale === "en" ? "" : `/${locale}`;
  const path = `${prefix}/download`;
  const crumbs = [{ name: t.home, path: locale === "en" ? "/" : `/${locale}` }, { name: t.title, path }];
  const jsonld = [breadcrumbList(crumbs), faqPage(t.faqs)].filter((n): n is NonNullable<typeof n> => n !== null);

  return (
    <>
      <Header locale={locale} path="/download" />
      <main>
        <article>
          <JsonLd data={jsonld} />
          <Breadcrumbs items={crumbs} />
          <h1>{t.title}</h1>
          <p>{t.intro}</p>
          <p>
            <a className="btn" data-cta="download-apk" href={APK_DOWNLOAD_URL} rel="noopener noreferrer">
              {t.downloadBtn}
            </a>
          </p>
          <p>
            {t.fallback}{" "}
            <a data-cta="download-apk-drive" href={APK_DRIVE_VIEW_URL} target="_blank" rel="noopener noreferrer">
              {t.openDrive}
            </a>
            .
          </p>
          <ul>
            {t.details.map((d) => (
              <li key={d}>{d}</li>
            ))}
          </ul>

          <h2>{t.whatsNewHeading}</h2>
          <ul>
            {t.whatsNew.map((item) => (
              <li key={item}>{item}</li>
            ))}
          </ul>

          <h2>{t.stepsHeading}</h2>
          <ol>
            {t.steps.map((step) => (
              <li key={step}>{step}</li>
            ))}
          </ol>

          <h2>{t.dataHeading}</h2>
          <p>{t.dataText}</p>

          <Faqs faqs={t.faqs} locale={locale} />
        </article>
      </main>
      <Footer locale={locale} />
    </>
  );
}
