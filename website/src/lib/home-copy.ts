import type { Locale } from "./locale";

interface Step { title: string; text: string }
interface Feature { title: string; text: string; slug?: "verified-workers" | "book-instantly"; icon: "shield" | "bolt" | "lock" | "star" | "globe" }
interface Plan { name: string; price: string; unit: string; blurb: string; points: string[]; featured?: boolean }

export interface HomeCopyShape {
  eyebrow: string;
  heroH1: [string, string]; // [plain, accented]
  heroLede: string;
  ctaOwner: string;
  ctaWorker: string;
  heroNote: string;
  mock: { title: string; skills: string[]; tasks: { title: string; place: string; pay: string; cta: string }[]; chipVerified: string; chipVerifiedSub: string; chipBook: string; chipBookSub: string; alt: string };
  trust: string[];
  howEyebrow: string; howHeading: string; howLede: string;
  howOwnerH: string; howOwnerSteps: Step[];
  howWorkerH: string; howWorkerSteps: Step[];
  useEyebrow: string; useHeading: string; useLede: string;
  featEyebrow: string; featHeading: string; featLede: string; features: Feature[];
  priceEyebrow: string; priceHeading: string; priceLede: string; plans: Plan[]; priceFine: string;
  faqEyebrow: string;
  faqs: { q: string; a: string }[];
  pilotHeading: string; pilotText: string; downloadBtn: string; browseFeatures: string;
}

export const HOME_COPY: Record<Locale, HomeCopyShape> = {
  en: {
    eyebrow: "Verified workers, same day",
    heroH1: ["Need a worker for a day?", "Find one nearby."],
    heroLede: "Jugaadi connects shop owners and households with verified temporary workers nearby, for 1 day, 3 days, or a week.",
    ctaOwner: "I need workers",
    ctaWorker: "I want work",
    heroNote: "Android early access. Currently piloting in one city.",
    mock: {
      title: "Nearby tasks", skills: ["Loading", "Cleaning", "Delivery"],
      tasks: [
        { title: "Loading / unloading", place: "Kirana shop · 1.2 km", pay: "₹600/day", cta: "Respond" },
        { title: "General helper", place: "Home · 2.4 km", pay: "₹500/day", cta: "Respond" },
      ],
      chipVerified: "Verified worker", chipVerifiedSub: "Identity confirmed by admin", chipBook: "Booked", chipBookSub: "Contact shared now",
      alt: "Illustration of the Jugaadi app showing nearby tasks",
    },
    trust: ["Manually verified workers", "Same day, 1 day to 1 week", "Contacts shared only after booking", "No agency commission"],
    howEyebrow: "How it works", howHeading: "Three steps for owners, three for workers",
    howLede: "No agency in the middle. Owners post, workers respond, owners book.",
    howOwnerH: "For shop and home owners",
    howOwnerSteps: [
      { title: "Post a task", text: "Say what help you need, the skill, the dates and the daily pay." },
      { title: "Workers respond", text: "Verified workers nearby see your task and respond to it." },
      { title: "Book and pay directly", text: "Choose who to book. Contact details are shared then, and you pay the worker yourself." },
    ],
    howWorkerH: "For workers",
    howWorkerSteps: [
      { title: "Sign up, add skills", text: "Create a profile and pick the skills you offer." },
      { title: "See nearby tasks", text: "Browse tasks close to you that match what you do." },
      { title: "Respond and get booked", text: "Respond to tasks you can do. If an owner books you, their contact is shared." },
    ],
    useEyebrow: "Find workers near you", useHeading: "Pick the kind of help you need", useLede: "Short, same-day help for the situations that come up in a shop or a home.",
    featEyebrow: "Why Jugaadi", featHeading: "Built for short-notice help", featLede: "Only what the app does today.",
    features: [
      { title: "Verified workers", text: "A verified badge means our admin manually confirmed the worker's identity. It is a basic check, not a guarantee of skill or background.", slug: "verified-workers", icon: "shield" },
      { title: "Book instantly", text: "Post a task, see who responded, and book directly. No agency, no long wait.", slug: "book-instantly", icon: "bolt" },
      { title: "Contacts shared after booking", text: "An owner's number reaches a worker only once that worker is booked.", icon: "lock" },
      { title: "Reviews both ways", text: "Owners and workers review each other after a task, so trust builds up.", icon: "star" },
      { title: "English, Hindi or Hinglish", text: "Use the app in the language you are comfortable with. Set it in Profile.", icon: "globe" },
    ],
    priceEyebrow: "Pricing", priceHeading: "Start free", priceLede: "Prices and limits are also shown in the app before you pay.",
    plans: [
      { name: "Free", price: "₹0", unit: "per month", blurb: "For trying Jugaadi.", points: ["3 task posts a month (owners)", "3 responses a month (workers)", "Verified badges, reviews and booking"] },
      { name: "7-day Pro trial", price: "₹0", unit: "for 7 days", blurb: "Included for new accounts.", points: ["Everything in Pro", "Starts when you create your account", "No payment needed"], featured: true },
      { name: "Pro", price: "₹399", unit: "per 30 days for owners · ₹199 for workers", blurb: "When you outgrow the free limit.", points: ["Unlimited task posts and responses", "One payment per 30 days through Razorpay", "Does not renew automatically"] },
    ],
    priceFine: "Workers pay ₹199 per 30 days for Pro; owners pay ₹399. You choose whether to buy it again.",
    faqEyebrow: "FAQ",
    faqs: [
      { q: "What does Jugaadi actually do?", a: "Connects shop owners and households who need short-term help with nearby workers who can do that specific task, for 1 day to 1 week." },
      { q: "Is Jugaadi live in my city?", a: "We're running a single-city pilot right now. Download the app below to try it." },
      { q: "Do workers need to pay anything?", a: "Signing up, adding your skills and responding to nearby tasks is free, up to 3 responses a month on the free plan. An optional Pro plan removes that limit." },
      { q: "Who can see my phone number?", a: "An owner sees the mobile number of workers who respond to their task. A worker sees the owner's contact only after being booked." },
      { q: "Does Pro renew automatically?", a: "No. Pro is paid for a period of 30 days and you choose whether to buy it again." },
    ],
    pilotHeading: "Now piloting in one city", pilotText: "We're in early testing. Download the app and try it out.",
    downloadBtn: "Download the app", browseFeatures: "Browse features",
  },
  hi: {
    eyebrow: "वेरिफाइड वर्कर, उसी दिन",
    heroH1: ["एक दिन के लिए वर्कर चाहिए?", "पास में ही मिलेगा।"],
    heroLede: "Jugaadi दुकान मालिकों और घरों को पास के वेरिफाइड टेम्पररी वर्कर से जोड़ता है — 1 दिन, 3 दिन, या एक हफ्ते के लिए।",
    ctaOwner: "मुझे वर्कर चाहिए",
    ctaWorker: "मुझे काम चाहिए",
    heroNote: "एंड्रॉइड अर्ली एक्सेस। फ़िलहाल एक शहर में पायलट चल रहा है।",
    mock: {
      title: "पास के टास्क", skills: ["लोडिंग", "सफ़ाई", "डिलीवरी"],
      tasks: [
        { title: "लोडिंग / अनलोडिंग", place: "किराना दुकान · 1.2 किमी", pay: "₹600/दिन", cta: "रिस्पॉन्ड" },
        { title: "जनरल हेल्पर", place: "घर · 2.4 किमी", pay: "₹500/दिन", cta: "रिस्पॉन्ड" },
      ],
      chipVerified: "वेरिफाइड वर्कर", chipVerifiedSub: "एडमिन ने पहचान कन्फर्म की", chipBook: "बुक हो गया", chipBookSub: "अब कॉन्टैक्ट शेयर होगा",
      alt: "Jugaadi ऐप में पास के टास्क दिखाने वाला चित्र",
    },
    trust: ["मैनुअली वेरिफाइड वर्कर", "उसी दिन, 1 दिन से 1 हफ्ता", "कॉन्टैक्ट बुकिंग के बाद ही शेयर", "कोई एजेंसी कमीशन नहीं"],
    howEyebrow: "यह कैसे काम करता है", howHeading: "ओनर के लिए तीन स्टेप, वर्कर के लिए तीन",
    howLede: "बीच में कोई एजेंसी नहीं। ओनर टास्क डालता है, वर्कर रिस्पॉन्ड करता है, ओनर बुक करता है।",
    howOwnerH: "दुकान और घर मालिकों के लिए",
    howOwnerSteps: [
      { title: "टास्क पोस्ट करें", text: "बताएं कौन सी मदद चाहिए, कौन सी स्किल, कौन सी तारीखें और रोज़ का पेमेंट।" },
      { title: "वर्कर रिस्पॉन्ड करते हैं", text: "पास के वेरिफाइड वर्कर आपका टास्क देखकर रिस्पॉन्ड करते हैं।" },
      { title: "सीधे बुक करें और पेमेंट करें", text: "जिसे चुनें उसे बुक करें। तभी कॉन्टैक्ट डिटेल्स शेयर होती हैं, और पेमेंट आप खुद वर्कर को करते हैं।" },
    ],
    howWorkerH: "वर्कर्स के लिए",
    howWorkerSteps: [
      { title: "साइन अप करें, स्किल्स जोड़ें", text: "प्रोफ़ाइल बनाएं और अपनी स्किल्स चुनें।" },
      { title: "पास के टास्क देखें", text: "अपने काम से मिलते-जुलते पास के टास्क देखें।" },
      { title: "रिस्पॉन्ड करें और बुक हों", text: "जो टास्क कर सकें उस पर रिस्पॉन्ड करें। ओनर बुक करे तो उसका कॉन्टैक्ट आपको मिल जाता है।" },
    ],
    useEyebrow: "अपने पास वर्कर खोजें", useHeading: "बताएं कैसी मदद चाहिए", useLede: "दुकान या घर में अचानक आने वाली ज़रूरतों के लिए छोटी, उसी दिन की मदद।",
    featEyebrow: "Jugaadi क्यों", featHeading: "कम समय में मदद के लिए बना", featLede: "सिर्फ़ वही, जो ऐप आज करता है।",
    features: [
      { title: "वेरिफाइड वर्कर", text: "वेरिफाइड बैज का मतलब है कि हमारे एडमिन ने वर्कर की पहचान मैनुअली कन्फर्म की है। यह एक बेसिक चेक है, स्किल या बैकग्राउंड की गारंटी नहीं।", slug: "verified-workers", icon: "shield" },
      { title: "तुरंत बुक करें", text: "टास्क पोस्ट करें, देखें किसने रिस्पॉन्ड किया, और सीधे बुक करें। न एजेंसी, न लंबा इंतज़ार।", slug: "book-instantly", icon: "bolt" },
      { title: "बुकिंग के बाद ही कॉन्टैक्ट", text: "ओनर का नंबर वर्कर को तभी मिलता है जब वह वर्कर बुक हो जाए।", icon: "lock" },
      { title: "दोनों तरफ़ रिव्यू", text: "टास्क के बाद ओनर और वर्कर एक-दूसरे को रिव्यू करते हैं, जिससे भरोसा बनता है।", icon: "star" },
      { title: "अंग्रेज़ी, हिंदी या हिंग्लिश", text: "ऐप को अपनी सुविधा की भाषा में इस्तेमाल करें। प्रोफ़ाइल में सेट करें।", icon: "globe" },
    ],
    priceEyebrow: "प्राइसिंग", priceHeading: "मुफ़्त में शुरू करें", priceLede: "कीमत और लिमिट पेमेंट से पहले ऐप में भी दिखती हैं।",
    plans: [
      { name: "फ्री", price: "₹0", unit: "हर महीने", blurb: "Jugaadi आज़माने के लिए।", points: ["महीने में 3 टास्क पोस्ट (ओनर)", "महीने में 3 रिस्पॉन्स (वर्कर)", "वेरिफाइड बैज, रिव्यू और बुकिंग"] },
      { name: "7 दिन का Pro ट्रायल", price: "₹0", unit: "7 दिन के लिए", blurb: "नए अकाउंट के लिए शामिल।", points: ["Pro की सारी सुविधाएं", "अकाउंट बनते ही शुरू", "कोई पेमेंट नहीं"], featured: true },
      { name: "Pro", price: "₹399", unit: "30 दिन के लिए ओनर · वर्कर के लिए ₹199", blurb: "जब फ्री लिमिट कम पड़े।", points: ["अनलिमिटेड टास्क पोस्ट और रिस्पॉन्स", "30 दिन के लिए एक पेमेंट, Razorpay से", "अपने आप रिन्यू नहीं होता"] },
    ],
    priceFine: "वर्कर Pro के लिए 30 दिन के ₹199 देते हैं; ओनर ₹399। दोबारा खरीदना आपकी मर्ज़ी है।",
    faqEyebrow: "सवाल-जवाब",
    faqs: [
      { q: "Jugaadi असल में क्या करता है?", a: "दुकान मालिकों और घरों को, जिन्हें थोड़े समय की मदद चाहिए, पास के ऐसे वर्कर से जोड़ता है जो वह खास काम 1 दिन से 1 हफ्ते तक कर सकें।" },
      { q: "क्या Jugaadi मेरे शहर में लाइव है?", a: "अभी हम सिर्फ एक शहर में पायलट चला रहे हैं। नीचे से ऐप डाउनलोड करके ट्राई करें।" },
      { q: "क्या वर्कर्स को कुछ पेमेंट करना होता है?", a: "साइन अप करना, स्किल्स जोड़ना और पास के टास्क पर रिस्पॉन्ड करना मुफ़्त है — फ्री प्लान में महीने के 3 रिस्पॉन्स तक। एक वैकल्पिक Pro प्लान यह लिमिट हटा देता है।" },
      { q: "मेरा फ़ोन नंबर कौन देख सकता है?", a: "ओनर को उन वर्कर्स का मोबाइल नंबर दिखता है जो उसके टास्क पर रिस्पॉन्ड करते हैं। वर्कर को ओनर का कॉन्टैक्ट बुक होने के बाद ही दिखता है।" },
      { q: "क्या Pro अपने आप रिन्यू होता है?", a: "नहीं। Pro 30 दिन के लिए खरीदा जाता है और दोबारा खरीदना आपकी मर्ज़ी है।" },
    ],
    pilotHeading: "फ़िलहाल एक शहर में पायलट चल रहा है", pilotText: "हम अभी शुरुआती टेस्टिंग में हैं। ऐप डाउनलोड करें और इस्तेमाल करें।",
    downloadBtn: "ऐप डाउनलोड करें", browseFeatures: "सुविधाएं देखें",
  },
  hinglish: {
    eyebrow: "Verified workers, usi din",
    heroH1: ["Ek din ke liye worker chahiye?", "Paas mein hi milega."],
    heroLede: "Jugaadi shop owners aur gharon ko paas ke verified temporary workers se jodta hai — 1 din, 3 din, ya ek hafte ke liye.",
    ctaOwner: "Mujhe worker chahiye",
    ctaWorker: "Mujhe kaam chahiye",
    heroNote: "Android early access. Abhi ek city mein pilot chal raha hai.",
    mock: {
      title: "Nearby tasks", skills: ["Loading", "Cleaning", "Delivery"],
      tasks: [
        { title: "Loading / unloading", place: "Kirana shop · 1.2 km", pay: "₹600/din", cta: "Respond" },
        { title: "General helper", place: "Ghar · 2.4 km", pay: "₹500/din", cta: "Respond" },
      ],
      chipVerified: "Verified worker", chipVerifiedSub: "Admin ne identity confirm ki", chipBook: "Book ho gaya", chipBookSub: "Ab contact share hoga",
      alt: "Jugaadi app mein nearby tasks dikhane wali illustration",
    },
    trust: ["Manually verified workers", "Usi din, 1 din se 1 hafta", "Contact sirf booking ke baad share", "Koi agency commission nahi"],
    howEyebrow: "Yeh kaise kaam karta hai", howHeading: "Owner ke liye teen steps, worker ke liye teen",
    howLede: "Beech mein koi agency nahi. Owner task post karta hai, worker respond karta hai, owner book karta hai.",
    howOwnerH: "Shop aur home owners ke liye",
    howOwnerSteps: [
      { title: "Task post karo", text: "Batao kaunsi help chahiye, kaunsi skill, kaunsi dates aur daily pay kitna." },
      { title: "Workers respond karte hain", text: "Paas ke verified workers aapka task dekhkar respond karte hain." },
      { title: "Seedha book karo aur pay karo", text: "Jise chaho use book karo. Tabhi contact details share hoti hain, aur pay aap khud worker ko karte ho." },
    ],
    howWorkerH: "Workers ke liye",
    howWorkerSteps: [
      { title: "Sign up karo, skills add karo", text: "Profile banao aur apni skills chuno." },
      { title: "Nearby tasks dekho", text: "Apne kaam se match karte paas ke tasks dekho." },
      { title: "Respond karo aur book ho jao", text: "Jo task kar sako uspe respond karo. Owner book kare toh uska contact aapko mil jaata hai." },
    ],
    useEyebrow: "Apne paas worker dhoondo", useHeading: "Batao kaisi help chahiye", useLede: "Shop ya ghar mein achanak aane wali zaroorton ke liye chhoti, usi din ki help.",
    featEyebrow: "Jugaadi kyun", featHeading: "Short-notice help ke liye bana", featLede: "Sirf wahi, jo app aaj karta hai.",
    features: [
      { title: "Verified workers", text: "Verified badge ka matlab hai ki hamare admin ne worker ki identity manually confirm ki hai. Yeh ek basic check hai, skill ya background ki guarantee nahi.", slug: "verified-workers", icon: "shield" },
      { title: "Turant book karo", text: "Task post karo, dekho kisne respond kiya, aur seedha book karo. Na agency, na lamba wait.", slug: "book-instantly", icon: "bolt" },
      { title: "Booking ke baad hi contact", text: "Owner ka number worker ko tabhi milta hai jab woh worker book ho jaaye.", icon: "lock" },
      { title: "Dono taraf reviews", text: "Task ke baad owner aur worker ek-doosre ko review karte hain, jisse bharosa banta hai.", icon: "star" },
      { title: "English, Hindi ya Hinglish", text: "App ko apni pasand ki language mein use karo. Profile mein set karo.", icon: "globe" },
    ],
    priceEyebrow: "Pricing", priceHeading: "Free mein shuru karo", priceLede: "Price aur limits payment se pehle app mein bhi dikhte hain.",
    plans: [
      { name: "Free", price: "₹0", unit: "har mahine", blurb: "Jugaadi try karne ke liye.", points: ["Mahine mein 3 task posts (owners)", "Mahine mein 3 responses (workers)", "Verified badge, reviews aur booking"] },
      { name: "7-din ka Pro trial", price: "₹0", unit: "7 din ke liye", blurb: "Naye accounts ke liye included.", points: ["Pro ki sab cheezein", "Account banate hi shuru", "Koi payment nahi"], featured: true },
      { name: "Pro", price: "₹399", unit: "30 din ke liye owners · workers ke liye ₹199", blurb: "Jab free limit kam pade.", points: ["Unlimited task posts aur responses", "30 din ka ek payment, Razorpay se", "Apne aap renew nahi hota"] },
    ],
    priceFine: "Workers Pro ke liye 30 din ke ₹199 dete hain; owners ₹399. Dobara kharidna aapki marzi hai.",
    faqEyebrow: "FAQ",
    faqs: [
      { q: "Jugaadi actually karta kya hai?", a: "Shop owners aur gharon ko, jinhe short-term help chahiye, paas ke un workers se jodta hai jo woh specific kaam 1 din se 1 hafte tak kar sakein." },
      { q: "Kya Jugaadi meri city mein live hai?", a: "Abhi hum sirf ek city mein pilot chala rahe hain. Neeche se app download karke try karo." },
      { q: "Kya workers ko kuch pay karna padta hai?", a: "Sign up karna, skills add karna aur nearby tasks par respond karna free hai — free plan mein mahine ke 3 responses tak. Ek optional Pro plan woh limit hata deta hai." },
      { q: "Mera phone number kaun dekh sakta hai?", a: "Owner ko un workers ka mobile number dikhta hai jo uske task par respond karte hain. Worker ko owner ka contact booking ke baad hi dikhta hai." },
      { q: "Kya Pro apne aap renew hota hai?", a: "Nahi. Pro 30 din ke liye kharida jaata hai aur dobara kharidna aapki marzi hai." },
    ],
    pilotHeading: "Abhi ek city mein pilot chal raha hai", pilotText: "Hum abhi early testing mein hain. App download karo aur try karo.",
    downloadBtn: "App download karo", browseFeatures: "Features dekho",
  },
};

export function homeCopy(locale: Locale) {
  return HOME_COPY[locale];
}
