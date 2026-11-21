import type { KbEntry } from "./types";

/**
 * Knowledge base for the support bot, generated from the admin repo's
 * chatbot-knowledge-base/supportKb-import.json (the source of truth: edit
 * there or in the admin's Support → Knowledge base, then regenerate).
 *
 * `npm run seed:support` REPLACES the whole supportKb collection with this
 * list, wiping edits made in the admin. For production prefer the admin's
 * Import JSON, which only upserts.
 *
 * bn / hi / pa text needs review by native speakers.
 */
export const KB_SEED: KbEntry[] = [
  {
    "id": "where_is_order",
    "action": "order_status",
    "title": {
      "en": "Where is my order?",
      "bn": "আমার অর্ডার কোথায়?",
      "hi": "मेरा ऑर्डर कहाँ है?",
      "pa": "ਮੇਰਾ ਆਰਡਰ ਕਿੱਥੇ ਹੈ?"
    },
    "questions": {
      "en": [
        "Where is my order?",
        "Track my order",
        "When will my order arrive?",
        "How long will delivery take?",
        "order status",
        "order kab aayega",
        "order kahan hai",
        "where is my delivery",
        "wheres my order",
        "order kothay",
        "how much time left"
      ],
      "bn": [
        "আমার অর্ডার কোথায়?",
        "অর্ডার কখন আসবে?",
        "ডেলিভারি কতক্ষণ লাগবে?"
      ],
      "hi": [
        "मेरा ऑर्डर कहाँ है?",
        "ऑर्डर कब आएगा?",
        "डिलीवरी में कितना समय लगेगा?"
      ],
      "pa": [
        "ਮੇਰਾ ਆਰਡਰ ਕਿੱਥੇ ਹੈ?",
        "ਆਰਡਰ ਕਦੋਂ ਆਵੇਗਾ?",
        "ਡਿਲੀਵਰੀ ਵਿੱਚ ਕਿੰਨਾ ਸਮਾਂ ਲੱਗੇਗਾ?"
      ]
    },
    "answers": {
      "en": "",
      "bn": "",
      "hi": "",
      "pa": ""
    },
    "keywords": [
      "track",
      "tracking",
      "eta",
      "status",
      "trak",
      "kab",
      "kahan"
    ],
    "related": [
      "late_order",
      "live_tracking",
      "order_statuses"
    ]
  },
  {
    "id": "late_order",
    "action": "order_status",
    "title": {
      "en": "My order is late",
      "bn": "অর্ডার দেরি হচ্ছে",
      "hi": "ऑर्डर देर से आ रहा है",
      "pa": "ਆਰਡਰ ਲੇਟ ਹੈ"
    },
    "questions": {
      "en": [
        "My order is late",
        "My order hasn't arrived yet",
        "My order never came",
        "It's taking too long",
        "order abhi tak nahi aaya",
        "still waiting for my order",
        "delivery delayed",
        "order late keno",
        "my parcel has not reached yet",
        "package not received"
      ],
      "bn": [
        "আমার অর্ডার দেরি হচ্ছে",
        "অর্ডার এখনও আসেনি",
        "অনেক সময় লাগছে"
      ],
      "hi": [
        "मेरा ऑर्डर लेट है",
        "ऑर्डर अभी तक नहीं आया",
        "बहुत देर हो रही है"
      ],
      "pa": [
        "ਮੇਰਾ ਆਰਡਰ ਲੇਟ ਹੈ",
        "ਆਰਡਰ ਅਜੇ ਤੱਕ ਨਹੀਂ ਆਇਆ",
        "ਬਹੁਤ ਦੇਰ ਹੋ ਰਹੀ ਹੈ"
      ]
    },
    "answers": {
      "en": "Sorry for the wait. If it's past the expected time, tap “Talk to a person” and our team will check with the delivery partner.",
      "bn": "অপেক্ষা করানোর জন্য দুঃখিত। প্রত্যাশিত সময় পেরিয়ে গেলে “কারও সঙ্গে কথা বলুন”-এ ট্যাপ করুন, আমাদের টিম ডেলিভারি পার্টনারের সঙ্গে কথা বলবে।",
      "hi": "इंतज़ार के लिए माफ़ कीजिए। अगर तय समय निकल गया है, तो “किसी से बात करें” पर टैप करें, हमारी टीम डिलीवरी पार्टनर से पता करेगी।",
      "pa": "ਉਡੀਕ ਲਈ ਮਾਫ਼ ਕਰਨਾ। ਜੇ ਤੈਅ ਸਮਾਂ ਲੰਘ ਗਿਆ ਹੈ, ਤਾਂ “ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ” ’ਤੇ ਟੈਪ ਕਰੋ, ਸਾਡੀ ਟੀਮ ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਤੋਂ ਪਤਾ ਕਰੇਗੀ।"
    },
    "keywords": [
      "late",
      "delay",
      "delayed",
      "waiting",
      "slow",
      "der"
    ],
    "related": [
      "where_is_order",
      "talk_to_person"
    ]
  },
  {
    "id": "order_statuses",
    "action": "none",
    "title": {
      "en": "What the order statuses mean",
      "bn": "অর্ডারের স্ট্যাটাসের মানে",
      "hi": "ऑर्डर स्टेटस का मतलब",
      "pa": "ਆਰਡਰ ਸਟੇਟਸ ਦਾ ਮਤਲਬ"
    },
    "questions": {
      "en": [
        "What does Packed mean?",
        "What do the order statuses mean?",
        "What is Out for delivery?",
        "order placed but nothing happening",
        "status meaning"
      ],
      "bn": [
        "প্যাকড মানে কী?",
        "অর্ডারের স্ট্যাটাসগুলোর মানে কী?"
      ],
      "hi": [
        "पैक्ड का मतलब क्या है?",
        "ऑर्डर स्टेटस का क्या मतलब है?"
      ],
      "pa": [
        "ਪੈਕਡ ਦਾ ਕੀ ਮਤਲਬ ਹੈ?",
        "ਆਰਡਰ ਸਟੇਟਸ ਦਾ ਕੀ ਮਤਲਬ ਹੈ?"
      ]
    },
    "answers": {
      "en": "Your Zyppi order moves through these steps: “Order placed” (the store is getting it ready), “Packed” (ready and waiting for a delivery partner), “Out for delivery” (the rider is on the way), then “Delivered”. If something goes wrong it shows “Cancelled”. You get a notification at each step.",
      "bn": "আপনার Zyppi অর্ডার এই ধাপগুলো পেরোয়: “অর্ডার হয়েছে” (দোকান তৈরি করছে), “প্যাকড” (তৈরি, ডেলিভারি পার্টনারের অপেক্ষায়), “ডেলিভারির পথে” (রাইডার আসছেন), তারপর “ডেলিভারি হয়েছে”। কোনো সমস্যা হলে “বাতিল” দেখায়। প্রতিটি ধাপে নোটিফিকেশন পাবেন।",
      "hi": "आपका Zyppi ऑर्डर इन चरणों से गुज़रता है: “ऑर्डर हो गया” (दुकान तैयार कर रही है), “पैक्ड” (तैयार, डिलीवरी पार्टनर का इंतज़ार), “डिलीवरी के लिए निकला” (राइडर रास्ते में है), फिर “डिलीवर हो गया”। कोई दिक्कत हो तो “कैंसिल” दिखता है। हर चरण पर नोटिफ़िकेशन मिलता है।",
      "pa": "ਤੁਹਾਡਾ Zyppi ਆਰਡਰ ਇਹਨਾਂ ਕਦਮਾਂ ਵਿੱਚੋਂ ਲੰਘਦਾ ਹੈ: “ਆਰਡਰ ਹੋ ਗਿਆ” (ਦੁਕਾਨ ਤਿਆਰ ਕਰ ਰਹੀ ਹੈ), “ਪੈਕਡ” (ਤਿਆਰ, ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਦੀ ਉਡੀਕ), “ਡਿਲੀਵਰੀ ਲਈ ਨਿਕਲਿਆ” (ਰਾਈਡਰ ਰਸਤੇ ਵਿੱਚ ਹੈ), ਫਿਰ “ਡਿਲੀਵਰ ਹੋ ਗਿਆ”। ਕੋਈ ਗੜਬੜ ਹੋਵੇ ਤਾਂ “ਰੱਦ” ਦਿਖਦਾ ਹੈ। ਹਰ ਕਦਮ ’ਤੇ ਨੋਟੀਫ਼ਿਕੇਸ਼ਨ ਮਿਲਦਾ ਹੈ।"
    },
    "keywords": [
      "placed",
      "packed",
      "out for delivery",
      "delivered",
      "cancelled",
      "meaning"
    ],
    "related": [
      "where_is_order",
      "live_tracking"
    ]
  },
  {
    "id": "live_tracking",
    "action": "none",
    "title": {
      "en": "Track the rider live",
      "bn": "রাইডারকে লাইভ ট্র্যাক",
      "hi": "राइडर को लाइव ट्रैक करें",
      "pa": "ਰਾਈਡਰ ਨੂੰ ਲਾਈਵ ਟ੍ਰੈਕ ਕਰੋ"
    },
    "questions": {
      "en": [
        "How do I track the rider?",
        "Where is the delivery boy?",
        "rider location not updating",
        "track rider live",
        "rider kitna door hai",
        "map not moving"
      ],
      "bn": [
        "রাইডার কোথায় আছে?",
        "রাইডারের লোকেশন আপডেট হচ্ছে না"
      ],
      "hi": [
        "राइडर कहाँ है?",
        "राइडर की लोकेशन अपडेट नहीं हो रही"
      ],
      "pa": [
        "ਰਾਈਡਰ ਕਿੱਥੇ ਹੈ?",
        "ਰਾਈਡਰ ਦੀ ਲੋਕੇਸ਼ਨ ਅੱਪਡੇਟ ਨਹੀਂ ਹੋ ਰਹੀ"
      ]
    },
    "answers": {
      "en": "When your Zyppi order is “Out for delivery”, the order screen shows how far the rider is and about how long they will take, for example “Rider is 1.2 km away · ~4 min”. Before a rider is assigned it says “Assigning a delivery partner…”. If you see “Location updated a few minutes ago”, the rider’s phone has a weak signal — the order is still on its way.",
      "bn": "আপনার Zyppi অর্ডার “ডেলিভারির পথে” হলে অর্ডার স্ক্রিনে দেখাবে রাইডার কত দূরে আর কত সময় লাগবে, যেমন “রাইডার 1.2 km দূরে · ~4 মিনিট”। রাইডার ঠিক হওয়ার আগে লেখা থাকে “ডেলিভারি পার্টনার খোঁজা হচ্ছে…”। “কয়েক মিনিট আগে লোকেশন আপডেট হয়েছে” দেখালে রাইডারের ফোনে নেটওয়ার্ক দুর্বল — অর্ডার তবুও আসছে।",
      "hi": "जब आपका Zyppi ऑर्डर “डिलीवरी के लिए निकला” हो, तो ऑर्डर स्क्रीन पर दिखता है कि राइडर कितनी दूर है और कितना समय लगेगा, जैसे “राइडर 1.2 km दूर है · ~4 मिनट”। राइडर तय होने से पहले लिखा आता है “डिलीवरी पार्टनर ढूँढ रहे हैं…”। “लोकेशन कुछ मिनट पहले अपडेट हुई” दिखे तो राइडर के फ़ोन में नेटवर्क कमज़ोर है — ऑर्डर फिर भी रास्ते में है।",
      "pa": "ਜਦੋਂ ਤੁਹਾਡਾ Zyppi ਆਰਡਰ “ਡਿਲੀਵਰੀ ਲਈ ਨਿਕਲਿਆ” ਹੋਵੇ, ਤਾਂ ਆਰਡਰ ਸਕ੍ਰੀਨ ’ਤੇ ਦਿਖਦਾ ਹੈ ਕਿ ਰਾਈਡਰ ਕਿੰਨੀ ਦੂਰ ਹੈ ਅਤੇ ਕਿੰਨਾ ਸਮਾਂ ਲੱਗੇਗਾ, ਜਿਵੇਂ “ਰਾਈਡਰ 1.2 km ਦੂਰ ਹੈ · ~4 ਮਿੰਟ”। ਰਾਈਡਰ ਤੈਅ ਹੋਣ ਤੋਂ ਪਹਿਲਾਂ ਲਿਖਿਆ ਆਉਂਦਾ ਹੈ “ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਲੱਭ ਰਹੇ ਹਾਂ…”। “ਲੋਕੇਸ਼ਨ ਕੁਝ ਮਿੰਟ ਪਹਿਲਾਂ ਅੱਪਡੇਟ ਹੋਈ” ਦਿਖੇ ਤਾਂ ਰਾਈਡਰ ਦੇ ਫ਼ੋਨ ਵਿੱਚ ਨੈੱਟਵਰਕ ਕਮਜ਼ੋਰ ਹੈ — ਆਰਡਰ ਫਿਰ ਵੀ ਰਸਤੇ ਵਿੱਚ ਹੈ।"
    },
    "keywords": [
      "rider",
      "delivery boy",
      "location",
      "map",
      "distance",
      "live",
      "raider"
    ],
    "related": [
      "rider_contact",
      "where_is_order"
    ]
  },
  {
    "id": "rider_contact",
    "action": "none",
    "title": {
      "en": "Call my delivery partner",
      "bn": "ডেলিভারি পার্টনারকে ফোন",
      "hi": "डिलीवरी पार्टनर को कॉल करें",
      "pa": "ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਨੂੰ ਕਾਲ ਕਰੋ"
    },
    "questions": {
      "en": [
        "How do I call the rider?",
        "rider phone number",
        "contact delivery boy",
        "give delivery instructions",
        "rider ko call kaise kare",
        "rider is not picking up"
      ],
      "bn": [
        "রাইডারকে কীভাবে ফোন করব?",
        "রাইডারের নম্বর"
      ],
      "hi": [
        "राइडर को कॉल कैसे करें?",
        "राइडर का नंबर"
      ],
      "pa": [
        "ਰਾਈਡਰ ਨੂੰ ਕਾਲ ਕਿਵੇਂ ਕਰੀਏ?",
        "ਰਾਈਡਰ ਦਾ ਨੰਬਰ"
      ]
    },
    "answers": {
      "en": "Once a delivery partner is assigned to your Zyppi order, tap “Call delivery partner” on the order screen to talk to them — for example to explain a landmark or which gate to use. The rider can also call the mobile number on your profile when they reach you, so keep your phone nearby. If the rider is not reachable, tap “Talk to a person”.",
      "bn": "আপনার Zyppi অর্ডারে ডেলিভারি পার্টনার ঠিক হলে অর্ডার স্ক্রিনে “ডেলিভারি পার্টনারকে কল করুন” ট্যাপ করে কথা বলুন — যেমন ল্যান্ডমার্ক বা কোন গেট, বুঝিয়ে দিতে। পৌঁছে রাইডারও আপনার প্রোফাইলের মোবাইল নম্বরে ফোন করতে পারেন, তাই ফোন কাছে রাখুন। রাইডারকে না পেলে “কারও সঙ্গে কথা বলুন” ট্যাপ করুন।",
      "hi": "आपके Zyppi ऑर्डर पर डिलीवरी पार्टनर तय होते ही ऑर्डर स्क्रीन पर “डिलीवरी पार्टनर को कॉल करें” पर टैप करके बात करें — जैसे लैंडमार्क या कौन-सा गेट, बताने के लिए। पहुँचने पर राइडर भी आपकी प्रोफ़ाइल के मोबाइल नंबर पर कॉल कर सकता है, इसलिए फ़ोन पास रखें। राइडर से बात न हो पाए तो “किसी से बात करें” पर टैप करें।",
      "pa": "ਤੁਹਾਡੇ Zyppi ਆਰਡਰ ’ਤੇ ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਤੈਅ ਹੁੰਦੇ ਹੀ ਆਰਡਰ ਸਕ੍ਰੀਨ ’ਤੇ “ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਨੂੰ ਕਾਲ ਕਰੋ” ’ਤੇ ਟੈਪ ਕਰਕੇ ਗੱਲ ਕਰੋ — ਜਿਵੇਂ ਲੈਂਡਮਾਰਕ ਜਾਂ ਕਿਹੜਾ ਗੇਟ, ਦੱਸਣ ਲਈ। ਪਹੁੰਚਣ ’ਤੇ ਰਾਈਡਰ ਵੀ ਤੁਹਾਡੀ ਪ੍ਰੋਫ਼ਾਈਲ ਦੇ ਮੋਬਾਈਲ ਨੰਬਰ ’ਤੇ ਕਾਲ ਕਰ ਸਕਦਾ ਹੈ, ਇਸ ਲਈ ਫ਼ੋਨ ਕੋਲ ਰੱਖੋ। ਰਾਈਡਰ ਨਾਲ ਗੱਲ ਨਾ ਹੋਵੇ ਤਾਂ “ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ” ’ਤੇ ਟੈਪ ਕਰੋ।"
    },
    "keywords": [
      "call",
      "phone",
      "number",
      "contact",
      "instructions",
      "rider",
      "delivery boy"
    ],
    "related": [
      "live_tracking",
      "delivery_code",
      "talk_to_person"
    ]
  },
  {
    "id": "delivery_code",
    "action": "none",
    "title": {
      "en": "Delivery code",
      "bn": "ডেলিভারি কোড",
      "hi": "डिलीवरी कोड",
      "pa": "ਡਿਲੀਵਰੀ ਕੋਡ"
    },
    "questions": {
      "en": [
        "What is the delivery code?",
        "Rider is asking for an OTP",
        "Where do I find the delivery OTP?",
        "delivery code is not working",
        "rider bol raha code batao",
        "4 digit code",
        "delivery pin"
      ],
      "bn": [
        "ডেলিভারি কোড কী?",
        "রাইডার OTP চাইছে"
      ],
      "hi": [
        "डिलीवरी कोड क्या है?",
        "राइडर OTP माँग रहा है"
      ],
      "pa": [
        "ਡਿਲੀਵਰੀ ਕੋਡ ਕੀ ਹੈ?",
        "ਰਾਈਡਰ OTP ਮੰਗ ਰਿਹਾ ਹੈ"
      ]
    },
    "answers": {
      "en": "Every Zyppi order has a 4-digit delivery code, shown on the order screen under “Delivery code”. Tell it to your rider at the door — the order is only marked delivered once they enter it, so nobody else can receive your groceries. Share it only when the rider is in front of you. After 5 wrong tries the code locks and our team helps the rider finish the delivery.",
      "bn": "প্রতিটি Zyppi অর্ডারের একটি ৪ সংখ্যার ডেলিভারি কোড থাকে, অর্ডার স্ক্রিনে “ডেলিভারি কোড”-এ দেখায়। দরজায় রাইডারকে কোডটি বলুন — তিনি কোড দিলে তবেই অর্ডার ডেলিভারি হয়, তাই অন্য কেউ আপনার জিনিস নিতে পারবে না। রাইডার সামনে থাকলেই কোড বলুন। ৫ বার ভুল হলে কোড লক হয়ে যায়, তখন আমাদের টিম রাইডারকে সাহায্য করে।",
      "hi": "हर Zyppi ऑर्डर का 4 अंकों का डिलीवरी कोड होता है, जो ऑर्डर स्क्रीन पर “डिलीवरी कोड” में दिखता है। दरवाज़े पर राइडर को यह कोड बताएँ — कोड डालने पर ही ऑर्डर डिलीवर माना जाता है, ताकि कोई और आपका सामान न ले सके। कोड तभी बताएँ जब राइडर सामने हो। 5 बार गलत कोड पर यह लॉक हो जाता है और हमारी टीम राइडर की मदद करती है।",
      "pa": "ਹਰ Zyppi ਆਰਡਰ ਦਾ 4 ਅੰਕਾਂ ਦਾ ਡਿਲੀਵਰੀ ਕੋਡ ਹੁੰਦਾ ਹੈ, ਜੋ ਆਰਡਰ ਸਕ੍ਰੀਨ ’ਤੇ “ਡਿਲੀਵਰੀ ਕੋਡ” ਵਿੱਚ ਦਿਖਦਾ ਹੈ। ਦਰਵਾਜ਼ੇ ’ਤੇ ਰਾਈਡਰ ਨੂੰ ਇਹ ਕੋਡ ਦੱਸੋ — ਕੋਡ ਪਾਉਣ ’ਤੇ ਹੀ ਆਰਡਰ ਡਿਲੀਵਰ ਮੰਨਿਆ ਜਾਂਦਾ ਹੈ, ਤਾਂ ਜੋ ਕੋਈ ਹੋਰ ਤੁਹਾਡਾ ਸਾਮਾਨ ਨਾ ਲੈ ਸਕੇ। ਕੋਡ ਤਾਂ ਹੀ ਦੱਸੋ ਜਦੋਂ ਰਾਈਡਰ ਸਾਹਮਣੇ ਹੋਵੇ। 5 ਵਾਰ ਗਲਤ ਕੋਡ ’ਤੇ ਇਹ ਲੌਕ ਹੋ ਜਾਂਦਾ ਹੈ ਅਤੇ ਸਾਡੀ ਟੀਮ ਰਾਈਡਰ ਦੀ ਮਦਦ ਕਰਦੀ ਹੈ।"
    },
    "keywords": [
      "code",
      "otp",
      "pin",
      "delivery code",
      "handover",
      "verify"
    ],
    "related": [
      "rider_contact",
      "failed_delivery"
    ]
  },
  {
    "id": "failed_delivery",
    "action": "none",
    "title": {
      "en": "I missed my delivery",
      "bn": "ডেলিভারি মিস হয়েছে",
      "hi": "मेरी डिलीवरी छूट गई",
      "pa": "ਮੇਰੀ ਡਿਲੀਵਰੀ ਖੁੰਝ ਗਈ"
    },
    "questions": {
      "en": [
        "I wasn't home when the rider came",
        "Rider could not deliver my order",
        "rider says customer not reachable",
        "missed delivery",
        "rider went back with my order",
        "wrong address rider can not find"
      ],
      "bn": [
        "রাইডার এসে ফিরে গেছে",
        "বাড়িতে ছিলাম না"
      ],
      "hi": [
        "राइडर आकर वापस चला गया",
        "मैं घर पर नहीं था"
      ],
      "pa": [
        "ਰਾਈਡਰ ਆ ਕੇ ਵਾਪਸ ਚਲਾ ਗਿਆ",
        "ਮੈਂ ਘਰ ਨਹੀਂ ਸੀ"
      ]
    },
    "answers": {
      "en": "If the rider can’t hand over your Zyppi order, they first wait at your door for a few minutes and call you. If you still can’t be reached, or the address can’t be found, our team decides the next step with you. If the order has to go back to the store, it is cancelled and anything you paid online or from your wallet is refunded. Tap “Talk to a person” to sort it out quickly.",
      "bn": "রাইডার আপনার Zyppi অর্ডার দিতে না পারলে প্রথমে কয়েক মিনিট দরজায় অপেক্ষা করে আপনাকে ফোন করেন। তবুও যোগাযোগ না হলে বা ঠিকানা না পেলে আমাদের টিম আপনার সঙ্গে পরের ধাপ ঠিক করে। অর্ডার দোকানে ফেরত গেলে বাতিল হয় এবং অনলাইনে বা ওয়ালেট থেকে দেওয়া টাকা ফেরত হয়। দ্রুত মেটাতে “কারও সঙ্গে কথা বলুন” ট্যাপ করুন।",
      "hi": "अगर राइडर आपका Zyppi ऑर्डर नहीं दे पाता, तो वह पहले कुछ मिनट दरवाज़े पर रुककर आपको कॉल करता है। फिर भी बात न हो या पता न मिले, तो हमारी टीम आपके साथ आगे का फ़ैसला करती है। अगर ऑर्डर दुकान पर वापस जाता है, तो वह कैंसिल हो जाता है और ऑनलाइन या वॉलेट से दिए पैसे वापस हो जाते हैं। जल्दी सुलझाने के लिए “किसी से बात करें” पर टैप करें।",
      "pa": "ਜੇ ਰਾਈਡਰ ਤੁਹਾਡਾ Zyppi ਆਰਡਰ ਨਹੀਂ ਦੇ ਪਾਉਂਦਾ, ਤਾਂ ਉਹ ਪਹਿਲਾਂ ਕੁਝ ਮਿੰਟ ਦਰਵਾਜ਼ੇ ’ਤੇ ਰੁਕ ਕੇ ਤੁਹਾਨੂੰ ਕਾਲ ਕਰਦਾ ਹੈ। ਫਿਰ ਵੀ ਗੱਲ ਨਾ ਹੋਵੇ ਜਾਂ ਪਤਾ ਨਾ ਮਿਲੇ, ਤਾਂ ਸਾਡੀ ਟੀਮ ਤੁਹਾਡੇ ਨਾਲ ਅਗਲਾ ਫ਼ੈਸਲਾ ਕਰਦੀ ਹੈ। ਜੇ ਆਰਡਰ ਦੁਕਾਨ ’ਤੇ ਵਾਪਸ ਜਾਂਦਾ ਹੈ, ਤਾਂ ਉਹ ਰੱਦ ਹੋ ਜਾਂਦਾ ਹੈ ਅਤੇ ਔਨਲਾਈਨ ਜਾਂ ਵਾਲਿਟ ਤੋਂ ਦਿੱਤੇ ਪੈਸੇ ਵਾਪਸ ਹੋ ਜਾਂਦੇ ਹਨ। ਜਲਦੀ ਸੁਲਝਾਉਣ ਲਈ “ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ” ’ਤੇ ਟੈਪ ਕਰੋ।"
    },
    "keywords": [
      "missed",
      "not home",
      "unreachable",
      "failed",
      "returned",
      "wrong address"
    ],
    "related": [
      "talk_to_person",
      "change_address"
    ]
  },
  {
    "id": "order_cancelled_by_us",
    "action": "none",
    "title": {
      "en": "Why was my order cancelled?",
      "bn": "অর্ডার কেন বাতিল হল?",
      "hi": "मेरा ऑर्डर कैंसिल क्यों हुआ?",
      "pa": "ਮੇਰਾ ਆਰਡਰ ਰੱਦ ਕਿਉਂ ਹੋਇਆ?"
    },
    "questions": {
      "en": [
        "Why was my order cancelled?",
        "I didn't cancel but my order got cancelled",
        "store rejected my order",
        "seller cancelled my order",
        "order cancel ho gaya apne aap",
        "got order cancelled notification"
      ],
      "bn": [
        "আমার অর্ডার কেন বাতিল হল?",
        "আমি বাতিল করিনি, তবু বাতিল হয়েছে"
      ],
      "hi": [
        "मेरा ऑर्डर कैंसिल क्यों हुआ?",
        "मैंने कैंसिल नहीं किया फिर भी हो गया"
      ],
      "pa": [
        "ਮੇਰਾ ਆਰਡਰ ਰੱਦ ਕਿਉਂ ਹੋਇਆ?",
        "ਮੈਂ ਰੱਦ ਨਹੀਂ ਕੀਤਾ ਫਿਰ ਵੀ ਹੋ ਗਿਆ"
      ]
    },
    "answers": {
      "en": "Sometimes a Zyppi order is cancelled for you — for example when the store or seller can’t fulfil it (an item ran out, or the shop is closing), when no seller accepts it in time, or when delivery fails and the order goes back to the store. You get an “Order cancelled” notification. Online payments are refunded to the original payment method, wallet money returns to your wallet, and cash orders aren’t charged. You can place the order again.",
      "bn": "কখনও কখনও Zyppi অর্ডার আপনার হয়ে বাতিল হয় — যেমন দোকান বা বিক্রেতা দিতে না পারলে (জিনিস শেষ, বা দোকান বন্ধ হচ্ছে), সময়মতো কোনো বিক্রেতা অর্ডার না নিলে, বা ডেলিভারি না হয়ে অর্ডার দোকানে ফিরলে। আপনি “অর্ডার বাতিল” নোটিফিকেশন পাবেন। অনলাইন পেমেন্ট আগের মাধ্যমে ফেরত যায়, ওয়ালেটের টাকা ওয়ালেটে ফেরে, ক্যাশ অর্ডারে টাকা লাগে না। আবার অর্ডার করতে পারেন।",
      "hi": "कभी-कभी Zyppi ऑर्डर अपने-आप कैंसिल होता है — जैसे जब दुकान या सेलर उसे पूरा नहीं कर पाता (सामान खत्म, या दुकान बंद हो रही है), कोई सेलर समय पर ऑर्डर स्वीकार नहीं करता, या डिलीवरी न होकर ऑर्डर दुकान लौट जाता है। आपको “ऑर्डर कैंसिल” नोटिफ़िकेशन मिलता है। ऑनलाइन पेमेंट उसी तरीके में वापस जाता है, वॉलेट का पैसा वॉलेट में लौटता है, और कैश ऑर्डर पर कोई चार्ज नहीं लगता। आप दोबारा ऑर्डर कर सकते हैं।",
      "pa": "ਕਈ ਵਾਰ Zyppi ਆਰਡਰ ਆਪਣੇ-ਆਪ ਰੱਦ ਹੁੰਦਾ ਹੈ — ਜਿਵੇਂ ਜਦੋਂ ਦੁਕਾਨ ਜਾਂ ਸੇਲਰ ਇਸਨੂੰ ਪੂਰਾ ਨਹੀਂ ਕਰ ਪਾਉਂਦਾ (ਸਾਮਾਨ ਖ਼ਤਮ, ਜਾਂ ਦੁਕਾਨ ਬੰਦ ਹੋ ਰਹੀ ਹੈ), ਕੋਈ ਸੇਲਰ ਸਮੇਂ ਸਿਰ ਆਰਡਰ ਨਹੀਂ ਲੈਂਦਾ, ਜਾਂ ਡਿਲੀਵਰੀ ਨਾ ਹੋ ਕੇ ਆਰਡਰ ਦੁਕਾਨ ’ਤੇ ਵਾਪਸ ਜਾਂਦਾ ਹੈ। ਤੁਹਾਨੂੰ “ਆਰਡਰ ਰੱਦ” ਨੋਟੀਫ਼ਿਕੇਸ਼ਨ ਮਿਲਦਾ ਹੈ। ਔਨਲਾਈਨ ਭੁਗਤਾਨ ਉਸੇ ਤਰੀਕੇ ਵਿੱਚ ਵਾਪਸ ਜਾਂਦਾ ਹੈ, ਵਾਲਿਟ ਦੇ ਪੈਸੇ ਵਾਲਿਟ ਵਿੱਚ ਮੁੜਦੇ ਹਨ, ਅਤੇ ਕੈਸ਼ ਆਰਡਰ ’ਤੇ ਕੋਈ ਚਾਰਜ ਨਹੀਂ। ਤੁਸੀਂ ਦੁਬਾਰਾ ਆਰਡਰ ਕਰ ਸਕਦੇ ਹੋ।"
    },
    "keywords": [
      "rejected",
      "seller",
      "store",
      "auto cancel",
      "cancelled"
    ],
    "related": [
      "refund",
      "talk_to_person"
    ]
  },
  {
    "id": "cancel_order",
    "action": "none",
    "title": {
      "en": "Cancel my order",
      "bn": "অর্ডার বাতিল",
      "hi": "ऑर्डर कैंसिल करें",
      "pa": "ਆਰਡਰ ਰੱਦ ਕਰੋ"
    },
    "questions": {
      "en": [
        "I want to cancel my order",
        "How do I cancel an order?",
        "Cancel order",
        "order cancel karna hai",
        "cancle my order",
        "cancel kaise kare",
        "stop my order",
        "ordered by mistake"
      ],
      "bn": [
        "আমি অর্ডার বাতিল করতে চাই",
        "অর্ডার কীভাবে বাতিল করব?",
        "ভুল করে অর্ডার দিয়েছি"
      ],
      "hi": [
        "मुझे ऑर्डर कैंसिल करना है",
        "ऑर्डर कैसे कैंसिल करें?",
        "गलती से ऑर्डर हो गया"
      ],
      "pa": [
        "ਮੈਂ ਆਰਡਰ ਰੱਦ ਕਰਨਾ ਚਾਹੁੰਦਾ ਹਾਂ",
        "ਆਰਡਰ ਕਿਵੇਂ ਰੱਦ ਕਰੀਏ?",
        "ਗਲਤੀ ਨਾਲ ਆਰਡਰ ਹੋ ਗਿਆ"
      ]
    },
    "answers": {
      "en": "You can cancel a Zyppi order yourself while it still says “Order placed”: open the order, tap “Cancel order” and pick a reason. Once the store has packed it, it can’t be cancelled in the app — tap “Talk to a person” and our team will help. Wallet money goes back to your wallet; online payments are refunded to the original payment method. Cash-on-delivery orders aren’t charged.",
      "bn": "আপনার Zyppi অর্ডারে “অর্ডার হয়েছে” লেখা থাকা পর্যন্ত নিজেই বাতিল করতে পারেন: অর্ডার খুলে “অর্ডার বাতিল করুন” ট্যাপ করে কারণ বাছুন। দোকান প্যাক করে ফেললে অ্যাপ থেকে আর বাতিল করা যায় না — “কারও সঙ্গে কথা বলুন” ট্যাপ করুন, আমাদের টিম সাহায্য করবে। ওয়ালেটের টাকা ওয়ালেটে ফেরে; অনলাইন পেমেন্ট আগের মাধ্যমে ফেরত যায়। ক্যাশ অন ডেলিভারিতে টাকা লাগে না।",
      "hi": "जब तक आपके Zyppi ऑर्डर पर “ऑर्डर हो गया” लिखा है, आप खुद कैंसिल कर सकते हैं: ऑर्डर खोलें, “ऑर्डर कैंसिल करें” पर टैप करें और कारण चुनें। दुकान ने पैक कर दिया तो ऐप से कैंसिल नहीं होगा — “किसी से बात करें” पर टैप करें, हमारी टीम मदद करेगी। वॉलेट का पैसा वॉलेट में लौटता है; ऑनलाइन पेमेंट उसी तरीके में रिफ़ंड होता है। कैश ऑन डिलीवरी पर कोई चार्ज नहीं लगता।",
      "pa": "ਜਦੋਂ ਤੱਕ ਤੁਹਾਡੇ Zyppi ਆਰਡਰ ’ਤੇ “ਆਰਡਰ ਹੋ ਗਿਆ” ਲਿਖਿਆ ਹੈ, ਤੁਸੀਂ ਖੁਦ ਰੱਦ ਕਰ ਸਕਦੇ ਹੋ: ਆਰਡਰ ਖੋਲ੍ਹੋ, “ਆਰਡਰ ਰੱਦ ਕਰੋ” ’ਤੇ ਟੈਪ ਕਰੋ ਅਤੇ ਕਾਰਨ ਚੁਣੋ। ਦੁਕਾਨ ਨੇ ਪੈਕ ਕਰ ਦਿੱਤਾ ਤਾਂ ਐਪ ਤੋਂ ਰੱਦ ਨਹੀਂ ਹੋਵੇਗਾ — “ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ” ’ਤੇ ਟੈਪ ਕਰੋ, ਸਾਡੀ ਟੀਮ ਮਦਦ ਕਰੇਗੀ। ਵਾਲਿਟ ਦੇ ਪੈਸੇ ਵਾਲਿਟ ਵਿੱਚ ਮੁੜਦੇ ਹਨ; ਔਨਲਾਈਨ ਭੁਗਤਾਨ ਉਸੇ ਤਰੀਕੇ ਵਿੱਚ ਰਿਫ਼ੰਡ ਹੁੰਦਾ ਹੈ। ਕੈਸ਼ ਆਨ ਡਿਲੀਵਰੀ ’ਤੇ ਕੋਈ ਚਾਰਜ ਨਹੀਂ।"
    },
    "keywords": [
      "cancel",
      "cancellation",
      "cancle",
      "cansel",
      "stop",
      "mistake"
    ],
    "related": [
      "refund",
      "talk_to_person"
    ]
  },
  {
    "id": "refund",
    "action": "none",
    "title": {
      "en": "Refunds",
      "bn": "টাকা ফেরত",
      "hi": "रिफ़ंड",
      "pa": "ਰਿਫ਼ੰਡ"
    },
    "questions": {
      "en": [
        "When will I get my refund?",
        "I want a refund",
        "How do refunds work?",
        "refund kab milega",
        "money back",
        "paisa wapas",
        "refund not received",
        "refnd status",
        "taka ferot",
        "paise kab wapas aayenge"
      ],
      "bn": [
        "টাকা ফেরত কবে পাব?",
        "আমি টাকা ফেরত চাই",
        "রিফান্ড এখনও আসেনি",
        "আমার টাকা ফেরত দিন"
      ],
      "hi": [
        "रिफ़ंड कब मिलेगा?",
        "मुझे रिफ़ंड चाहिए",
        "रिफ़ंड अभी तक नहीं आया",
        "मुझे पैसे वापस चाहिए"
      ],
      "pa": [
        "ਰਿਫ਼ੰਡ ਕਦੋਂ ਮਿਲੇਗਾ?",
        "ਮੈਨੂੰ ਰਿਫ਼ੰਡ ਚਾਹੀਦਾ ਹੈ",
        "ਰਿਫ਼ੰਡ ਅਜੇ ਤੱਕ ਨਹੀਂ ਆਇਆ",
        "ਮੈਨੂੰ ਪੈਸੇ ਵਾਪਸ ਚਾਹੀਦੇ",
        "ਪੈਸੇ ਵਾਪਸ ਕਦੋਂ ਮਿਲਣਗੇ"
      ]
    },
    "answers": {
      "en": "Zyppi refunds go back the way you paid. Refunds to your Zyppi wallet arrive instantly. Refunds to UPI or card take 5–7 working days after approval. Cash-on-delivery orders are never charged before delivery, so a cancelled cash order needs no refund; for a problem reported on a delivered cash order, the refund goes to your wallet. If a refund is late, tap “Talk to a person”.",
      "bn": "Zyppi-র টাকা যে মাধ্যমে দিয়েছিলেন সেখানেই ফেরত যায়। Zyppi ওয়ালেটে রিফান্ড সঙ্গে সঙ্গে আসে। UPI বা কার্ডে রিফান্ড অনুমোদনের পর ৫–৭ কার্যদিবস লাগে। ক্যাশ অন ডেলিভারিতে ডেলিভারির আগে টাকা লাগে না, তাই বাতিল ক্যাশ অর্ডারে রিফান্ড লাগে না; ডেলিভারি হওয়া ক্যাশ অর্ডারে সমস্যা জানালে টাকা ওয়ালেটে আসে। রিফান্ড দেরি হলে “কারও সঙ্গে কথা বলুন” ট্যাপ করুন।",
      "hi": "Zyppi रिफ़ंड उसी तरीके में वापस जाता है जिससे आपने पेमेंट किया। Zyppi वॉलेट में रिफ़ंड तुरंत आता है। UPI या कार्ड में रिफ़ंड मंज़ूरी के बाद 5–7 कार्यदिवस लेता है। कैश ऑन डिलीवरी में डिलीवरी से पहले पैसे नहीं लगते, इसलिए कैंसिल कैश ऑर्डर पर रिफ़ंड की ज़रूरत नहीं; डिलीवर हुए कैश ऑर्डर में समस्या बताने पर पैसा वॉलेट में आता है। रिफ़ंड में देर हो तो “किसी से बात करें” पर टैप करें।",
      "pa": "Zyppi ਰਿਫ਼ੰਡ ਉਸੇ ਤਰੀਕੇ ਵਿੱਚ ਵਾਪਸ ਜਾਂਦਾ ਹੈ ਜਿਸ ਨਾਲ ਤੁਸੀਂ ਭੁਗਤਾਨ ਕੀਤਾ। Zyppi ਵਾਲਿਟ ਵਿੱਚ ਰਿਫ਼ੰਡ ਤੁਰੰਤ ਆਉਂਦਾ ਹੈ। UPI ਜਾਂ ਕਾਰਡ ਵਿੱਚ ਰਿਫ਼ੰਡ ਮਨਜ਼ੂਰੀ ਤੋਂ ਬਾਅਦ 5–7 ਕੰਮਕਾਜੀ ਦਿਨ ਲੈਂਦਾ ਹੈ। ਕੈਸ਼ ਆਨ ਡਿਲੀਵਰੀ ਵਿੱਚ ਡਿਲੀਵਰੀ ਤੋਂ ਪਹਿਲਾਂ ਪੈਸੇ ਨਹੀਂ ਲੱਗਦੇ, ਇਸ ਲਈ ਰੱਦ ਕੈਸ਼ ਆਰਡਰ ’ਤੇ ਰਿਫ਼ੰਡ ਦੀ ਲੋੜ ਨਹੀਂ; ਡਿਲੀਵਰ ਹੋਏ ਕੈਸ਼ ਆਰਡਰ ਵਿੱਚ ਸਮੱਸਿਆ ਦੱਸਣ ’ਤੇ ਪੈਸਾ ਵਾਲਿਟ ਵਿੱਚ ਆਉਂਦਾ ਹੈ। ਰਿਫ਼ੰਡ ਵਿੱਚ ਦੇਰ ਹੋਵੇ ਤਾਂ “ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ” ’ਤੇ ਟੈਪ ਕਰੋ।"
    },
    "keywords": [
      "refund",
      "money back",
      "paisa",
      "wapas",
      "refnd",
      "credited"
    ],
    "related": [
      "wallet",
      "missing_item",
      "talk_to_person"
    ]
  },
  {
    "id": "missing_item",
    "action": "return_flow",
    "title": {
      "en": "Missing or wrong item",
      "bn": "জিনিস কম বা ভুল",
      "hi": "सामान कम या गलत",
      "pa": "ਸਾਮਾਨ ਘੱਟ ਜਾਂ ਗਲਤ"
    },
    "questions": {
      "en": [
        "An item is missing from my order",
        "I received the wrong item",
        "The product was damaged",
        "Item is expired or bad quality",
        "report a problem",
        "return an item",
        "item kam aaya",
        "saman kharab hai",
        "broken packet",
        "replace my item",
        "got a different brand or size",
        "I want to return an item",
        "rotten vegetables",
        "less quantity received",
        "weight is less",
        "I got someone else's order",
        "packet was open or torn",
        "food is stale"
      ],
      "bn": [
        "অর্ডারে একটা জিনিস নেই",
        "ভুল জিনিস এসেছে",
        "জিনিস নষ্ট ছিল"
      ],
      "hi": [
        "ऑर्डर में एक सामान नहीं आया",
        "गलत सामान आया है",
        "सामान खराब निकला"
      ],
      "pa": [
        "ਆਰਡਰ ਵਿੱਚ ਇੱਕ ਸਾਮਾਨ ਨਹੀਂ ਆਇਆ",
        "ਗਲਤ ਸਾਮਾਨ ਆਇਆ ਹੈ",
        "ਸਾਮਾਨ ਖ਼ਰਾਬ ਨਿਕਲਿਆ"
      ]
    },
    "answers": {
      "en": "Sorry about that! You can report missing, wrong, damaged or expired items for 2 hours after delivery. Tap \"Start a return\" to tell me which item and what went wrong (add up to 3 photos). For wrong, damaged or expired items a rider collects it, and your refund goes out as soon as the store receives it. Missing items and bigger claims are checked by our team. You can choose a wallet refund, a refund to UPI/card, or a free replacement.",
      "bn": "এর জন্য দুঃখিত! ডেলিভারির পর ২ ঘণ্টা পর্যন্ত না আসা, ভুল, নষ্ট বা মেয়াদোত্তীর্ণ জিনিসের কথা জানাতে পারেন। কোন জিনিস আর কী সমস্যা, জানাতে \"রিটার্ন শুরু করুন\" ট্যাপ করুন (৩টি পর্যন্ত ছবি দিন)। ভুল, নষ্ট বা মেয়াদোত্তীর্ণ জিনিস রাইডার নিয়ে যাবেন, দোকানে পৌঁছালেই রিফান্ড হবে। না আসা জিনিস ও বড় দাবি আমাদের টিম দেখবে। ওয়ালেটে রিফান্ড, UPI/কার্ডে রিফান্ড বা বিনা খরচে বদলি — যেকোনোটি বাছতে পারেন।",
      "hi": "इसके लिए माफ़ी! डिलीवरी के 2 घंटे तक आप न आए, गलत, खराब या एक्सपायर्ड सामान की शिकायत कर सकते हैं। कौन-सा सामान और क्या दिक्कत है, बताने के लिए \"रिटर्न शुरू करें\" पर टैप करें (3 तक फ़ोटो जोड़ें)। गलत, खराब या एक्सपायर्ड सामान राइडर ले जाएगा और दुकान पहुँचते ही रिफ़ंड हो जाएगा। न आए सामान और बड़े दावों की जाँच हमारी टीम करेगी। आप वॉलेट रिफ़ंड, UPI/कार्ड में रिफ़ंड या मुफ़्त बदलाव चुन सकते हैं।",
      "pa": "ਇਸ ਲਈ ਮਾਫ਼ੀ! ਡਿਲੀਵਰੀ ਤੋਂ 2 ਘੰਟੇ ਤੱਕ ਤੁਸੀਂ ਨਾ ਆਏ, ਗਲਤ, ਖ਼ਰਾਬ ਜਾਂ ਮਿਆਦ ਪੁੱਗੇ ਸਾਮਾਨ ਦੀ ਸ਼ਿਕਾਇਤ ਕਰ ਸਕਦੇ ਹੋ। ਕਿਹੜਾ ਸਾਮਾਨ ਅਤੇ ਕੀ ਗੜਬੜ ਹੈ, ਦੱਸਣ ਲਈ \"ਰਿਟਰਨ ਸ਼ੁਰੂ ਕਰੋ\" ’ਤੇ ਟੈਪ ਕਰੋ (3 ਤੱਕ ਫ਼ੋਟੋ ਜੋੜੋ)। ਗਲਤ, ਖ਼ਰਾਬ ਜਾਂ ਮਿਆਦ ਪੁੱਗਿਆ ਸਾਮਾਨ ਰਾਈਡਰ ਲੈ ਜਾਵੇਗਾ ਅਤੇ ਦੁਕਾਨ ਪਹੁੰਚਦੇ ਹੀ ਰਿਫ਼ੰਡ ਹੋ ਜਾਵੇਗਾ। ਨਾ ਆਏ ਸਾਮਾਨ ਅਤੇ ਵੱਡੇ ਦਾਅਵਿਆਂ ਦੀ ਜਾਂਚ ਸਾਡੀ ਟੀਮ ਕਰੇਗੀ। ਤੁਸੀਂ ਵਾਲਿਟ ਰਿਫ਼ੰਡ, UPI/ਕਾਰਡ ਵਿੱਚ ਰਿਫ਼ੰਡ ਜਾਂ ਮੁਫ਼ਤ ਬਦਲੀ ਚੁਣ ਸਕਦੇ ਹੋ।"
    },
    "keywords": [
      "missing",
      "wrong",
      "damaged",
      "broken",
      "expired",
      "spoiled",
      "quality",
      "return",
      "replace",
      "leak"
    ],
    "related": [
      "refund",
      "report_too_late"
    ]
  },
  {
    "id": "report_too_late",
    "action": "handoff",
    "title": {
      "en": "Can't report a problem",
      "bn": "সমস্যা জানাতে পারছি না",
      "hi": "शिकायत नहीं कर पा रहा",
      "pa": "ਸ਼ਿਕਾਇਤ ਨਹੀਂ ਕਰ ਪਾ ਰਿਹਾ"
    },
    "questions": {
      "en": [
        "I can't report a problem on my order",
        "Report a problem button not showing",
        "it says problems can be reported up to 2 hours after delivery",
        "I already have a report under review",
        "my report was not approved"
      ],
      "bn": [
        "সমস্যা জানানোর বোতাম নেই",
        "আমার রিপোর্ট বাতিল হয়েছে"
      ],
      "hi": [
        "शिकायत का बटन नहीं दिख रहा",
        "मेरी रिपोर्ट मंज़ूर नहीं हुई"
      ],
      "pa": [
        "ਸ਼ਿਕਾਇਤ ਦਾ ਬਟਨ ਨਹੀਂ ਦਿਖ ਰਿਹਾ",
        "ਮੇਰੀ ਰਿਪੋਰਟ ਮਨਜ਼ੂਰ ਨਹੀਂ ਹੋਈ"
      ]
    },
    "answers": {
      "en": "In the Zyppi app, “Report a problem” works for 2 hours after delivery, and only one report per order can be under review at a time. If that time has passed, your report wasn’t approved, or you’ve already reported every unit of an item, our team can still look at it. I’m connecting you to them now.",
      "bn": "Zyppi অ্যাপে “সমস্যা জানান” ডেলিভারির পর ২ ঘণ্টা কাজ করে, আর একটি অর্ডারে একসঙ্গে একটিই রিপোর্ট দেখা হয়। সময় পেরিয়ে গেলে, রিপোর্ট অনুমোদিত না হলে, বা একটি জিনিসের সব ইউনিট আগেই জানিয়ে থাকলেও আমাদের টিম দেখতে পারে। এখনই আপনাকে তাদের সঙ্গে যুক্ত করছি।",
      "hi": "Zyppi ऐप में “समस्या बताएँ” डिलीवरी के 2 घंटे तक काम करता है, और एक ऑर्डर पर एक समय में एक ही रिपोर्ट की जाँच होती है। अगर समय निकल गया, रिपोर्ट मंज़ूर नहीं हुई, या किसी सामान की सारी यूनिट पहले ही बता चुके हैं, तब भी हमारी टीम देख सकती है। मैं अभी आपको उनसे जोड़ रहा हूँ।",
      "pa": "Zyppi ਐਪ ਵਿੱਚ “ਸਮੱਸਿਆ ਦੱਸੋ” ਡਿਲੀਵਰੀ ਤੋਂ 2 ਘੰਟੇ ਤੱਕ ਕੰਮ ਕਰਦਾ ਹੈ, ਅਤੇ ਇੱਕ ਆਰਡਰ ’ਤੇ ਇੱਕ ਸਮੇਂ ਇੱਕ ਹੀ ਰਿਪੋਰਟ ਦੀ ਜਾਂਚ ਹੁੰਦੀ ਹੈ। ਜੇ ਸਮਾਂ ਲੰਘ ਗਿਆ, ਰਿਪੋਰਟ ਮਨਜ਼ੂਰ ਨਹੀਂ ਹੋਈ, ਜਾਂ ਕਿਸੇ ਸਾਮਾਨ ਦੀਆਂ ਸਾਰੀਆਂ ਯੂਨਿਟਾਂ ਪਹਿਲਾਂ ਹੀ ਦੱਸ ਚੁੱਕੇ ਹੋ, ਤਾਂ ਵੀ ਸਾਡੀ ਟੀਮ ਦੇਖ ਸਕਦੀ ਹੈ। ਮੈਂ ਹੁਣੇ ਤੁਹਾਨੂੰ ਉਨ੍ਹਾਂ ਨਾਲ ਜੋੜ ਰਿਹਾ ਹਾਂ।"
    },
    "keywords": [
      "report",
      "claim",
      "under review",
      "rejected",
      "window",
      "2 hours"
    ]
  },
  {
    "id": "payment_methods",
    "action": "none",
    "title": {
      "en": "Payment options",
      "bn": "পেমেন্টের উপায়",
      "hi": "पेमेंट के तरीके",
      "pa": "ਭੁਗਤਾਨ ਦੇ ਤਰੀਕੇ"
    },
    "questions": {
      "en": [
        "How can I pay?",
        "Can I pay by UPI?",
        "Which payment methods are available?",
        "Can I pay with a card?",
        "gpay phonepe chalega",
        "payment option not showing"
      ],
      "bn": [
        "কীভাবে পেমেন্ট করব?",
        "UPI দিয়ে দেওয়া যাবে?"
      ],
      "hi": [
        "मैं कैसे पेमेंट करूँ?",
        "क्या UPI से पेमेंट कर सकते हैं?"
      ],
      "pa": [
        "ਮੈਂ ਭੁਗਤਾਨ ਕਿਵੇਂ ਕਰਾਂ?",
        "ਕੀ UPI ਨਾਲ ਭੁਗਤਾਨ ਹੋ ਸਕਦਾ ਹੈ?"
      ]
    },
    "answers": {
      "en": "On Zyppi you can pay cash on delivery, or online with UPI (GPay, PhonePe, Paytm or any UPI app) or a credit/debit card through PayU’s secure checkout. We never store card details. You can also use your Zyppi wallet balance, on its own or together with another method. If a method says it is unavailable right now, please choose another.",
      "bn": "Zyppi-তে ক্যাশ অন ডেলিভারি, অথবা PayU-র নিরাপদ চেকআউটে UPI (GPay, PhonePe, Paytm বা যেকোনো UPI অ্যাপ) বা ক্রেডিট/ডেবিট কার্ড দিয়ে অনলাইনে পেমেন্ট করতে পারেন। আমরা কার্ডের তথ্য কখনও রাখি না। Zyppi ওয়ালেটের টাকাও একা বা অন্য উপায়ের সঙ্গে ব্যবহার করতে পারেন। কোনো উপায় এখন বন্ধ দেখালে অন্যটি বাছুন।",
      "hi": "Zyppi पर आप कैश ऑन डिलीवरी से, या PayU के सुरक्षित चेकआउट पर UPI (GPay, PhonePe, Paytm या कोई भी UPI ऐप) या क्रेडिट/डेबिट कार्ड से ऑनलाइन पेमेंट कर सकते हैं। हम कार्ड की जानकारी कभी सेव नहीं करते। Zyppi वॉलेट का बैलेंस भी अकेले या किसी और तरीके के साथ इस्तेमाल कर सकते हैं। कोई तरीका अभी उपलब्ध न हो तो दूसरा चुनें।",
      "pa": "Zyppi ’ਤੇ ਤੁਸੀਂ ਕੈਸ਼ ਆਨ ਡਿਲੀਵਰੀ ਨਾਲ, ਜਾਂ PayU ਦੇ ਸੁਰੱਖਿਅਤ ਚੈੱਕਆਊਟ ’ਤੇ UPI (GPay, PhonePe, Paytm ਜਾਂ ਕੋਈ ਵੀ UPI ਐਪ) ਜਾਂ ਕ੍ਰੈਡਿਟ/ਡੈਬਿਟ ਕਾਰਡ ਨਾਲ ਔਨਲਾਈਨ ਭੁਗਤਾਨ ਕਰ ਸਕਦੇ ਹੋ। ਅਸੀਂ ਕਾਰਡ ਦੀ ਜਾਣਕਾਰੀ ਕਦੇ ਸੇਵ ਨਹੀਂ ਕਰਦੇ। Zyppi ਵਾਲਿਟ ਦਾ ਬੈਲੇਂਸ ਵੀ ਇਕੱਲਾ ਜਾਂ ਕਿਸੇ ਹੋਰ ਤਰੀਕੇ ਨਾਲ ਵਰਤ ਸਕਦੇ ਹੋ। ਕੋਈ ਤਰੀਕਾ ਹੁਣ ਉਪਲਬਧ ਨਾ ਹੋਵੇ ਤਾਂ ਦੂਜਾ ਚੁਣੋ।"
    },
    "keywords": [
      "upi",
      "payu",
      "phonepe",
      "gpay",
      "paytm",
      "card",
      "debit",
      "credit",
      "pay"
    ],
    "related": [
      "cod",
      "wallet",
      "payment_failed"
    ]
  },
  {
    "id": "cod",
    "action": "none",
    "title": {
      "en": "Cash on delivery",
      "bn": "ক্যাশ অন ডেলিভারি",
      "hi": "कैश ऑन डिलीवरी",
      "pa": "ਕੈਸ਼ ਆਨ ਡਿਲੀਵਰੀ"
    },
    "questions": {
      "en": [
        "Do you accept cash on delivery?",
        "Is COD available?",
        "Can I pay the rider in cash?",
        "cash on delivery",
        "cod hai kya",
        "pay at door",
        "can I pay UPI to the rider"
      ],
      "bn": [
        "ক্যাশ অন ডেলিভারি আছে?",
        "রাইডারকে নগদ দেওয়া যাবে?",
        "নগদে পেমেন্ট করা যাবে?"
      ],
      "hi": [
        "क्या कैश ऑन डिलीवरी है?",
        "राइडर को कैश दे सकते हैं?",
        "क्या कैश में पेमेंट कर सकते हैं?"
      ],
      "pa": [
        "ਕੀ ਕੈਸ਼ ਆਨ ਡਿਲੀਵਰੀ ਹੈ?",
        "ਰਾਈਡਰ ਨੂੰ ਕੈਸ਼ ਦੇ ਸਕਦੇ ਹਾਂ?",
        "ਕੀ ਕੈਸ਼ ਵਿੱਚ ਭੁਗਤਾਨ ਕਰ ਸਕਦੇ ਹਾਂ?"
      ]
    },
    "answers": {
      "en": "Yes — choose “Cash on delivery” at Zyppi checkout and pay at your door. You aren’t charged anything until the order is delivered, so cancelling a cash order costs nothing. Please keep the amount ready for the rider. If you report a problem with a cash order after delivery, the refund goes to your Zyppi wallet.",
      "bn": "হ্যাঁ — Zyppi চেকআউটে “ক্যাশ অন ডেলিভারি” বেছে দরজায় টাকা দিন। ডেলিভারির আগে কোনো টাকা লাগে না, তাই ক্যাশ অর্ডার বাতিলে কোনো খরচ নেই। রাইডারের জন্য টাকা তৈরি রাখুন। ডেলিভারির পর ক্যাশ অর্ডারে সমস্যা জানালে রিফান্ড Zyppi ওয়ালেটে আসে।",
      "hi": "हाँ — Zyppi चेकआउट पर “कैश ऑन डिलीवरी” चुनें और दरवाज़े पर पेमेंट करें। डिलीवरी से पहले कोई पैसा नहीं लगता, इसलिए कैश ऑर्डर कैंसिल करने पर कोई खर्च नहीं। राइडर के लिए पैसे तैयार रखें। डिलीवरी के बाद कैश ऑर्डर में समस्या बताने पर रिफ़ंड Zyppi वॉलेट में आता है।",
      "pa": "ਹਾਂ — Zyppi ਚੈੱਕਆਊਟ ’ਤੇ “ਕੈਸ਼ ਆਨ ਡਿਲੀਵਰੀ” ਚੁਣੋ ਅਤੇ ਦਰਵਾਜ਼ੇ ’ਤੇ ਭੁਗਤਾਨ ਕਰੋ। ਡਿਲੀਵਰੀ ਤੋਂ ਪਹਿਲਾਂ ਕੋਈ ਪੈਸਾ ਨਹੀਂ ਲੱਗਦਾ, ਇਸ ਲਈ ਕੈਸ਼ ਆਰਡਰ ਰੱਦ ਕਰਨ ’ਤੇ ਕੋਈ ਖ਼ਰਚਾ ਨਹੀਂ। ਰਾਈਡਰ ਲਈ ਪੈਸੇ ਤਿਆਰ ਰੱਖੋ। ਡਿਲੀਵਰੀ ਤੋਂ ਬਾਅਦ ਕੈਸ਼ ਆਰਡਰ ਵਿੱਚ ਸਮੱਸਿਆ ਦੱਸਣ ’ਤੇ ਰਿਫ਼ੰਡ Zyppi ਵਾਲਿਟ ਵਿੱਚ ਆਉਂਦਾ ਹੈ।"
    },
    "keywords": [
      "cod",
      "cash",
      "nagad",
      "cash on delivery",
      "pay later"
    ],
    "related": [
      "payment_methods",
      "wallet"
    ]
  },
  {
    "id": "payment_failed",
    "action": "handoff",
    "title": {
      "en": "Payment problem",
      "bn": "পেমেন্টে সমস্যা",
      "hi": "पेमेंट में समस्या",
      "pa": "ਭੁਗਤਾਨ ਵਿੱਚ ਸਮੱਸਿਆ"
    },
    "questions": {
      "en": [
        "Money was deducted but the order wasn't placed",
        "My payment failed",
        "I paid but didn't get a confirmation",
        "paisa kat gaya order nahi hua",
        "amount debited order failed",
        "double payment",
        "charged twice"
      ],
      "bn": [
        "টাকা কেটে গেছে কিন্তু অর্ডার হয়নি",
        "পেমেন্ট ফেল হয়েছে"
      ],
      "hi": [
        "पैसे कट गए लेकिन ऑर्डर नहीं हुआ",
        "मेरा पेमेंट फेल हो गया"
      ],
      "pa": [
        "ਪੈਸੇ ਕੱਟ ਗਏ ਪਰ ਆਰਡਰ ਨਹੀਂ ਹੋਇਆ",
        "ਮੇਰਾ ਭੁਗਤਾਨ ਫੇਲ੍ਹ ਹੋ ਗਿਆ"
      ]
    },
    "answers": {
      "en": "Don't worry — if money left your account without an order, our team will either complete the order or refund it. I'm connecting you to them now.",
      "bn": "চিন্তা করবেন না — অর্ডার ছাড়া টাকা কেটে গেলে আমাদের টিম হয় অর্ডারটি সম্পূর্ণ করবে, নয়তো টাকা ফেরত দেবে। এখনই আপনাকে তাদের সঙ্গে যুক্ত করছি।",
      "hi": "चिंता न करें — अगर बिना ऑर्डर के पैसे कटे हैं, तो हमारी टीम या तो ऑर्डर पूरा करेगी या पैसे वापस करेगी। मैं अभी आपको उनसे जोड़ रहा हूँ।",
      "pa": "ਚਿੰਤਾ ਨਾ ਕਰੋ — ਜੇ ਬਿਨਾਂ ਆਰਡਰ ਦੇ ਪੈਸੇ ਕੱਟੇ ਹਨ, ਤਾਂ ਸਾਡੀ ਟੀਮ ਜਾਂ ਤਾਂ ਆਰਡਰ ਪੂਰਾ ਕਰੇਗੀ ਜਾਂ ਪੈਸੇ ਵਾਪਸ ਕਰੇਗੀ। ਮੈਂ ਹੁਣੇ ਤੁਹਾਨੂੰ ਉਨ੍ਹਾਂ ਨਾਲ ਜੋੜ ਰਿਹਾ ਹਾਂ।"
    },
    "keywords": [
      "deducted",
      "debited",
      "failed",
      "payment",
      "kat gaya",
      "twice",
      "double"
    ]
  },
  {
    "id": "payment_pending",
    "action": "none",
    "title": {
      "en": "Payment still confirming",
      "bn": "পেমেন্ট নিশ্চিত হচ্ছে",
      "hi": "पेमेंट कन्फ़र्म हो रहा है",
      "pa": "ਭੁਗਤਾਨ ਪੱਕਾ ਹੋ ਰਿਹਾ ਹੈ"
    },
    "questions": {
      "en": [
        "It says my payment is still being confirmed",
        "payment pending",
        "payment processing for a long time",
        "Payment didn't go through",
        "should I pay again?"
      ],
      "bn": [
        "পেমেন্ট পেন্ডিং দেখাচ্ছে",
        "আবার পেমেন্ট করব?"
      ],
      "hi": [
        "पेमेंट पेंडिंग दिख रहा है",
        "क्या दोबारा पेमेंट करूँ?"
      ],
      "pa": [
        "ਭੁਗਤਾਨ ਪੈਂਡਿੰਗ ਦਿਖ ਰਿਹਾ ਹੈ",
        "ਕੀ ਦੁਬਾਰਾ ਭੁਗਤਾਨ ਕਰਾਂ?"
      ]
    },
    "answers": {
      "en": "If Zyppi says “Payment didn’t go through”, you haven’t been charged — just try again. If it says your payment is still being confirmed, tap Pay again in a moment to check. If it isn’t confirmed within 15 minutes you can pay again; if the first payment goes through later, it is refunded automatically. Your items stay reserved for those 15 minutes.",
      "bn": "Zyppi-তে “পেমেন্ট হয়নি” দেখালে টাকা কাটেনি — আবার চেষ্টা করুন। পেমেন্ট এখনও নিশ্চিত হচ্ছে দেখালে একটু পরে আবার পে ট্যাপ করে দেখুন। ১৫ মিনিটে নিশ্চিত না হলে আবার পেমেন্ট করতে পারেন; প্রথম পেমেন্ট পরে সফল হলে তা নিজে থেকেই ফেরত যায়। এই ১৫ মিনিট জিনিসগুলো আপনার জন্য রাখা থাকে।",
      "hi": "Zyppi पर “पेमेंट नहीं हुआ” दिखे तो पैसा नहीं कटा — फिर से कोशिश करें। अगर लिखा है कि पेमेंट अभी कन्फ़र्म हो रहा है, तो थोड़ी देर में फिर से पे पर टैप करके देखें। 15 मिनट में कन्फ़र्म न हो तो दोबारा पेमेंट कर सकते हैं; पहला पेमेंट बाद में सफल हुआ तो वह अपने-आप रिफ़ंड हो जाता है। इन 15 मिनट तक आपका सामान रिज़र्व रहता है।",
      "pa": "Zyppi ’ਤੇ “ਭੁਗਤਾਨ ਨਹੀਂ ਹੋਇਆ” ਦਿਖੇ ਤਾਂ ਪੈਸਾ ਨਹੀਂ ਕੱਟਿਆ — ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ। ਜੇ ਲਿਖਿਆ ਹੈ ਕਿ ਭੁਗਤਾਨ ਅਜੇ ਪੱਕਾ ਹੋ ਰਿਹਾ ਹੈ, ਤਾਂ ਥੋੜ੍ਹੀ ਦੇਰ ਬਾਅਦ ਫਿਰ ਪੇ ’ਤੇ ਟੈਪ ਕਰਕੇ ਦੇਖੋ। 15 ਮਿੰਟ ਵਿੱਚ ਪੱਕਾ ਨਾ ਹੋਵੇ ਤਾਂ ਦੁਬਾਰਾ ਭੁਗਤਾਨ ਕਰ ਸਕਦੇ ਹੋ; ਪਹਿਲਾ ਭੁਗਤਾਨ ਬਾਅਦ ਵਿੱਚ ਸਫਲ ਹੋਇਆ ਤਾਂ ਉਹ ਆਪਣੇ-ਆਪ ਰਿਫ਼ੰਡ ਹੋ ਜਾਂਦਾ ਹੈ। ਇਹਨਾਂ 15 ਮਿੰਟਾਂ ਤੱਕ ਤੁਹਾਡਾ ਸਾਮਾਨ ਰਾਖਵਾਂ ਰਹਿੰਦਾ ਹੈ।"
    },
    "keywords": [
      "pending",
      "processing",
      "confirming",
      "stuck",
      "pay again",
      "not charged"
    ],
    "related": [
      "payment_failed",
      "payment_methods"
    ]
  },
  {
    "id": "wallet",
    "action": "none",
    "title": {
      "en": "Zyppi wallet",
      "bn": "Zyppi ওয়ালেট",
      "hi": "Zyppi वॉलेट",
      "pa": "Zyppi ਵਾਲਿਟ"
    },
    "questions": {
      "en": [
        "What is the Zyppi wallet?",
        "How do I use my wallet balance?",
        "Can I withdraw my wallet money?",
        "add money to wallet",
        "wallet balance expiry",
        "wallet me paisa kaise aaya"
      ],
      "bn": [
        "ওয়ালেটের টাকা কীভাবে ব্যবহার করব?",
        "ওয়ালেট থেকে টাকা তোলা যাবে?"
      ],
      "hi": [
        "वॉलेट बैलेंस कैसे इस्तेमाल करें?",
        "क्या वॉलेट से पैसे निकाल सकते हैं?"
      ],
      "pa": [
        "ਵਾਲਿਟ ਬੈਲੇਂਸ ਕਿਵੇਂ ਵਰਤੀਏ?",
        "ਕੀ ਵਾਲਿਟ ਤੋਂ ਪੈਸੇ ਕੱਢ ਸਕਦੇ ਹਾਂ?"
      ]
    },
    "answers": {
      "en": "Your Zyppi wallet holds refunds and approved claims — they land there instantly. At checkout, switch on “Use Zyppi wallet” to pay with it, fully or together with another method. Wallet money can’t be topped up, withdrawn or transferred, and refunded money never expires. If you delete your account, any wallet balance is lost.",
      "bn": "আপনার Zyppi ওয়ালেটে রিফান্ড ও অনুমোদিত দাবির টাকা থাকে — সঙ্গে সঙ্গে আসে। চেকআউটে “Zyppi ওয়ালেট ব্যবহার করুন” চালু করে পুরো বা অন্য উপায়ের সঙ্গে পেমেন্ট করুন। ওয়ালেটে টাকা ভরা, তোলা বা পাঠানো যায় না, আর ফেরত টাকার মেয়াদ শেষ হয় না। অ্যাকাউন্ট মুছলে ওয়ালেটের টাকা চলে যায়।",
      "hi": "आपके Zyppi वॉलेट में रिफ़ंड और मंज़ूर दावे का पैसा आता है — तुरंत। चेकआउट पर “Zyppi वॉलेट इस्तेमाल करें” चालू करके पूरा या किसी और तरीके के साथ पेमेंट करें। वॉलेट में पैसा डाला, निकाला या भेजा नहीं जा सकता, और रिफ़ंड का पैसा कभी एक्सपायर नहीं होता। अकाउंट डिलीट करने पर वॉलेट बैलेंस खत्म हो जाता है।",
      "pa": "ਤੁਹਾਡੇ Zyppi ਵਾਲਿਟ ਵਿੱਚ ਰਿਫ਼ੰਡ ਅਤੇ ਮਨਜ਼ੂਰ ਦਾਅਵਿਆਂ ਦਾ ਪੈਸਾ ਆਉਂਦਾ ਹੈ — ਤੁਰੰਤ। ਚੈੱਕਆਊਟ ’ਤੇ “Zyppi ਵਾਲਿਟ ਵਰਤੋ” ਚਾਲੂ ਕਰਕੇ ਪੂਰਾ ਜਾਂ ਕਿਸੇ ਹੋਰ ਤਰੀਕੇ ਨਾਲ ਭੁਗਤਾਨ ਕਰੋ। ਵਾਲਿਟ ਵਿੱਚ ਪੈਸਾ ਪਾਇਆ, ਕੱਢਿਆ ਜਾਂ ਭੇਜਿਆ ਨਹੀਂ ਜਾ ਸਕਦਾ, ਅਤੇ ਰਿਫ਼ੰਡ ਦਾ ਪੈਸਾ ਕਦੇ ਖ਼ਤਮ ਨਹੀਂ ਹੁੰਦਾ। ਖਾਤਾ ਮਿਟਾਉਣ ’ਤੇ ਵਾਲਿਟ ਬੈਲੇਂਸ ਖ਼ਤਮ ਹੋ ਜਾਂਦਾ ਹੈ।"
    },
    "keywords": [
      "wallet",
      "balance",
      "credit",
      "withdraw",
      "top up",
      "expire"
    ],
    "related": [
      "refund",
      "payment_methods"
    ]
  },
  {
    "id": "delivery_fee",
    "action": "none",
    "title": {
      "en": "Delivery charges",
      "bn": "ডেলিভারি চার্জ",
      "hi": "डिलीवरी चार्ज",
      "pa": "ਡਿਲੀਵਰੀ ਚਾਰਜ"
    },
    "questions": {
      "en": [
        "How much is the delivery fee?",
        "What is the handling fee?",
        "Are there any extra charges?",
        "Is delivery free?",
        "free delivery kab milegi",
        "why am I charged a delivery fee",
        "hidden charges"
      ],
      "bn": [
        "ডেলিভারি চার্জ কত?",
        "হ্যান্ডলিং ফি কী?",
        "কোনো বাড়তি চার্জ আছে?"
      ],
      "hi": [
        "डिलीवरी चार्ज कितना है?",
        "हैंडलिंग फ़ीस क्या है?",
        "क्या कोई अतिरिक्त चार्ज है?"
      ],
      "pa": [
        "ਡਿਲੀਵਰੀ ਚਾਰਜ ਕਿੰਨਾ ਹੈ?",
        "ਹੈਂਡਲਿੰਗ ਫ਼ੀਸ ਕੀ ਹੈ?",
        "ਕੀ ਕੋਈ ਵਾਧੂ ਚਾਰਜ ਹੈ?"
      ]
    },
    "answers": {
      "en": "Your Zyppi cart bill shows every charge before you pay: a delivery fee, which is free once your items cross the free-delivery amount shown in the cart; a small handling fee per order; and any tip you choose to add. There are no other hidden charges — what the bill shows is what you pay.",
      "bn": "আপনার Zyppi কার্টের বিলে পেমেন্টের আগেই সব চার্জ দেখায়: ডেলিভারি চার্জ, যা কার্টে দেখানো ফ্রি-ডেলিভারির অঙ্ক পেরোলে ফ্রি; প্রতি অর্ডারে সামান্য হ্যান্ডলিং ফি; আর আপনার দেওয়া টিপ (যদি দেন)। আর কোনো লুকোনো চার্জ নেই — বিলে যা দেখায়, তা-ই দেবেন।",
      "hi": "आपके Zyppi कार्ट बिल में पेमेंट से पहले हर चार्ज दिखता है: डिलीवरी फ़ीस, जो कार्ट में दिखाई गई फ़्री-डिलीवरी राशि पार करने पर मुफ़्त हो जाती है; हर ऑर्डर पर छोटी हैंडलिंग फ़ीस; और आपकी दी हुई टिप (अगर दें)। कोई और छिपा चार्ज नहीं — बिल में जो दिखे, वही देना है।",
      "pa": "ਤੁਹਾਡੇ Zyppi ਕਾਰਟ ਬਿੱਲ ਵਿੱਚ ਭੁਗਤਾਨ ਤੋਂ ਪਹਿਲਾਂ ਹਰ ਚਾਰਜ ਦਿਖਦਾ ਹੈ: ਡਿਲੀਵਰੀ ਫ਼ੀਸ, ਜੋ ਕਾਰਟ ਵਿੱਚ ਦਿਖਾਈ ਮੁਫ਼ਤ-ਡਿਲੀਵਰੀ ਰਕਮ ਪਾਰ ਕਰਨ ’ਤੇ ਮੁਫ਼ਤ ਹੋ ਜਾਂਦੀ ਹੈ; ਹਰ ਆਰਡਰ ’ਤੇ ਛੋਟੀ ਹੈਂਡਲਿੰਗ ਫ਼ੀਸ; ਅਤੇ ਤੁਹਾਡੀ ਦਿੱਤੀ ਟਿੱਪ (ਜੇ ਦਿਓ)। ਕੋਈ ਹੋਰ ਲੁਕਿਆ ਚਾਰਜ ਨਹੀਂ — ਬਿੱਲ ਵਿੱਚ ਜੋ ਦਿਖੇ, ਉਹੀ ਦੇਣਾ ਹੈ।"
    },
    "keywords": [
      "fee",
      "charge",
      "charges",
      "cost",
      "handling",
      "free delivery",
      "extra"
    ],
    "related": [
      "min_order",
      "tip",
      "coupons"
    ]
  },
  {
    "id": "min_order",
    "action": "none",
    "title": {
      "en": "Minimum order",
      "bn": "ন্যূনতম অর্ডার",
      "hi": "न्यूनतम ऑर्डर",
      "pa": "ਘੱਟੋ-ਘੱਟ ਆਰਡਰ"
    },
    "questions": {
      "en": [
        "Is there a minimum order amount?",
        "It says minimum order is not met",
        "Why can't I check out a small order?",
        "minimum kitne ka order"
      ],
      "bn": [
        "ন্যূনতম কত টাকার অর্ডার করতে হয়?"
      ],
      "hi": [
        "कम से कम कितने का ऑर्डर करना होगा?"
      ],
      "pa": [
        "ਘੱਟੋ-ਘੱਟ ਕਿੰਨੇ ਦਾ ਆਰਡਰ ਕਰਨਾ ਪਵੇਗਾ?"
      ]
    },
    "answers": {
      "en": "Zyppi may have a minimum order value. If your cart is below it, checkout shows “Minimum order is ₹… Add a little more to your cart.” Add a few more items and you can place the order. Coupons can also have their own minimum — the app tells you how much more to add.",
      "bn": "Zyppi-তে একটি ন্যূনতম অর্ডার মূল্য থাকতে পারে। কার্ট তার কম হলে চেকআউটে দেখায় “ন্যূনতম অর্ডার ₹… কার্টে আরও কিছু যোগ করুন।” আরও কয়েকটা জিনিস যোগ করলেই অর্ডার দিতে পারবেন। কুপনেরও আলাদা ন্যূনতম থাকতে পারে — অ্যাপ জানিয়ে দেবে আর কত যোগ করতে হবে।",
      "hi": "Zyppi पर न्यूनतम ऑर्डर राशि हो सकती है। कार्ट उससे कम हो तो चेकआउट पर दिखता है “न्यूनतम ऑर्डर ₹… है। कार्ट में थोड़ा और जोड़ें।” कुछ और सामान जोड़ें और ऑर्डर कर सकते हैं। कूपन की भी अपनी न्यूनतम राशि हो सकती है — ऐप बताएगा कि और कितना जोड़ना है।",
      "pa": "Zyppi ’ਤੇ ਘੱਟੋ-ਘੱਟ ਆਰਡਰ ਰਕਮ ਹੋ ਸਕਦੀ ਹੈ। ਕਾਰਟ ਉਸ ਤੋਂ ਘੱਟ ਹੋਵੇ ਤਾਂ ਚੈੱਕਆਊਟ ’ਤੇ ਦਿਖਦਾ ਹੈ “ਘੱਟੋ-ਘੱਟ ਆਰਡਰ ₹… ਹੈ। ਕਾਰਟ ਵਿੱਚ ਥੋੜ੍ਹਾ ਹੋਰ ਜੋੜੋ।” ਕੁਝ ਹੋਰ ਸਾਮਾਨ ਜੋੜੋ ਅਤੇ ਆਰਡਰ ਕਰ ਸਕਦੇ ਹੋ। ਕੂਪਨ ਦੀ ਵੀ ਆਪਣੀ ਘੱਟੋ-ਘੱਟ ਰਕਮ ਹੋ ਸਕਦੀ ਹੈ — ਐਪ ਦੱਸੇਗੀ ਕਿ ਹੋਰ ਕਿੰਨਾ ਜੋੜਨਾ ਹੈ।"
    },
    "keywords": [
      "minimum",
      "min order",
      "small order",
      "checkout blocked"
    ],
    "related": [
      "delivery_fee",
      "coupons"
    ]
  },
  {
    "id": "tip",
    "action": "none",
    "title": {
      "en": "Tip your delivery partner",
      "bn": "ডেলিভারি পার্টনারকে টিপ",
      "hi": "डिलीवरी पार्टनर को टिप",
      "pa": "ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਨੂੰ ਟਿੱਪ"
    },
    "questions": {
      "en": [
        "How do I tip the rider?",
        "Is tipping compulsory?",
        "Does the rider get the full tip?",
        "tip kaise de"
      ],
      "bn": [
        "রাইডারকে কীভাবে টিপ দেব?"
      ],
      "hi": [
        "राइडर को टिप कैसे दें?"
      ],
      "pa": [
        "ਰਾਈਡਰ ਨੂੰ ਟਿੱਪ ਕਿਵੇਂ ਦੇਈਏ?"
      ]
    },
    "answers": {
      "en": "Tipping on Zyppi is optional. Pick an amount under “Tip your delivery partner” in your cart, up to ₹500. The full amount goes to your rider.",
      "bn": "Zyppi-তে টিপ দেওয়া ঐচ্ছিক। কার্টে “ডেলিভারি পার্টনারকে টিপ দিন”-এ ₹500 পর্যন্ত একটা অঙ্ক বাছুন। পুরো টাকাই রাইডার পান।",
      "hi": "Zyppi पर टिप देना ज़रूरी नहीं है। कार्ट में “डिलीवरी पार्टनर को टिप दें” में ₹500 तक कोई राशि चुनें। पूरी राशि आपके राइडर को मिलती है।",
      "pa": "Zyppi ’ਤੇ ਟਿੱਪ ਦੇਣਾ ਲਾਜ਼ਮੀ ਨਹੀਂ। ਕਾਰਟ ਵਿੱਚ “ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਨੂੰ ਟਿੱਪ ਦਿਓ” ਵਿੱਚ ₹500 ਤੱਕ ਕੋਈ ਰਕਮ ਚੁਣੋ। ਪੂਰੀ ਰਕਮ ਤੁਹਾਡੇ ਰਾਈਡਰ ਨੂੰ ਮਿਲਦੀ ਹੈ।"
    },
    "keywords": [
      "tip",
      "tipping",
      "rider tip",
      "bakshish"
    ],
    "related": [
      "delivery_fee"
    ]
  },
  {
    "id": "coupons",
    "action": "none",
    "title": {
      "en": "Coupons and offers",
      "bn": "কুপন ও অফার",
      "hi": "कूपन और ऑफ़र",
      "pa": "ਕੂਪਨ ਅਤੇ ਆਫ਼ਰ"
    },
    "questions": {
      "en": [
        "How do I use a coupon?",
        "My coupon is not working",
        "Are there any offers?",
        "promo code",
        "coupon expired",
        "coupon only for first order",
        "cupon not applying",
        "discount code invalid",
        "any discount today?",
        "todays offers"
      ],
      "bn": [
        "কুপন কীভাবে ব্যবহার করব?",
        "কুপন কাজ করছে না",
        "কোনো অফার আছে?"
      ],
      "hi": [
        "कूपन कैसे इस्तेमाल करें?",
        "मेरा कूपन काम नहीं कर रहा",
        "कोई ऑफ़र है?"
      ],
      "pa": [
        "ਕੂਪਨ ਕਿਵੇਂ ਵਰਤੀਏ?",
        "ਮੇਰਾ ਕੂਪਨ ਕੰਮ ਨਹੀਂ ਕਰ ਰਿਹਾ",
        "ਕੋਈ ਆਫ਼ਰ ਹੈ?"
      ]
    },
    "answers": {
      "en": "Enter the code in the Coupons box in your Zyppi cart. If your cart is below the coupon’s minimum, the app shows how much more to add. A coupon won’t apply if it has expired, has been fully used, you’ve used it the maximum number of times, it’s only for your first order, or it isn’t available in your area — the message in the cart tells you which.",
      "bn": "Zyppi কার্টের কুপন বক্সে কোডটি লিখুন। কার্ট কুপনের ন্যূনতমের কম হলে অ্যাপ জানিয়ে দেবে আর কত যোগ করতে হবে। কুপনের মেয়াদ শেষ হলে, সব ব্যবহার হয়ে গেলে, আপনি সর্বোচ্চবার ব্যবহার করে থাকলে, শুধু প্রথম অর্ডারের জন্য হলে, বা আপনার এলাকায় না চললে কুপন লাগবে না — কার্টের মেসেজে কারণ দেখাবে।",
      "hi": "Zyppi कार्ट में कूपन बॉक्स में कोड डालें। कार्ट कूपन की न्यूनतम राशि से कम हो तो ऐप बता देगा कि और कितना जोड़ना है। कूपन तब नहीं लगेगा जब वह एक्सपायर हो गया हो, पूरा इस्तेमाल हो चुका हो, आपने उसे अधिकतम बार इस्तेमाल कर लिया हो, वह सिर्फ़ पहले ऑर्डर के लिए हो, या आपके इलाके में न चलता हो — कार्ट का मैसेज कारण बताता है।",
      "pa": "Zyppi ਕਾਰਟ ਵਿੱਚ ਕੂਪਨ ਬਾਕਸ ਵਿੱਚ ਕੋਡ ਪਾਓ। ਕਾਰਟ ਕੂਪਨ ਦੀ ਘੱਟੋ-ਘੱਟ ਰਕਮ ਤੋਂ ਘੱਟ ਹੋਵੇ ਤਾਂ ਐਪ ਦੱਸ ਦੇਵੇਗੀ ਕਿ ਹੋਰ ਕਿੰਨਾ ਜੋੜਨਾ ਹੈ। ਕੂਪਨ ਤਾਂ ਨਹੀਂ ਲੱਗੇਗਾ ਜੇ ਉਸਦੀ ਮਿਆਦ ਪੁੱਗ ਗਈ ਹੋਵੇ, ਪੂਰਾ ਵਰਤਿਆ ਜਾ ਚੁੱਕਾ ਹੋਵੇ, ਤੁਸੀਂ ਵੱਧ ਤੋਂ ਵੱਧ ਵਾਰ ਵਰਤ ਲਿਆ ਹੋਵੇ, ਸਿਰਫ਼ ਪਹਿਲੇ ਆਰਡਰ ਲਈ ਹੋਵੇ, ਜਾਂ ਤੁਹਾਡੇ ਇਲਾਕੇ ਵਿੱਚ ਨਾ ਚੱਲਦਾ ਹੋਵੇ — ਕਾਰਟ ਦਾ ਸੁਨੇਹਾ ਕਾਰਨ ਦੱਸਦਾ ਹੈ।"
    },
    "keywords": [
      "coupon",
      "offer",
      "discount",
      "promo",
      "code",
      "cupon",
      "voucher"
    ],
    "related": [
      "delivery_fee",
      "min_order"
    ]
  },
  {
    "id": "delivery_areas",
    "action": "none",
    "title": {
      "en": "Where do you deliver?",
      "bn": "কোথায় ডেলিভারি করেন?",
      "hi": "आप कहाँ डिलीवरी करते हैं?",
      "pa": "ਤੁਸੀਂ ਕਿੱਥੇ ਡਿਲੀਵਰੀ ਕਰਦੇ ਹੋ?"
    },
    "questions": {
      "en": [
        "Which areas do you deliver to?",
        "Do you deliver to my area?",
        "Is delivery available in my town?",
        "Not serviceable at my address",
        "It says we don't deliver to this address yet",
        "delivery radius",
        "service area",
        "serviceable areas",
        "Is Zyppi available in my town?"
      ],
      "bn": [
        "কোন কোন এলাকায় ডেলিভারি করেন?",
        "আমার এলাকায় কি ডেলিভারি হয়?"
      ],
      "hi": [
        "आप किन इलाकों में डिलीवरी करते हैं?",
        "क्या मेरे इलाके में डिलीवरी होती है?"
      ],
      "pa": [
        "ਤੁਸੀਂ ਕਿਹੜੇ ਇਲਾਕਿਆਂ ਵਿੱਚ ਡਿਲੀਵਰੀ ਕਰਦੇ ਹੋ?",
        "ਕੀ ਮੇਰੇ ਇਲਾਕੇ ਵਿੱਚ ਡਿਲੀਵਰੀ ਹੁੰਦੀ ਹੈ?"
      ]
    },
    "answers": {
      "en": "We currently deliver in Purulia, Raghunathpur and Chelyama. Set your address from the location bar on Home and the app will tell you if we deliver there.",
      "bn": "এখন আমরা পুরুলিয়া, রঘুনাথপুর ও চেলিয়ামায় ডেলিভারি করি। হোম পেজের লোকেশন বার থেকে ঠিকানা দিন, অ্যাপ জানিয়ে দেবে সেখানে ডেলিভারি হয় কি না।",
      "hi": "अभी हम पुरुलिया, रघुनाथपुर और चेलियामा में डिलीवरी करते हैं। होम पर लोकेशन बार से अपना पता चुनें, ऐप बता देगा कि वहाँ डिलीवरी होती है या नहीं।",
      "pa": "ਹੁਣ ਅਸੀਂ ਪੁਰੂਲੀਆ, ਰਘੂਨਾਥਪੁਰ ਅਤੇ ਚੇਲਿਆਮਾ ਵਿੱਚ ਡਿਲੀਵਰੀ ਕਰਦੇ ਹਾਂ। ਹੋਮ ’ਤੇ ਲੋਕੇਸ਼ਨ ਬਾਰ ਤੋਂ ਆਪਣਾ ਪਤਾ ਚੁਣੋ, ਐਪ ਦੱਸ ਦੇਵੇਗੀ ਕਿ ਉੱਥੇ ਡਿਲੀਵਰੀ ਹੁੰਦੀ ਹੈ ਜਾਂ ਨਹੀਂ।"
    },
    "keywords": [
      "purulia",
      "raghunathpur",
      "chelyama",
      "serviceable",
      "area",
      "location",
      "radius",
      "pincode"
    ],
    "related": [
      "delivery_fee",
      "change_address"
    ]
  },
  {
    "id": "cant_order",
    "action": "none",
    "title": {
      "en": "Why can't I place an order?",
      "bn": "অর্ডার দিতে পারছি না কেন?",
      "hi": "ऑर्डर क्यों नहीं हो रहा?",
      "pa": "ਆਰਡਰ ਕਿਉਂ ਨਹੀਂ ਹੋ ਰਿਹਾ?"
    },
    "questions": {
      "en": [
        "Why can't I place an order?",
        "It says stores in your area are closed",
        "Ordering is paused in my area",
        "app says update required",
        "checkout button not working",
        "Couldn't place your order",
        "store band hai kya"
      ],
      "bn": [
        "অর্ডার দিতে পারছি না",
        "দোকান বন্ধ দেখাচ্ছে"
      ],
      "hi": [
        "ऑर्डर नहीं हो रहा",
        "दुकानें बंद दिख रही हैं"
      ],
      "pa": [
        "ਆਰਡਰ ਨਹੀਂ ਹੋ ਰਿਹਾ",
        "ਦੁਕਾਨਾਂ ਬੰਦ ਦਿਖ ਰਹੀਆਂ ਹਨ"
      ]
    },
    "answers": {
      "en": "Zyppi checkout tells you why an order can’t go through. “Stores in your area are closed right now” means please order during opening hours. “Ordering is paused in your area” is a short pause by our team. “This version of Zyppi is no longer supported” means update the app from the Play Store. Guests must save their account first. For any other error, try again in a minute or tap “Talk to a person”.",
      "bn": "Zyppi চেকআউটেই জানিয়ে দেয় কেন অর্ডার হচ্ছে না। “আপনার এলাকার দোকান এখন বন্ধ” মানে খোলার সময়ে অর্ডার দিন। “আপনার এলাকায় অর্ডার আপাতত বন্ধ” মানে আমাদের টিমের সাময়িক বিরতি। “Zyppi-র এই ভার্সন আর চলবে না” মানে Play Store থেকে অ্যাপ আপডেট করুন। গেস্টদের আগে অ্যাকাউন্ট সেভ করতে হয়। অন্য কোনো ত্রুটি হলে এক মিনিট পরে আবার চেষ্টা করুন বা “কারও সঙ্গে কথা বলুন” ট্যাপ করুন।",
      "hi": "Zyppi चेकआउट ही बताता है कि ऑर्डर क्यों नहीं हो रहा। “आपके इलाके की दुकानें अभी बंद हैं” का मतलब है खुलने के समय ऑर्डर करें। “आपके इलाके में ऑर्डर अभी रुके हैं” हमारी टीम का छोटा ब्रेक है। “Zyppi का यह वर्ज़न अब नहीं चलेगा” का मतलब है Play Store से ऐप अपडेट करें। गेस्ट को पहले अपना अकाउंट सेव करना होता है। कोई और गड़बड़ हो तो एक मिनट बाद फिर कोशिश करें या “किसी से बात करें” पर टैप करें।",
      "pa": "Zyppi ਚੈੱਕਆਊਟ ਹੀ ਦੱਸਦਾ ਹੈ ਕਿ ਆਰਡਰ ਕਿਉਂ ਨਹੀਂ ਹੋ ਰਿਹਾ। “ਤੁਹਾਡੇ ਇਲਾਕੇ ਦੀਆਂ ਦੁਕਾਨਾਂ ਹੁਣ ਬੰਦ ਹਨ” ਦਾ ਮਤਲਬ ਹੈ ਖੁੱਲ੍ਹਣ ਦੇ ਸਮੇਂ ਆਰਡਰ ਕਰੋ। “ਤੁਹਾਡੇ ਇਲਾਕੇ ਵਿੱਚ ਆਰਡਰ ਹੁਣ ਰੁਕੇ ਹਨ” ਸਾਡੀ ਟੀਮ ਦਾ ਛੋਟਾ ਵਿਰਾਮ ਹੈ। “Zyppi ਦਾ ਇਹ ਵਰਜ਼ਨ ਹੁਣ ਨਹੀਂ ਚੱਲੇਗਾ” ਦਾ ਮਤਲਬ ਹੈ Play Store ਤੋਂ ਐਪ ਅੱਪਡੇਟ ਕਰੋ। ਗੈਸਟ ਨੂੰ ਪਹਿਲਾਂ ਆਪਣਾ ਖਾਤਾ ਸੇਵ ਕਰਨਾ ਪੈਂਦਾ ਹੈ। ਕੋਈ ਹੋਰ ਗੜਬੜ ਹੋਵੇ ਤਾਂ ਇੱਕ ਮਿੰਟ ਬਾਅਦ ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ ਜਾਂ “ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ” ’ਤੇ ਟੈਪ ਕਰੋ।"
    },
    "keywords": [
      "closed",
      "paused",
      "maintenance",
      "update",
      "blocked",
      "cannot order",
      "opening hours"
    ],
    "related": [
      "delivery_areas",
      "guest_checkout",
      "talk_to_person"
    ]
  },
  {
    "id": "schedule_slot",
    "action": "none",
    "title": {
      "en": "Schedule a delivery time",
      "bn": "ডেলিভারির সময় বাছুন",
      "hi": "डिलीवरी का समय चुनें",
      "pa": "ਡਿਲੀਵਰੀ ਦਾ ਸਮਾਂ ਚੁਣੋ"
    },
    "questions": {
      "en": [
        "Can I schedule my order for later?",
        "deliver tomorrow morning",
        "choose delivery slot",
        "That delivery time is no longer available",
        "express delivery",
        "kal subah delivery"
      ],
      "bn": [
        "পরে ডেলিভারির জন্য অর্ডার দেওয়া যাবে?",
        "ডেলিভারি স্লট বাছব কীভাবে?"
      ],
      "hi": [
        "क्या बाद के लिए ऑर्डर शेड्यूल कर सकते हैं?",
        "डिलीवरी स्लॉट कैसे चुनें?"
      ],
      "pa": [
        "ਕੀ ਬਾਅਦ ਲਈ ਆਰਡਰ ਸ਼ਡਿਊਲ ਕਰ ਸਕਦੇ ਹਾਂ?",
        "ਡਿਲੀਵਰੀ ਸਲਾਟ ਕਿਵੇਂ ਚੁਣੀਏ?"
      ]
    },
    "answers": {
      "en": "Yes. At Zyppi checkout, under “Schedule”, choose Express (the fastest delivery) or a later time slot. If the slot you picked is no longer available when you pay, the app says “That delivery time is no longer available. Pick another.” — just choose a different one.",
      "bn": "হ্যাঁ। Zyppi চেকআউটে “শিডিউল”-এর নিচে এক্সপ্রেস (সবচেয়ে দ্রুত) বা পরের কোনো সময় বাছুন। পেমেন্টের সময় বাছা স্লট আর না থাকলে অ্যাপ বলবে “এই ডেলিভারির সময় আর পাওয়া যাচ্ছে না। অন্যটি বাছুন।” — অন্য একটি বেছে নিন।",
      "hi": "हाँ। Zyppi चेकआउट पर “शेड्यूल” में एक्सप्रेस (सबसे तेज़) या बाद का कोई समय चुनें। पेमेंट के समय चुना स्लॉट उपलब्ध न रहे, तो ऐप कहेगा “यह डिलीवरी समय अब उपलब्ध नहीं है। दूसरा चुनें।” — कोई दूसरा चुन लें।",
      "pa": "ਹਾਂ। Zyppi ਚੈੱਕਆਊਟ ’ਤੇ “ਸ਼ਡਿਊਲ” ਵਿੱਚ ਐਕਸਪ੍ਰੈਸ (ਸਭ ਤੋਂ ਤੇਜ਼) ਜਾਂ ਬਾਅਦ ਦਾ ਕੋਈ ਸਮਾਂ ਚੁਣੋ। ਭੁਗਤਾਨ ਵੇਲੇ ਚੁਣਿਆ ਸਲਾਟ ਉਪਲਬਧ ਨਾ ਰਹੇ, ਤਾਂ ਐਪ ਕਹੇਗੀ “ਇਹ ਡਿਲੀਵਰੀ ਸਮਾਂ ਹੁਣ ਉਪਲਬਧ ਨਹੀਂ। ਦੂਜਾ ਚੁਣੋ।” — ਕੋਈ ਦੂਜਾ ਚੁਣ ਲਓ।"
    },
    "keywords": [
      "schedule",
      "slot",
      "later",
      "tomorrow",
      "express",
      "time"
    ],
    "related": [
      "where_is_order",
      "cant_order"
    ]
  },
  {
    "id": "multi_seller_cart",
    "action": "none",
    "title": {
      "en": "Items from different sellers",
      "bn": "বিভিন্ন বিক্রেতার জিনিস",
      "hi": "अलग-अलग सेलर का सामान",
      "pa": "ਵੱਖ-ਵੱਖ ਸੇਲਰ ਦਾ ਸਾਮਾਨ"
    },
    "questions": {
      "en": [
        "Can I order from different stores in one order?",
        "It says my basket has items from too many sellers",
        "Who is the seller of my item?",
        "marketplace seller problem",
        "one order many shops"
      ],
      "bn": [
        "এক অর্ডারে আলাদা দোকানের জিনিস নেওয়া যাবে?"
      ],
      "hi": [
        "क्या एक ऑर्डर में अलग-अलग दुकानों का सामान ले सकते हैं?"
      ],
      "pa": [
        "ਕੀ ਇੱਕ ਆਰਡਰ ਵਿੱਚ ਵੱਖ-ਵੱਖ ਦੁਕਾਨਾਂ ਦਾ ਸਾਮਾਨ ਲੈ ਸਕਦੇ ਹਾਂ?"
      ]
    },
    "answers": {
      "en": "Yes — one Zyppi order can include items from a few different sellers, and the rider collects from each before coming to you (the order screen says “Collecting your order from 2 stores”). If you add items from too many sellers, the app asks you to remove some or pick the same seller for them. Zyppi takes the payment and delivers for every seller, so for any problem with your order, contact Zyppi support.",
      "bn": "হ্যাঁ — একটি Zyppi অর্ডারে কয়েকজন আলাদা বিক্রেতার জিনিস থাকতে পারে, রাইডার প্রত্যেকের কাছ থেকে নিয়ে আপনার কাছে আসেন (অর্ডার স্ক্রিনে দেখায় “2টি দোকান থেকে অর্ডার নেওয়া হচ্ছে”)। অনেক বেশি বিক্রেতার জিনিস যোগ করলে অ্যাপ কিছু সরাতে বা একই বিক্রেতা বাছতে বলবে। সব বিক্রেতার হয়ে Zyppi পেমেন্ট নেয় ও ডেলিভারি করে, তাই অর্ডারে কোনো সমস্যা হলে Zyppi সাপোর্টে যোগাযোগ করুন।",
      "hi": "हाँ — एक Zyppi ऑर्डर में कुछ अलग-अलग सेलर का सामान हो सकता है, राइडर हर एक से लेकर आपके पास आता है (ऑर्डर स्क्रीन पर दिखता है “2 दुकानों से ऑर्डर ले रहे हैं”)। बहुत ज़्यादा सेलर का सामान जोड़ने पर ऐप कुछ हटाने या एक ही सेलर चुनने को कहेगा। हर सेलर के लिए Zyppi ही पेमेंट लेता है और डिलीवरी करता है, इसलिए ऑर्डर में कोई दिक्कत हो तो Zyppi सपोर्ट से संपर्क करें।",
      "pa": "ਹਾਂ — ਇੱਕ Zyppi ਆਰਡਰ ਵਿੱਚ ਕੁਝ ਵੱਖ-ਵੱਖ ਸੇਲਰਾਂ ਦਾ ਸਾਮਾਨ ਹੋ ਸਕਦਾ ਹੈ, ਰਾਈਡਰ ਹਰ ਇੱਕ ਤੋਂ ਲੈ ਕੇ ਤੁਹਾਡੇ ਕੋਲ ਆਉਂਦਾ ਹੈ (ਆਰਡਰ ਸਕ੍ਰੀਨ ’ਤੇ ਦਿਖਦਾ ਹੈ “2 ਦੁਕਾਨਾਂ ਤੋਂ ਆਰਡਰ ਲੈ ਰਹੇ ਹਾਂ”)। ਬਹੁਤ ਜ਼ਿਆਦਾ ਸੇਲਰਾਂ ਦਾ ਸਾਮਾਨ ਜੋੜਨ ’ਤੇ ਐਪ ਕੁਝ ਹਟਾਉਣ ਜਾਂ ਇੱਕੋ ਸੇਲਰ ਚੁਣਨ ਲਈ ਕਹੇਗੀ। ਹਰ ਸੇਲਰ ਲਈ Zyppi ਹੀ ਭੁਗਤਾਨ ਲੈਂਦਾ ਅਤੇ ਡਿਲੀਵਰੀ ਕਰਦਾ ਹੈ, ਇਸ ਲਈ ਆਰਡਰ ਵਿੱਚ ਕੋਈ ਗੜਬੜ ਹੋਵੇ ਤਾਂ Zyppi ਸਪੋਰਟ ਨਾਲ ਸੰਪਰਕ ਕਰੋ।"
    },
    "keywords": [
      "seller",
      "sellers",
      "store",
      "shop",
      "marketplace",
      "basket",
      "multiple"
    ],
    "related": [
      "out_of_stock",
      "talk_to_person"
    ]
  },
  {
    "id": "out_of_stock",
    "action": "none",
    "title": {
      "en": "Item out of stock",
      "bn": "জিনিস স্টকে নেই",
      "hi": "सामान स्टॉक में नहीं",
      "pa": "ਸਾਮਾਨ ਸਟਾਕ ਵਿੱਚ ਨਹੀਂ"
    },
    "questions": {
      "en": [
        "An item in my cart is out of stock",
        "It says the item is no longer available",
        "I can't find a product",
        "product not available",
        "when will it be back in stock",
        "saman nahi mil raha",
        "do you have atta?",
        "is rice available?"
      ],
      "bn": [
        "জিনিসটা স্টকে নেই",
        "জিনিস খুঁজে পাচ্ছি না"
      ],
      "hi": [
        "सामान स्टॉक में नहीं है",
        "सामान नहीं मिल रहा"
      ],
      "pa": [
        "ਸਾਮਾਨ ਸਟਾਕ ਵਿੱਚ ਨਹੀਂ ਹੈ",
        "ਸਾਮਾਨ ਨਹੀਂ ਮਿਲ ਰਿਹਾ"
      ]
    },
    "answers": {
      "en": "Use the search bar on Zyppi Home (for example oil, rice or atta) or browse categories to find products. If an item runs out, your cart says it is out of stock — reduce the quantity or remove it — or that it is no longer available. If a store finds an item has run out after you ordered, our team will replace it or refund that item.",
      "bn": "Zyppi হোমের সার্চ বার (যেমন তেল, চাল বা আটা) বা ক্যাটাগরি থেকে জিনিস খুঁজুন। কোনো জিনিস শেষ হলে কার্টে দেখাবে স্টকে নেই — পরিমাণ কমান বা সরিয়ে দিন — অথবা আর পাওয়া যাচ্ছে না। অর্ডারের পর দোকানে কোনো জিনিস শেষ হলে আমাদের টিম সেটা বদলে দেবে বা সেই জিনিসের টাকা ফেরত দেবে।",
      "hi": "Zyppi होम पर सर्च बार (जैसे तेल, चावल या आटा) या कैटेगरी से सामान ढूँढें। कोई सामान खत्म हो तो कार्ट में दिखेगा कि स्टॉक में नहीं है — मात्रा कम करें या हटा दें — या अब उपलब्ध नहीं है। ऑर्डर के बाद दुकान में कोई सामान खत्म निकले, तो हमारी टीम उसे बदल देगी या उस सामान का पैसा वापस करेगी।",
      "pa": "Zyppi ਹੋਮ ’ਤੇ ਸਰਚ ਬਾਰ (ਜਿਵੇਂ ਤੇਲ, ਚੌਲ ਜਾਂ ਆਟਾ) ਜਾਂ ਕੈਟੇਗਰੀ ਤੋਂ ਸਾਮਾਨ ਲੱਭੋ। ਕੋਈ ਸਾਮਾਨ ਖ਼ਤਮ ਹੋਵੇ ਤਾਂ ਕਾਰਟ ਵਿੱਚ ਦਿਖੇਗਾ ਕਿ ਸਟਾਕ ਵਿੱਚ ਨਹੀਂ — ਮਾਤਰਾ ਘਟਾਓ ਜਾਂ ਹਟਾ ਦਿਓ — ਜਾਂ ਹੁਣ ਉਪਲਬਧ ਨਹੀਂ। ਆਰਡਰ ਤੋਂ ਬਾਅਦ ਦੁਕਾਨ ਵਿੱਚ ਕੋਈ ਸਾਮਾਨ ਖ਼ਤਮ ਨਿਕਲੇ, ਤਾਂ ਸਾਡੀ ਟੀਮ ਉਸਨੂੰ ਬਦਲ ਦੇਵੇਗੀ ਜਾਂ ਉਸ ਸਾਮਾਨ ਦਾ ਪੈਸਾ ਵਾਪਸ ਕਰੇਗੀ।"
    },
    "keywords": [
      "out of stock",
      "unavailable",
      "not available",
      "search",
      "find",
      "stock"
    ],
    "related": [
      "multi_seller_cart",
      "missing_item"
    ]
  },
  {
    "id": "change_address",
    "action": "none",
    "title": {
      "en": "Change delivery address",
      "bn": "ঠিকানা বদলানো",
      "hi": "पता बदलें",
      "pa": "ਪਤਾ ਬਦਲੋ"
    },
    "questions": {
      "en": [
        "How do I change my address?",
        "Wrong delivery address",
        "Add a new address",
        "deliver to a different address",
        "delete a saved address",
        "set default address",
        "address galat daal diya",
        "I entered the wrong house number",
        "my address is incomplete"
      ],
      "bn": [
        "ঠিকানা কীভাবে বদলাব?",
        "ভুল ঠিকানা দিয়েছি"
      ],
      "hi": [
        "पता कैसे बदलें?",
        "मैंने गलत पता डाल दिया"
      ],
      "pa": [
        "ਪਤਾ ਕਿਵੇਂ ਬਦਲੀਏ?",
        "ਮੈਂ ਗਲਤ ਪਤਾ ਪਾ ਦਿੱਤਾ"
      ]
    },
    "answers": {
      "en": "Before ordering, tap the location bar on Zyppi Home to pick a saved address or add a new one (label it Home, Work or Other, and add a landmark if it helps). You can set a default and delete old addresses — past orders aren’t affected. If your order is already placed, tap “Talk to a person” and our team will update the rider.",
      "bn": "অর্ডারের আগে Zyppi হোমের লোকেশন বারে ট্যাপ করে সেভ করা ঠিকানা বাছুন বা নতুন যোগ করুন (হোম, ওয়ার্ক বা অন্য নাম দিন, দরকারে ল্যান্ডমার্ক লিখুন)। একটি ডিফল্ট রাখতে ও পুরোনো ঠিকানা মুছতে পারেন — আগের অর্ডারে প্রভাব পড়ে না। অর্ডার হয়ে গেলে “কারও সঙ্গে কথা বলুন”-এ ট্যাপ করুন, আমাদের টিম রাইডারকে জানিয়ে দেবে।",
      "hi": "ऑर्डर से पहले Zyppi होम पर लोकेशन बार पर टैप करके सेव किया पता चुनें या नया जोड़ें (होम, वर्क या अन्य नाम दें, ज़रूरत हो तो लैंडमार्क लिखें)। आप एक डिफ़ॉल्ट पता रख सकते हैं और पुराने पते हटा सकते हैं — पिछले ऑर्डर पर असर नहीं पड़ता। अगर ऑर्डर हो चुका है, तो “किसी से बात करें” पर टैप करें, हमारी टीम राइडर को बता देगी।",
      "pa": "ਆਰਡਰ ਤੋਂ ਪਹਿਲਾਂ Zyppi ਹੋਮ ’ਤੇ ਲੋਕੇਸ਼ਨ ਬਾਰ ’ਤੇ ਟੈਪ ਕਰਕੇ ਸੇਵ ਕੀਤਾ ਪਤਾ ਚੁਣੋ ਜਾਂ ਨਵਾਂ ਜੋੜੋ (ਹੋਮ, ਵਰਕ ਜਾਂ ਹੋਰ ਨਾਂ ਦਿਓ, ਲੋੜ ਹੋਵੇ ਤਾਂ ਲੈਂਡਮਾਰਕ ਲਿਖੋ)। ਤੁਸੀਂ ਇੱਕ ਡਿਫ਼ਾਲਟ ਪਤਾ ਰੱਖ ਸਕਦੇ ਹੋ ਅਤੇ ਪੁਰਾਣੇ ਪਤੇ ਹਟਾ ਸਕਦੇ ਹੋ — ਪਿਛਲੇ ਆਰਡਰਾਂ ’ਤੇ ਅਸਰ ਨਹੀਂ ਪੈਂਦਾ। ਜੇ ਆਰਡਰ ਹੋ ਚੁੱਕਾ ਹੈ, ਤਾਂ “ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ” ’ਤੇ ਟੈਪ ਕਰੋ, ਸਾਡੀ ਟੀਮ ਰਾਈਡਰ ਨੂੰ ਦੱਸ ਦੇਵੇਗੀ।"
    },
    "keywords": [
      "address",
      "location",
      "landmark",
      "home",
      "work",
      "default",
      "saved address"
    ],
    "related": [
      "delivery_areas",
      "talk_to_person"
    ]
  },
  {
    "id": "ratings",
    "action": "none",
    "title": {
      "en": "Rate my order",
      "bn": "অর্ডারের রেটিং",
      "hi": "ऑर्डर को रेटिंग दें",
      "pa": "ਆਰਡਰ ਨੂੰ ਰੇਟਿੰਗ ਦਿਓ"
    },
    "questions": {
      "en": [
        "How do I rate my rider?",
        "rate the seller",
        "give feedback on delivery",
        "rider was rude",
        "complain about rider behaviour"
      ],
      "bn": [
        "রাইডারকে রেটিং দেব কীভাবে?"
      ],
      "hi": [
        "राइडर को रेटिंग कैसे दें?"
      ],
      "pa": [
        "ਰਾਈਡਰ ਨੂੰ ਰੇਟਿੰਗ ਕਿਵੇਂ ਦੇਈਏ?"
      ]
    },
    "answers": {
      "en": "After your Zyppi order is delivered, open it to “Rate your delivery partner” (with tags like Polite, On time, Careful with items, Late, Rude or Items damaged) and “Rate the sellers”. Your rating helps other customers. If something serious happened, tap “Talk to a person” too.",
      "bn": "Zyppi অর্ডার ডেলিভারির পর অর্ডার খুলে “ডেলিভারি পার্টনারকে রেটিং দিন” (ভদ্র, সময়মতো, যত্নশীল, দেরি, অভদ্র বা জিনিস নষ্ট — এমন ট্যাগসহ) আর “বিক্রেতাদের রেটিং দিন”। আপনার রেটিং অন্য গ্রাহকদের সাহায্য করে। গুরুতর কিছু ঘটলে “কারও সঙ্গে কথা বলুন”-ও ট্যাপ করুন।",
      "hi": "Zyppi ऑर्डर डिलीवर होने के बाद उसे खोलकर “डिलीवरी पार्टनर को रेटिंग दें” (विनम्र, समय पर, सामान का ध्यान, देर, बदतमीज़ या सामान खराब — जैसे टैग के साथ) और “सेलर को रेटिंग दें”। आपकी रेटिंग दूसरे ग्राहकों की मदद करती है। कुछ गंभीर हुआ हो तो “किसी से बात करें” पर भी टैप करें।",
      "pa": "Zyppi ਆਰਡਰ ਡਿਲੀਵਰ ਹੋਣ ਤੋਂ ਬਾਅਦ ਇਸਨੂੰ ਖੋਲ੍ਹ ਕੇ “ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਨੂੰ ਰੇਟਿੰਗ ਦਿਓ” (ਨਿਮਰ, ਸਮੇਂ ਸਿਰ, ਸਾਮਾਨ ਦਾ ਧਿਆਨ, ਦੇਰ, ਬਦਤਮੀਜ਼ ਜਾਂ ਸਾਮਾਨ ਖ਼ਰਾਬ — ਵਰਗੇ ਟੈਗਾਂ ਨਾਲ) ਅਤੇ “ਸੇਲਰਾਂ ਨੂੰ ਰੇਟਿੰਗ ਦਿਓ”। ਤੁਹਾਡੀ ਰੇਟਿੰਗ ਹੋਰ ਗਾਹਕਾਂ ਦੀ ਮਦਦ ਕਰਦੀ ਹੈ। ਕੁਝ ਗੰਭੀਰ ਹੋਇਆ ਹੋਵੇ ਤਾਂ “ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ” ’ਤੇ ਵੀ ਟੈਪ ਕਰੋ।"
    },
    "keywords": [
      "rate",
      "rating",
      "review",
      "feedback",
      "stars",
      "rude",
      "polite"
    ],
    "related": [
      "talk_to_person"
    ]
  },
  {
    "id": "otp_login",
    "action": "none",
    "title": {
      "en": "Login problem",
      "bn": "লগইন সমস্যা",
      "hi": "लॉगिन समस्या",
      "pa": "ਲੌਗਇਨ ਸਮੱਸਿਆ"
    },
    "questions": {
      "en": [
        "I'm not getting the OTP",
        "Can't log in",
        "I forgot my password",
        "Google sign in not working",
        "OTP nahi aaya",
        "login with mobile number",
        "reset password",
        "lgin problem",
        "login",
        "log in",
        "verification code not received",
        "sms code not coming"
      ],
      "bn": [
        "OTP আসছে না",
        "লগইন করতে পারছি না",
        "পাসওয়ার্ড ভুলে গেছি"
      ],
      "hi": [
        "OTP नहीं आ रहा",
        "लॉगिन नहीं हो रहा",
        "पासवर्ड भूल गया"
      ],
      "pa": [
        "OTP ਨਹੀਂ ਆ ਰਿਹਾ",
        "ਲੌਗਇਨ ਨਹੀਂ ਹੋ ਰਿਹਾ",
        "ਪਾਸਵਰਡ ਭੁੱਲ ਗਿਆ"
      ]
    },
    "answers": {
      "en": "Zyppi doesn’t send an OTP to sign in — there is no mobile-number login. Sign in with Google, or with your email and password. If you forgot your password, tap “Forgot password” on the login screen to get a reset link by email. You can also continue as a guest to browse.",
      "bn": "Zyppi-তে সাইন ইন করতে OTP পাঠানো হয় না — মোবাইল নম্বর দিয়ে লগইন নেই। Google, অথবা ইমেল ও পাসওয়ার্ড দিয়ে সাইন ইন করুন। পাসওয়ার্ড ভুলে গেলে লগইন স্ক্রিনে “পাসওয়ার্ড ভুলে গেছেন” ট্যাপ করে ইমেলে রিসেট লিঙ্ক নিন। চাইলে গেস্ট হিসেবেও দেখতে পারেন।",
      "hi": "Zyppi में साइन इन के लिए OTP नहीं आता — मोबाइल नंबर से लॉगिन नहीं होता। Google से, या ईमेल और पासवर्ड से साइन इन करें। पासवर्ड भूल गए हों तो लॉगिन स्क्रीन पर “पासवर्ड भूल गए” पर टैप करके ईमेल पर रीसेट लिंक पाएँ। आप गेस्ट के तौर पर भी ब्राउज़ कर सकते हैं।",
      "pa": "Zyppi ਵਿੱਚ ਸਾਈਨ ਇਨ ਲਈ OTP ਨਹੀਂ ਆਉਂਦਾ — ਮੋਬਾਈਲ ਨੰਬਰ ਨਾਲ ਲੌਗਇਨ ਨਹੀਂ ਹੁੰਦਾ। Google ਨਾਲ, ਜਾਂ ਈਮੇਲ ਅਤੇ ਪਾਸਵਰਡ ਨਾਲ ਸਾਈਨ ਇਨ ਕਰੋ। ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ ਹੋ ਤਾਂ ਲੌਗਇਨ ਸਕ੍ਰੀਨ ’ਤੇ “ਪਾਸਵਰਡ ਭੁੱਲ ਗਏ” ’ਤੇ ਟੈਪ ਕਰਕੇ ਈਮੇਲ ’ਤੇ ਰੀਸੈੱਟ ਲਿੰਕ ਲਓ। ਤੁਸੀਂ ਗੈਸਟ ਵਜੋਂ ਵੀ ਦੇਖ ਸਕਦੇ ਹੋ।"
    },
    "keywords": [
      "otp",
      "login",
      "sign in",
      "password",
      "forgot",
      "google",
      "email",
      "lgin"
    ],
    "related": [
      "sign_up",
      "guest_checkout"
    ]
  },
  {
    "id": "sign_up",
    "action": "none",
    "title": {
      "en": "Create an account",
      "bn": "অ্যাকাউন্ট খুলুন",
      "hi": "अकाउंट बनाएँ",
      "pa": "ਖਾਤਾ ਬਣਾਓ"
    },
    "questions": {
      "en": [
        "How do I sign up?",
        "How do I create a Zyppi account?",
        "register",
        "new account kaise banaye",
        "why do you need my mobile number"
      ],
      "bn": [
        "কীভাবে অ্যাকাউন্ট খুলব?"
      ],
      "hi": [
        "अकाउंट कैसे बनाएँ?"
      ],
      "pa": [
        "ਖਾਤਾ ਕਿਵੇਂ ਬਣਾਈਏ?"
      ]
    },
    "answers": {
      "en": "To join Zyppi, open the app and tap “Continue with Google”, or sign up with your email and a password. After you sign up we ask for your mobile number, so your rider can call you when they arrive. It isn’t used to log in.",
      "bn": "Zyppi-তে যোগ দিতে অ্যাপ খুলে “Google দিয়ে চালিয়ে যান” ট্যাপ করুন, অথবা ইমেল ও পাসওয়ার্ড দিয়ে সাইন আপ করুন। সাইন আপের পর আমরা আপনার মোবাইল নম্বর চাই, যাতে রাইডার পৌঁছে আপনাকে ফোন করতে পারেন। এটি লগইনের জন্য নয়।",
      "hi": "Zyppi से जुड़ने के लिए ऐप खोलें और “Google से जारी रखें” पर टैप करें, या ईमेल और पासवर्ड से साइन अप करें। साइन अप के बाद हम आपका मोबाइल नंबर माँगते हैं, ताकि राइडर पहुँचकर आपको कॉल कर सके। इसका इस्तेमाल लॉगिन के लिए नहीं होता।",
      "pa": "Zyppi ਨਾਲ ਜੁੜਨ ਲਈ ਐਪ ਖੋਲ੍ਹੋ ਅਤੇ “Google ਨਾਲ ਜਾਰੀ ਰੱਖੋ” ’ਤੇ ਟੈਪ ਕਰੋ, ਜਾਂ ਈਮੇਲ ਅਤੇ ਪਾਸਵਰਡ ਨਾਲ ਸਾਈਨ ਅੱਪ ਕਰੋ। ਸਾਈਨ ਅੱਪ ਤੋਂ ਬਾਅਦ ਅਸੀਂ ਤੁਹਾਡਾ ਮੋਬਾਈਲ ਨੰਬਰ ਮੰਗਦੇ ਹਾਂ, ਤਾਂ ਜੋ ਰਾਈਡਰ ਪਹੁੰਚ ਕੇ ਤੁਹਾਨੂੰ ਕਾਲ ਕਰ ਸਕੇ। ਇਹ ਲੌਗਇਨ ਲਈ ਨਹੀਂ ਵਰਤਿਆ ਜਾਂਦਾ।"
    },
    "keywords": [
      "sign up",
      "signup",
      "register",
      "registration",
      "new account",
      "create account"
    ],
    "related": [
      "otp_login",
      "phone_number"
    ]
  },
  {
    "id": "guest_checkout",
    "action": "none",
    "title": {
      "en": "Ordering as a guest",
      "bn": "গেস্ট হিসেবে অর্ডার",
      "hi": "गेस्ट के रूप में ऑर्डर",
      "pa": "ਗੈਸਟ ਵਜੋਂ ਆਰਡਰ"
    },
    "questions": {
      "en": [
        "Can I order as a guest?",
        "It says save your account to place an order",
        "guest mode",
        "link my guest account to Google",
        "without login order"
      ],
      "bn": [
        "গেস্ট হিসেবে অর্ডার দেওয়া যাবে?"
      ],
      "hi": [
        "क्या गेस्ट बनकर ऑर्डर कर सकते हैं?"
      ],
      "pa": [
        "ਕੀ ਗੈਸਟ ਵਜੋਂ ਆਰਡਰ ਕਰ ਸਕਦੇ ਹਾਂ?"
      ]
    },
    "answers": {
      "en": "You can browse Zyppi as a guest, but to place an order you need to save your account — link Google or an email when the app asks. Everything you did as a guest (cart, addresses, favourites) stays with you, and you can then sign in on any phone. If that Google or email already has a Zyppi account, you can sign in to it instead, but your guest orders and addresses won’t move over.",
      "bn": "Zyppi গেস্ট হিসেবে দেখা যায়, কিন্তু অর্ডার দিতে অ্যাকাউন্ট সেভ করতে হয় — অ্যাপ বললে Google বা ইমেল যুক্ত করুন। গেস্ট হিসেবে যা করেছেন (কার্ট, ঠিকানা, পছন্দ) সব থেকে যায়, তারপর যেকোনো ফোনে সাইন ইন করতে পারবেন। সেই Google বা ইমেলে আগে থেকেই Zyppi অ্যাকাউন্ট থাকলে তাতে সাইন ইন করতে পারেন, তবে গেস্ট অর্ডার ও ঠিকানা সেখানে যাবে না।",
      "hi": "Zyppi को गेस्ट बनकर देख सकते हैं, लेकिन ऑर्डर करने के लिए अकाउंट सेव करना होता है — ऐप पूछे तो Google या ईमेल लिंक करें। गेस्ट के तौर पर जो किया (कार्ट, पते, पसंदीदा) सब रहता है, फिर आप किसी भी फ़ोन पर साइन इन कर सकते हैं। अगर उस Google या ईमेल पर पहले से Zyppi अकाउंट है, तो उसमें साइन इन कर सकते हैं, पर गेस्ट ऑर्डर और पते वहाँ नहीं जाएँगे।",
      "pa": "Zyppi ਨੂੰ ਗੈਸਟ ਵਜੋਂ ਦੇਖ ਸਕਦੇ ਹੋ, ਪਰ ਆਰਡਰ ਕਰਨ ਲਈ ਖਾਤਾ ਸੇਵ ਕਰਨਾ ਪੈਂਦਾ ਹੈ — ਐਪ ਪੁੱਛੇ ਤਾਂ Google ਜਾਂ ਈਮੇਲ ਲਿੰਕ ਕਰੋ। ਗੈਸਟ ਵਜੋਂ ਜੋ ਕੀਤਾ (ਕਾਰਟ, ਪਤੇ, ਪਸੰਦੀਦਾ) ਸਭ ਰਹਿੰਦਾ ਹੈ, ਫਿਰ ਤੁਸੀਂ ਕਿਸੇ ਵੀ ਫ਼ੋਨ ’ਤੇ ਸਾਈਨ ਇਨ ਕਰ ਸਕਦੇ ਹੋ। ਜੇ ਉਸ Google ਜਾਂ ਈਮੇਲ ’ਤੇ ਪਹਿਲਾਂ ਹੀ Zyppi ਖਾਤਾ ਹੈ, ਤਾਂ ਉਸ ਵਿੱਚ ਸਾਈਨ ਇਨ ਕਰ ਸਕਦੇ ਹੋ, ਪਰ ਗੈਸਟ ਆਰਡਰ ਅਤੇ ਪਤੇ ਉੱਥੇ ਨਹੀਂ ਜਾਣਗੇ।"
    },
    "keywords": [
      "guest",
      "without login",
      "save account",
      "link"
    ],
    "related": [
      "sign_up",
      "otp_login"
    ]
  },
  {
    "id": "phone_number",
    "action": "handoff",
    "title": {
      "en": "Change my mobile number",
      "bn": "মোবাইল নম্বর বদলানো",
      "hi": "मोबाइल नंबर बदलें",
      "pa": "ਮੋਬਾਈਲ ਨੰਬਰ ਬਦਲੋ"
    },
    "questions": {
      "en": [
        "How do I change my mobile number?",
        "update phone number",
        "wrong phone number on my account",
        "number change karna hai"
      ],
      "bn": [
        "মোবাইল নম্বর কীভাবে বদলাব?"
      ],
      "hi": [
        "मोबाइल नंबर कैसे बदलें?"
      ],
      "pa": [
        "ਮੋਬਾਈਲ ਨੰਬਰ ਕਿਵੇਂ ਬਦਲੀਏ?"
      ]
    },
    "answers": {
      "en": "Your mobile number on Zyppi is only used so your rider can call you at delivery. It can’t be changed in the app, so I’m connecting you to our team — they’ll update it for you.",
      "bn": "Zyppi-তে আপনার মোবাইল নম্বর শুধু ডেলিভারির সময় রাইডারের ফোন করার জন্য। অ্যাপ থেকে এটি বদলানো যায় না, তাই আপনাকে আমাদের টিমের সঙ্গে যুক্ত করছি — তারা বদলে দেবে।",
      "hi": "Zyppi पर आपका मोबाइल नंबर सिर्फ़ इसलिए है कि डिलीवरी के समय राइडर आपको कॉल कर सके। इसे ऐप से नहीं बदला जा सकता, इसलिए मैं आपको हमारी टीम से जोड़ रहा हूँ — वे इसे बदल देंगे।",
      "pa": "Zyppi ’ਤੇ ਤੁਹਾਡਾ ਮੋਬਾਈਲ ਨੰਬਰ ਸਿਰਫ਼ ਇਸ ਲਈ ਹੈ ਕਿ ਡਿਲੀਵਰੀ ਵੇਲੇ ਰਾਈਡਰ ਤੁਹਾਨੂੰ ਕਾਲ ਕਰ ਸਕੇ। ਇਸਨੂੰ ਐਪ ਤੋਂ ਨਹੀਂ ਬਦਲਿਆ ਜਾ ਸਕਦਾ, ਇਸ ਲਈ ਮੈਂ ਤੁਹਾਨੂੰ ਸਾਡੀ ਟੀਮ ਨਾਲ ਜੋੜ ਰਿਹਾ ਹਾਂ — ਉਹ ਇਸਨੂੰ ਬਦਲ ਦੇਣਗੇ।"
    },
    "keywords": [
      "phone",
      "mobile",
      "mobile number",
      "change number"
    ]
  },
  {
    "id": "account_delete",
    "action": "none",
    "title": {
      "en": "Delete my account",
      "bn": "অ্যাকাউন্ট মুছুন",
      "hi": "अकाउंट डिलीट करें",
      "pa": "ਖਾਤਾ ਮਿਟਾਓ"
    },
    "questions": {
      "en": [
        "How do I delete my account?",
        "close my Zyppi account",
        "remove my data",
        "I can't delete my account",
        "account delete karna hai"
      ],
      "bn": [
        "অ্যাকাউন্ট কীভাবে মুছব?"
      ],
      "hi": [
        "अकाउंट कैसे डिलीट करें?"
      ],
      "pa": [
        "ਖਾਤਾ ਕਿਵੇਂ ਮਿਟਾਈਏ?"
      ]
    },
    "answers": {
      "en": "You can delete your Zyppi account from your profile: tap “Delete account” and type DELETE to confirm. It permanently deletes your profile, saved addresses, cart and favourites; past orders are kept without your personal details, as required for tax records. It can’t be undone, and any wallet balance is lost. You can’t delete while an order, payment or reported problem is still in progress.",
      "bn": "প্রোফাইল থেকে Zyppi অ্যাকাউন্ট মুছতে পারেন: “অ্যাকাউন্ট মুছুন” ট্যাপ করে নিশ্চিত করতে DELETE লিখুন। এতে প্রোফাইল, সেভ করা ঠিকানা, কার্ট ও পছন্দ চিরতরে মুছে যায়; আগের অর্ডার করের হিসেবের জন্য আপনার ব্যক্তিগত তথ্য ছাড়া রাখা হয়। এটি ফেরানো যায় না, আর ওয়ালেটের টাকা চলে যায়। কোনো অর্ডার, পেমেন্ট বা জানানো সমস্যা চলাকালীন মোছা যায় না।",
      "hi": "प्रोफ़ाइल से Zyppi अकाउंट डिलीट कर सकते हैं: “अकाउंट डिलीट करें” पर टैप करें और पुष्टि के लिए DELETE लिखें। इससे आपकी प्रोफ़ाइल, सेव किए पते, कार्ट और पसंदीदा हमेशा के लिए हट जाते हैं; पिछले ऑर्डर टैक्स रिकॉर्ड के लिए आपकी निजी जानकारी के बिना रखे जाते हैं। यह वापस नहीं होता, और वॉलेट बैलेंस खत्म हो जाता है। कोई ऑर्डर, पेमेंट या शिकायत चल रही हो तो डिलीट नहीं होगा।",
      "pa": "ਪ੍ਰੋਫ਼ਾਈਲ ਤੋਂ Zyppi ਖਾਤਾ ਮਿਟਾ ਸਕਦੇ ਹੋ: “ਖਾਤਾ ਮਿਟਾਓ” ’ਤੇ ਟੈਪ ਕਰੋ ਅਤੇ ਪੱਕਾ ਕਰਨ ਲਈ DELETE ਲਿਖੋ। ਇਸ ਨਾਲ ਤੁਹਾਡੀ ਪ੍ਰੋਫ਼ਾਈਲ, ਸੇਵ ਕੀਤੇ ਪਤੇ, ਕਾਰਟ ਅਤੇ ਪਸੰਦੀਦਾ ਹਮੇਸ਼ਾ ਲਈ ਮਿਟ ਜਾਂਦੇ ਹਨ; ਪਿਛਲੇ ਆਰਡਰ ਟੈਕਸ ਰਿਕਾਰਡ ਲਈ ਤੁਹਾਡੀ ਨਿੱਜੀ ਜਾਣਕਾਰੀ ਤੋਂ ਬਿਨਾਂ ਰੱਖੇ ਜਾਂਦੇ ਹਨ। ਇਹ ਵਾਪਸ ਨਹੀਂ ਹੁੰਦਾ, ਅਤੇ ਵਾਲਿਟ ਬੈਲੇਂਸ ਖ਼ਤਮ ਹੋ ਜਾਂਦਾ ਹੈ। ਕੋਈ ਆਰਡਰ, ਭੁਗਤਾਨ ਜਾਂ ਸ਼ਿਕਾਇਤ ਚੱਲ ਰਹੀ ਹੋਵੇ ਤਾਂ ਖਾਤਾ ਨਹੀਂ ਮਿਟੇਗਾ।"
    },
    "keywords": [
      "delete",
      "remove",
      "close account",
      "deactivate",
      "data",
      "privacy"
    ],
    "related": [
      "wallet",
      "talk_to_person"
    ]
  },
  {
    "id": "talk_to_person",
    "action": "handoff",
    "hidden": true,
    "title": {
      "en": "Talk to a person",
      "bn": "কারও সঙ্গে কথা বলুন",
      "hi": "किसी से बात करें",
      "pa": "ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ"
    },
    "questions": {
      "en": [
        "I want to talk to a person",
        "Connect me to customer care",
        "Talk to an agent",
        "call me",
        "human",
        "customer care number",
        "whatsapp support",
        "support email",
        "I want to complain"
      ],
      "bn": [
        "কারও সঙ্গে কথা বলতে চাই",
        "কাস্টমার কেয়ারে যোগাযোগ করুন"
      ],
      "hi": [
        "मुझे किसी इंसान से बात करनी है",
        "कस्टमर केयर से बात कराओ"
      ],
      "pa": [
        "ਮੈਂ ਕਿਸੇ ਬੰਦੇ ਨਾਲ ਗੱਲ ਕਰਨੀ ਹੈ",
        "ਕਸਟਮਰ ਕੇਅਰ ਨਾਲ ਗੱਲ ਕਰਾਓ"
      ]
    },
    "answers": {
      "en": "Sure — I’m connecting you to the Zyppi support team.",
      "bn": "নিশ্চয়ই — আপনাকে Zyppi সাপোর্ট টিমের সঙ্গে যুক্ত করছি।",
      "hi": "ज़रूर — मैं आपको Zyppi सपोर्ट टीम से जोड़ रहा हूँ।",
      "pa": "ਜ਼ਰੂਰ — ਮੈਂ ਤੁਹਾਨੂੰ Zyppi ਸਪੋਰਟ ਟੀਮ ਨਾਲ ਜੋੜ ਰਿਹਾ ਹਾਂ।"
    },
    "keywords": [
      "agent",
      "human",
      "person",
      "support",
      "helpline",
      "complaint",
      "customer care",
      "whatsapp",
      "call"
    ]
  },
  {
    "id": "greeting",
    "action": "none",
    "hidden": true,
    "title": {
      "en": "Hi",
      "bn": "নমস্কার",
      "hi": "नमस्ते",
      "pa": "ਸਤ ਸ੍ਰੀ ਅਕਾਲ"
    },
    "questions": {
      "en": [
        "Hi",
        "Hello",
        "Hey there",
        "Good morning",
        "Good afternoon",
        "Good evening",
        "hii",
        "helo",
        "hello zyppi",
        "namaste",
        "namaskar"
      ],
      "bn": [
        "নমস্কার",
        "হ্যালো",
        "সুপ্রভাত",
        "শুভ সকাল",
        "শুভ সন্ধ্যা"
      ],
      "hi": [
        "नमस्ते",
        "हैलो",
        "सुप्रभात",
        "गुड मॉर्निंग",
        "शुभ संध्या"
      ],
      "pa": [
        "ਸਤ ਸ੍ਰੀ ਅਕਾਲ",
        "ਹੈਲੋ",
        "ਸ਼ੁਭ ਸਵੇਰ",
        "ਗੁੱਡ ਮਾਰਨਿੰਗ"
      ]
    },
    "answers": {
      "en": "Hi! I'm Zyppi's assistant. Ask me about your order, delivery, payments or refunds.",
      "bn": "নমস্কার! আমি Zyppi-র সহকারী। আপনার অর্ডার, ডেলিভারি, পেমেন্ট বা টাকা ফেরত নিয়ে জিজ্ঞেস করুন।",
      "hi": "नमस्ते! मैं Zyppi का असिस्टेंट हूँ। अपने ऑर्डर, डिलीवरी, पेमेंट या रिफ़ंड के बारे में पूछें।",
      "pa": "ਸਤ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ Zyppi ਦਾ ਸਹਾਇਕ ਹਾਂ। ਆਪਣੇ ਆਰਡਰ, ਡਿਲੀਵਰੀ, ਭੁਗਤਾਨ ਜਾਂ ਰਿਫ਼ੰਡ ਬਾਰੇ ਪੁੱਛੋ।"
    },
    "keywords": [
      "hi",
      "hello",
      "hey",
      "namaste",
      "namaskar",
      "morning",
      "evening",
      "afternoon",
      "gm"
    ],
    "related": [
      "where_is_order",
      "delivery_fee",
      "payment_methods"
    ]
  },
  {
    "id": "thanks",
    "action": "none",
    "hidden": true,
    "title": {
      "en": "Thanks",
      "bn": "ধন্যবাদ",
      "hi": "धन्यवाद",
      "pa": "ਧੰਨਵਾਦ"
    },
    "questions": {
      "en": [
        "Thank you",
        "Thanks",
        "Great, that helped",
        "ok thanks",
        "thank you so much",
        "thnx",
        "thanku",
        "dhanyavad",
        "shukriya"
      ],
      "bn": [
        "ধন্যবাদ",
        "অনেক ধন্যবাদ"
      ],
      "hi": [
        "धन्यवाद",
        "शुक्रिया",
        "बहुत धन्यवाद"
      ],
      "pa": [
        "ਧੰਨਵਾਦ",
        "ਸ਼ੁਕਰੀਆ",
        "ਬਹੁਤ ਧੰਨਵਾਦ"
      ]
    },
    "answers": {
      "en": "You're welcome! Anything else I can help with?",
      "bn": "স্বাগতম! আর কিছুতে সাহায্য করতে পারি?",
      "hi": "आपका स्वागत है! और किसी चीज़ में मदद करूँ?",
      "pa": "ਜੀ ਆਇਆਂ ਨੂੰ! ਹੋਰ ਕਿਸੇ ਚੀਜ਼ ਵਿੱਚ ਮਦਦ ਕਰਾਂ?"
    },
    "keywords": [
      "thanks",
      "thank",
      "thx",
      "thnx",
      "tq",
      "ty",
      "dhanyavad",
      "shukriya",
      "thanku"
    ]
  },
  {
    "id": "goodbye",
    "action": "none",
    "hidden": true,
    "title": {
      "en": "Bye",
      "bn": "বিদায়",
      "hi": "अलविदा",
      "pa": "ਅਲਵਿਦਾ"
    },
    "questions": {
      "en": [
        "Good night",
        "Bye",
        "Bye bye",
        "See you",
        "ok bye",
        "tata",
        "gn",
        "talk later"
      ],
      "bn": [
        "শুভ রাত্রি",
        "বিদায়",
        "আবার কথা হবে"
      ],
      "hi": [
        "शुभ रात्रि",
        "गुड नाइट",
        "अलविदा",
        "बाय"
      ],
      "pa": [
        "ਸ਼ੁਭ ਰਾਤ",
        "ਅਲਵਿਦਾ",
        "ਬਾਏ"
      ]
    },
    "answers": {
      "en": "Take care! I’m here any time you need help with a Zyppi order.",
      "bn": "ভালো থাকবেন! Zyppi অর্ডার নিয়ে সাহায্য লাগলে যেকোনো সময় আমি আছি।",
      "hi": "अपना ध्यान रखें! Zyppi ऑर्डर में मदद चाहिए तो मैं कभी भी यहाँ हूँ।",
      "pa": "ਆਪਣਾ ਖ਼ਿਆਲ ਰੱਖੋ! Zyppi ਆਰਡਰ ਵਿੱਚ ਮਦਦ ਚਾਹੀਦੀ ਹੋਵੇ ਤਾਂ ਮੈਂ ਕਦੇ ਵੀ ਇੱਥੇ ਹਾਂ।"
    },
    "keywords": [
      "bye",
      "goodbye",
      "night",
      "gn",
      "tata",
      "later"
    ]
  },
  {
    "id": "how_are_you",
    "action": "none",
    "hidden": true,
    "title": {
      "en": "How are you?",
      "bn": "কেমন আছেন?",
      "hi": "आप कैसे हैं?",
      "pa": "ਤੁਸੀਂ ਕਿਵੇਂ ਹੋ?"
    },
    "questions": {
      "en": [
        "How are you?",
        "how r u",
        "how are you doing",
        "kaise ho",
        "kemon acho",
        "whats up"
      ],
      "bn": [
        "কেমন আছেন?",
        "কেমন আছো?"
      ],
      "hi": [
        "आप कैसे हैं?",
        "कैसे हो?"
      ],
      "pa": [
        "ਤੁਸੀਂ ਕਿਵੇਂ ਹੋ?",
        "ਕੀ ਹਾਲ ਹੈ?"
      ]
    },
    "answers": {
      "en": "I’m doing great, thanks for asking! How can I help with your Zyppi order today?",
      "bn": "আমি ভালো আছি, জিজ্ঞেস করার জন্য ধন্যবাদ! আজ আপনার Zyppi অর্ডারে কীভাবে সাহায্য করতে পারি?",
      "hi": "मैं बढ़िया हूँ, पूछने के लिए शुक्रिया! आज आपके Zyppi ऑर्डर में कैसे मदद करूँ?",
      "pa": "ਮੈਂ ਵਧੀਆ ਹਾਂ, ਪੁੱਛਣ ਲਈ ਸ਼ੁਕਰੀਆ! ਅੱਜ ਤੁਹਾਡੇ Zyppi ਆਰਡਰ ਵਿੱਚ ਕਿਵੇਂ ਮਦਦ ਕਰਾਂ?"
    },
    "keywords": [
      "how are you",
      "kaise",
      "kemon",
      "sup"
    ],
    "related": [
      "where_is_order",
      "refund",
      "payment_methods"
    ]
  },
  {
    "id": "about_bot",
    "action": "none",
    "hidden": true,
    "title": {
      "en": "Who are you?",
      "bn": "আপনি কে?",
      "hi": "आप कौन हैं?",
      "pa": "ਤੁਸੀਂ ਕੌਣ ਹੋ?"
    },
    "questions": {
      "en": [
        "Who are you?",
        "Are you a bot?",
        "Are you a real person?",
        "What can you do?",
        "what can you help with",
        "is this automatic"
      ],
      "bn": [
        "আপনি কে?",
        "আপনি কি রোবট?",
        "আপনি কী করতে পারেন?"
      ],
      "hi": [
        "आप कौन हैं?",
        "क्या आप बॉट हैं?",
        "आप क्या कर सकते हैं?"
      ],
      "pa": [
        "ਤੁਸੀਂ ਕੌਣ ਹੋ?",
        "ਕੀ ਤੁਸੀਂ ਬੋਟ ਹੋ?",
        "ਤੁਸੀਂ ਕੀ ਕਰ ਸਕਦੇ ਹੋ?"
      ]
    },
    "answers": {
      "en": "I’m Zyppi’s automatic assistant. I can help with tracking your order, delivery codes, payments, cancelling, refunds and reporting a problem with an item. For anything I can’t sort out, tap “Talk to a person” and our support team will reply here.",
      "bn": "আমি Zyppi-র স্বয়ংক্রিয় সহকারী। অর্ডার ট্র্যাক, ডেলিভারি কোড, পেমেন্ট, বাতিল, টাকা ফেরত আর জিনিসে সমস্যা জানাতে সাহায্য করতে পারি। আমি না পারলে “কারও সঙ্গে কথা বলুন” ট্যাপ করুন, আমাদের সাপোর্ট টিম এখানেই উত্তর দেবে।",
      "hi": "मैं Zyppi का ऑटोमैटिक असिस्टेंट हूँ। ऑर्डर ट्रैक करने, डिलीवरी कोड, पेमेंट, कैंसिल, रिफ़ंड और सामान की शिकायत में मदद कर सकता हूँ। जो मैं न सुलझा पाऊँ, उसके लिए “किसी से बात करें” पर टैप करें, हमारी सपोर्ट टीम यहीं जवाब देगी।",
      "pa": "ਮੈਂ Zyppi ਦਾ ਆਟੋਮੈਟਿਕ ਸਹਾਇਕ ਹਾਂ। ਆਰਡਰ ਟ੍ਰੈਕ ਕਰਨ, ਡਿਲੀਵਰੀ ਕੋਡ, ਭੁਗਤਾਨ, ਰੱਦ ਕਰਨ, ਰਿਫ਼ੰਡ ਅਤੇ ਸਾਮਾਨ ਦੀ ਸ਼ਿਕਾਇਤ ਵਿੱਚ ਮਦਦ ਕਰ ਸਕਦਾ ਹਾਂ। ਜੋ ਮੈਂ ਨਾ ਸੁਲਝਾ ਸਕਾਂ, ਉਸ ਲਈ “ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ” ’ਤੇ ਟੈਪ ਕਰੋ, ਸਾਡੀ ਸਪੋਰਟ ਟੀਮ ਇੱਥੇ ਹੀ ਜਵਾਬ ਦੇਵੇਗੀ।"
    },
    "keywords": [
      "bot",
      "robot",
      "assistant",
      "human",
      "real person",
      "help"
    ],
    "related": [
      "where_is_order",
      "refund",
      "talk_to_person"
    ]
  },
  {
    "id": "about_zyppi",
    "action": "none",
    "title": {
      "en": "What is Zyppi?",
      "bn": "Zyppi কী?",
      "hi": "Zyppi क्या है?",
      "pa": "Zyppi ਕੀ ਹੈ?"
    },
    "questions": {
      "en": [
        "What is Zyppi?",
        "What do you sell?",
        "What can I buy on Zyppi?",
        "Is Zyppi a grocery app?",
        "how does zyppi work"
      ],
      "bn": [
        "Zyppi কী?",
        "আপনারা কী বিক্রি করেন?"
      ],
      "hi": [
        "Zyppi क्या है?",
        "आप क्या बेचते हैं?"
      ],
      "pa": [
        "Zyppi ਕੀ ਹੈ?",
        "ਤੁਸੀਂ ਕੀ ਵੇਚਦੇ ਹੋ?"
      ]
    },
    "answers": {
      "en": "Zyppi is a quick-delivery app for groceries and daily essentials. You order from Zyppi stores and local sellers near you, and a Zyppi delivery partner brings it to your door — choose Express for the fastest delivery or schedule a later slot. Pay by UPI, card, Zyppi wallet or cash on delivery.",
      "bn": "Zyppi হলো মুদি ও রোজকার জিনিসের দ্রুত ডেলিভারি অ্যাপ। কাছের Zyppi স্টোর ও স্থানীয় বিক্রেতাদের থেকে অর্ডার দিন, Zyppi ডেলিভারি পার্টনার দরজায় পৌঁছে দেবেন — সবচেয়ে দ্রুত পেতে এক্সপ্রেস, বা পরের কোনো সময় বাছুন। UPI, কার্ড, Zyppi ওয়ালেট বা ক্যাশ অন ডেলিভারিতে পেমেন্ট করুন।",
      "hi": "Zyppi किराना और रोज़मर्रा की चीज़ों की तेज़ डिलीवरी वाला ऐप है। पास के Zyppi स्टोर और लोकल सेलर से ऑर्डर करें, Zyppi डिलीवरी पार्टनर आपके दरवाज़े तक लाएगा — सबसे तेज़ के लिए एक्सप्रेस चुनें या बाद का स्लॉट। UPI, कार्ड, Zyppi वॉलेट या कैश ऑन डिलीवरी से पेमेंट करें।",
      "pa": "Zyppi ਕਰਿਆਨੇ ਅਤੇ ਰੋਜ਼ਾਨਾ ਚੀਜ਼ਾਂ ਦੀ ਤੇਜ਼ ਡਿਲੀਵਰੀ ਵਾਲੀ ਐਪ ਹੈ। ਨੇੜੇ ਦੇ Zyppi ਸਟੋਰ ਅਤੇ ਲੋਕਲ ਸੇਲਰਾਂ ਤੋਂ ਆਰਡਰ ਕਰੋ, Zyppi ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਤੁਹਾਡੇ ਦਰਵਾਜ਼ੇ ਤੱਕ ਲਿਆਵੇਗਾ — ਸਭ ਤੋਂ ਤੇਜ਼ ਲਈ ਐਕਸਪ੍ਰੈਸ ਜਾਂ ਬਾਅਦ ਦਾ ਸਲਾਟ ਚੁਣੋ। UPI, ਕਾਰਡ, Zyppi ਵਾਲਿਟ ਜਾਂ ਕੈਸ਼ ਆਨ ਡਿਲੀਵਰੀ ਨਾਲ ਭੁਗਤਾਨ ਕਰੋ।"
    },
    "keywords": [
      "zyppi",
      "grocery",
      "groceries",
      "sell",
      "about",
      "what is"
    ],
    "related": [
      "delivery_areas",
      "payment_methods",
      "schedule_slot"
    ]
  },
  {
    "id": "acknowledge",
    "action": "none",
    "hidden": true,
    "title": {
      "en": "Okay",
      "bn": "ঠিক আছে",
      "hi": "ठीक है",
      "pa": "ਠੀਕ ਹੈ"
    },
    "questions": {
      "en": [
        "ok",
        "okay",
        "got it",
        "fine",
        "alright",
        "hmm",
        "accha",
        "thik hai",
        "thik ache",
        "cool"
      ],
      "bn": [
        "ঠিক আছে",
        "আচ্ছা"
      ],
      "hi": [
        "ठीक है",
        "अच्छा",
        "ओके"
      ],
      "pa": [
        "ਠੀਕ ਹੈ",
        "ਅੱਛਾ",
        "ਓਕੇ"
      ]
    },
    "answers": {
      "en": "Great! Is there anything else I can help you with?",
      "bn": "বেশ! আর কিছুতে সাহায্য করতে পারি?",
      "hi": "बढ़िया! क्या मैं किसी और चीज़ में मदद कर सकता हूँ?",
      "pa": "ਵਧੀਆ! ਕੀ ਮੈਂ ਕਿਸੇ ਹੋਰ ਚੀਜ਼ ਵਿੱਚ ਮਦਦ ਕਰ ਸਕਦਾ ਹਾਂ?"
    },
    "keywords": [
      "ok",
      "okay",
      "fine",
      "hmm",
      "accha",
      "thik",
      "cool"
    ],
    "related": [
      "where_is_order",
      "refund",
      "talk_to_person"
    ]
  },
  {
    "id": "compliment",
    "action": "none",
    "hidden": true,
    "title": {
      "en": "Thanks for the kind words",
      "bn": "প্রশংসার জন্য ধন্যবাদ",
      "hi": "तारीफ़ के लिए शुक्रिया",
      "pa": "ਤਾਰੀਫ਼ ਲਈ ਸ਼ੁਕਰੀਆ"
    },
    "questions": {
      "en": [
        "great service",
        "you guys are awesome",
        "nice app",
        "love zyppi",
        "fast delivery thanks",
        "good job",
        "very helpful"
      ],
      "bn": [
        "দারুণ সার্ভিস",
        "খুব ভালো অ্যাপ"
      ],
      "hi": [
        "बहुत बढ़िया सर्विस",
        "अच्छा ऐप है"
      ],
      "pa": [
        "ਬਹੁਤ ਵਧੀਆ ਸਰਵਿਸ",
        "ਵਧੀਆ ਐਪ ਹੈ"
      ]
    },
    "answers": {
      "en": "Thank you, that means a lot to us! You can also rate your delivery partner and sellers on the order screen — it helps other customers.",
      "bn": "অনেক ধন্যবাদ, এটা আমাদের কাছে অনেক! অর্ডার স্ক্রিনে ডেলিভারি পার্টনার ও বিক্রেতাদের রেটিংও দিতে পারেন — এতে অন্য গ্রাহকদের সুবিধা হয়।",
      "hi": "बहुत शुक्रिया, यह हमारे लिए बहुत मायने रखता है! ऑर्डर स्क्रीन पर डिलीवरी पार्टनर और सेलर को रेटिंग भी दे सकते हैं — इससे दूसरे ग्राहकों को मदद मिलती है।",
      "pa": "ਬਹੁਤ ਸ਼ੁਕਰੀਆ, ਇਹ ਸਾਡੇ ਲਈ ਬਹੁਤ ਮਾਇਨੇ ਰੱਖਦਾ ਹੈ! ਆਰਡਰ ਸਕ੍ਰੀਨ ’ਤੇ ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਅਤੇ ਸੇਲਰਾਂ ਨੂੰ ਰੇਟਿੰਗ ਵੀ ਦੇ ਸਕਦੇ ਹੋ — ਇਸ ਨਾਲ ਹੋਰ ਗਾਹਕਾਂ ਦੀ ਮਦਦ ਹੁੰਦੀ ਹੈ।"
    },
    "keywords": [
      "great",
      "awesome",
      "nice",
      "love",
      "good job",
      "helpful",
      "excellent",
      "best"
    ],
    "related": [
      "ratings"
    ]
  },
  {
    "id": "complaint",
    "action": "handoff",
    "hidden": true,
    "title": {
      "en": "I’m not happy",
      "bn": "আমি খুশি নই",
      "hi": "मैं खुश नहीं हूँ",
      "pa": "ਮੈਂ ਖ਼ੁਸ਼ ਨਹੀਂ ਹਾਂ"
    },
    "questions": {
      "en": [
        "worst service ever",
        "you are useless",
        "I am very angry",
        "very bad experience",
        "bakwas service",
        "this is unacceptable",
        "your bot is stupid",
        "this is a fraud",
        "fraud app",
        "I am not happy with Zyppi"
      ],
      "bn": [
        "খুব বাজে সার্ভিস",
        "আমি খুব রেগে আছি"
      ],
      "hi": [
        "बहुत बेकार सर्विस है",
        "मैं बहुत नाराज़ हूँ"
      ],
      "pa": [
        "ਬਹੁਤ ਮਾੜੀ ਸਰਵਿਸ",
        "ਮੈਂ ਬਹੁਤ ਨਾਰਾਜ਼ ਹਾਂ"
      ]
    },
    "answers": {
      "en": "I’m really sorry you’ve had a bad experience with Zyppi. I’m passing this chat to our support team so a person can look into it right away.",
      "bn": "Zyppi-তে আপনার খারাপ অভিজ্ঞতার জন্য সত্যিই দুঃখিত। চ্যাটটি আমাদের সাপোর্ট টিমকে দিচ্ছি, যাতে একজন মানুষ এখনই বিষয়টি দেখেন।",
      "hi": "Zyppi के साथ आपके बुरे अनुभव के लिए सच में माफ़ी चाहता हूँ। मैं यह चैट हमारी सपोर्ट टीम को दे रहा हूँ, ताकि कोई तुरंत इसे देखे।",
      "pa": "Zyppi ਨਾਲ ਤੁਹਾਡੇ ਮਾੜੇ ਤਜਰਬੇ ਲਈ ਸੱਚਮੁੱਚ ਮਾਫ਼ੀ। ਮੈਂ ਇਹ ਚੈਟ ਸਾਡੀ ਸਪੋਰਟ ਟੀਮ ਨੂੰ ਦੇ ਰਿਹਾ ਹਾਂ, ਤਾਂ ਜੋ ਕੋਈ ਤੁਰੰਤ ਇਸਨੂੰ ਦੇਖੇ।"
    },
    "keywords": [
      "worst",
      "useless",
      "angry",
      "bad",
      "bakwas",
      "pathetic",
      "terrible",
      "disappointed",
      "unhappy",
      "stupid"
    ]
  },
  {
    "id": "app_issue",
    "action": "none",
    "title": {
      "en": "The app isn’t working",
      "bn": "অ্যাপ কাজ করছে না",
      "hi": "ऐप काम नहीं कर रहा",
      "pa": "ਐਪ ਕੰਮ ਨਹੀਂ ਕਰ ਰਹੀ"
    },
    "questions": {
      "en": [
        "The app keeps crashing",
        "app is not opening",
        "app is very slow",
        "screen is blank",
        "app hang ho raha hai",
        "app not loading"
      ],
      "bn": [
        "অ্যাপ বারবার বন্ধ হয়ে যাচ্ছে",
        "অ্যাপ খুলছে না"
      ],
      "hi": [
        "ऐप बार-बार बंद हो रहा है",
        "ऐप नहीं खुल रहा"
      ],
      "pa": [
        "ਐਪ ਵਾਰ-ਵਾਰ ਬੰਦ ਹੋ ਰਹੀ ਹੈ",
        "ਐਪ ਨਹੀਂ ਖੁੱਲ੍ਹ ਰਹੀ"
      ]
    },
    "answers": {
      "en": "Sorry about that! Please update Zyppi from the Play Store, then close the app fully and open it again, and check that your internet is working. If it still doesn’t work, tap “Talk to a person” and tell us what you see — a screenshot helps.",
      "bn": "এর জন্য দুঃখিত! Play Store থেকে Zyppi আপডেট করুন, তারপর অ্যাপ পুরো বন্ধ করে আবার খুলুন, আর ইন্টারনেট চলছে কি না দেখুন। তবুও না চললে “কারও সঙ্গে কথা বলুন” ট্যাপ করে কী দেখছেন জানান — স্ক্রিনশট দিলে ভালো হয়।",
      "hi": "इसके लिए माफ़ी! Play Store से Zyppi अपडेट करें, फिर ऐप पूरी तरह बंद करके दोबारा खोलें, और देखें कि इंटरनेट चल रहा है। फिर भी न चले तो “किसी से बात करें” पर टैप करके बताएँ कि क्या दिख रहा है — स्क्रीनशॉट से मदद मिलती है।",
      "pa": "ਇਸ ਲਈ ਮਾਫ਼ੀ! Play Store ਤੋਂ Zyppi ਅੱਪਡੇਟ ਕਰੋ, ਫਿਰ ਐਪ ਪੂਰੀ ਤਰ੍ਹਾਂ ਬੰਦ ਕਰਕੇ ਦੁਬਾਰਾ ਖੋਲ੍ਹੋ, ਅਤੇ ਦੇਖੋ ਕਿ ਇੰਟਰਨੈੱਟ ਚੱਲ ਰਿਹਾ ਹੈ। ਫਿਰ ਵੀ ਨਾ ਚੱਲੇ ਤਾਂ “ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ” ’ਤੇ ਟੈਪ ਕਰਕੇ ਦੱਸੋ ਕਿ ਕੀ ਦਿਖ ਰਿਹਾ ਹੈ — ਸਕ੍ਰੀਨਸ਼ਾਟ ਨਾਲ ਮਦਦ ਮਿਲਦੀ ਹੈ।"
    },
    "keywords": [
      "crash",
      "crashing",
      "hang",
      "slow",
      "blank",
      "not opening",
      "loading",
      "bug",
      "stuck"
    ],
    "related": [
      "cant_order",
      "talk_to_person"
    ]
  }
];
