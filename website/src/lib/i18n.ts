import type { Locale } from "./locale";

export const UI = {
  en: {
    nav: { features: "Features", alternatives: "Alternatives", blog: "Blog" },
    joinWaitlist: "Join waitlist",
    faqHeading: "Frequently asked questions",
    home: "Home",
    footer: { findWorkers: "Find workers", features: "Features", compare: "Compare", company: "Company" },
    footerAbout: "Verified temporary workers near you, for 1 day to 1 week gigs. Currently piloting in one city.",
    footerCopy: "A pilot marketplace connecting shop owners and households with verified nearby temporary workers.",
    allFeatures: "All features",
    allComparisons: "All comparisons",
    privacy: "Privacy",
    terms: "Terms",
  },
  hi: {
    nav: { features: "सुविधाएं", alternatives: "विकल्प", blog: "ब्लॉग" },
    joinWaitlist: "वेटलिस्ट जॉइन करें",
    faqHeading: "अक्सर पूछे जाने वाले सवाल",
    home: "होम",
    footer: { findWorkers: "वर्कर खोजें", features: "सुविधाएं", compare: "तुलना करें", company: "कंपनी" },
    footerAbout: "आपके पास वेरिफाइड टेम्पररी वर्कर, 1 दिन से 1 हफ्ते के काम के लिए। फ़िलहाल एक शहर में पायलट चल रहा है।",
    footerCopy: "एक पायलट मार्केटप्लेस जो दुकान मालिकों और घरों को पास के वेरिफाइड टेम्पररी वर्कर से जोड़ता है।",
    allFeatures: "सभी सुविधाएं",
    allComparisons: "सभी तुलनाएं",
    privacy: "प्राइवेसी",
    terms: "नियम व शर्तें",
  },
  hinglish: {
    nav: { features: "Features", alternatives: "Alternatives", blog: "Blog" },
    joinWaitlist: "Waitlist join karo",
    faqHeading: "Aksar poochhe jaane waale sawaal",
    home: "Home",
    footer: { findWorkers: "Worker dhoondo", features: "Features", compare: "Compare karo", company: "Company" },
    footerAbout: "Aapke paas verified temporary worker, 1 din se 1 hafte ke kaam ke liye. Abhi ek city mein pilot chal raha hai.",
    footerCopy: "Ek pilot marketplace jo shop owners aur gharon ko paas ke verified temporary workers se jodta hai.",
    allFeatures: "Sabhi features",
    allComparisons: "Sabhi comparisons",
    privacy: "Privacy",
    terms: "Terms",
  },
} satisfies Record<Locale, Record<string, unknown>>;

export function ui(locale: Locale) {
  return UI[locale];
}
