import type { Lang } from "./lang";

/**
 * The bot's own sentences in the app's four languages. Topic answers live
 * in kb/seed.ts. bn / hi / pa need native-speaker review before launch.
 */
type Copy = {
  welcome: string;
  welcomeOrder: (shortId: string) => string;
  didYouMean: string;
  unknown: string;
  handoff: string;
  noOrder: string;
  status: Record<string, (shortId: string) => string>;
  arrivingIn: (minutes: number) => string;
  runningLate: string;
  rateLimited: string;
  error: string;
  talkToPerson: string;
  agentReplyPush: string;
};

export const COPY: Record<Lang, Copy> = {
  en: {
    welcome: "Hi! I'm Zyppi's assistant. Ask me anything about your orders, delivery, payments or refunds.",
    welcomeOrder: (id) => `Hi! I'm Zyppi's assistant. How can I help with order #${id}?`,
    didYouMean: "I'm not sure I got that. Did you mean one of these?",
    unknown: "Sorry, I can't answer that one yet. Would you like to talk to our team?",
    handoff:
      "I've passed this chat to our team — they'll reply here. For faster help you can also WhatsApp or call us.",
    noOrder: "I can't find a recent order on your account.",
    status: {
      placed: (id) => `Order #${id} is confirmed and the store is getting it ready.`,
      packed: (id) => `Order #${id} is packed and waiting for a delivery partner.`,
      out_for_delivery: (id) => `Order #${id} is on its way to you.`,
      delivered: (id) => `Order #${id} has been delivered.`,
      cancelled: (id) =>
        `Order #${id} was cancelled. If you paid online, the refund goes back to your original payment method.`,
    },
    arrivingIn: (m) => `It should reach you in about ${m} min.`,
    runningLate: "It's taking longer than expected — sorry about that.",
    rateLimited: "You're sending messages very quickly. Give me a moment and try again.",
    error: "Something went wrong on my side. You can talk to our team instead.",
    talkToPerson: "Talk to a person",
    agentReplyPush: "Zyppi support replied",
  },
  bn: {
    welcome: "নমস্কার! আমি Zyppi-র সহকারী। আপনার অর্ডার, ডেলিভারি, পেমেন্ট বা টাকা ফেরত নিয়ে যা খুশি জিজ্ঞেস করুন।",
    welcomeOrder: (id) => `নমস্কার! আমি Zyppi-র সহকারী। অর্ডার #${id} নিয়ে কীভাবে সাহায্য করতে পারি?`,
    didYouMean: "ঠিক বুঝতে পারলাম না। আপনি কি এগুলোর কোনোটা জানতে চাইছেন?",
    unknown: "দুঃখিত, এর উত্তর এখনও আমার জানা নেই। আমাদের টিমের সঙ্গে কথা বলবেন?",
    handoff:
      "এই চ্যাটটি আমাদের টিমের কাছে পাঠিয়েছি — তারা এখানেই উত্তর দেবে। তাড়াতাড়ি সাহায্যের জন্য WhatsApp বা ফোনও করতে পারেন।",
    noOrder: "আপনার অ্যাকাউন্টে সাম্প্রতিক কোনো অর্ডার পাচ্ছি না।",
    status: {
      placed: (id) => `অর্ডার #${id} কনফার্ম হয়েছে, দোকান সেটি তৈরি করছে।`,
      packed: (id) => `অর্ডার #${id} প্যাক হয়ে গেছে, ডেলিভারি পার্টনারের অপেক্ষায়।`,
      out_for_delivery: (id) => `অর্ডার #${id} আপনার কাছে আসছে।`,
      delivered: (id) => `অর্ডার #${id} ডেলিভারি হয়ে গেছে।`,
      cancelled: (id) =>
        `অর্ডার #${id} বাতিল হয়েছে। অনলাইনে পেমেন্ট করে থাকলে টাকা যে মাধ্যমে দিয়েছিলেন সেখানেই ফেরত যাবে।`,
    },
    arrivingIn: (m) => `প্রায় ${m} মিনিটের মধ্যে পৌঁছে যাওয়ার কথা।`,
    runningLate: "প্রত্যাশার চেয়ে বেশি সময় লাগছে — এর জন্য দুঃখিত।",
    rateLimited: "আপনি খুব তাড়াতাড়ি মেসেজ পাঠাচ্ছেন। একটু অপেক্ষা করে আবার চেষ্টা করুন।",
    error: "আমার দিকে কিছু সমস্যা হয়েছে। চাইলে আমাদের টিমের সঙ্গে কথা বলতে পারেন।",
    talkToPerson: "কারও সঙ্গে কথা বলুন",
    agentReplyPush: "Zyppi সাপোর্ট উত্তর দিয়েছে",
  },
  hi: {
    welcome: "नमस्ते! मैं Zyppi का असिस्टेंट हूँ। अपने ऑर्डर, डिलीवरी, पेमेंट या रिफ़ंड के बारे में कुछ भी पूछें।",
    welcomeOrder: (id) => `नमस्ते! मैं Zyppi का असिस्टेंट हूँ। ऑर्डर #${id} में कैसे मदद करूँ?`,
    didYouMean: "मैं ठीक से समझ नहीं पाया। क्या आप इनमें से कुछ पूछना चाहते हैं?",
    unknown: "माफ़ कीजिए, इसका जवाब अभी मेरे पास नहीं है। क्या आप हमारी टीम से बात करना चाहेंगे?",
    handoff:
      "मैंने यह चैट हमारी टीम को भेज दी है — वे यहीं जवाब देंगे। जल्दी मदद के लिए आप WhatsApp या कॉल भी कर सकते हैं।",
    noOrder: "आपके अकाउंट में कोई हाल का ऑर्डर नहीं मिला।",
    status: {
      placed: (id) => `ऑर्डर #${id} कन्फ़र्म हो गया है और स्टोर उसे तैयार कर रहा है।`,
      packed: (id) => `ऑर्डर #${id} पैक हो गया है और डिलीवरी पार्टनर का इंतज़ार है।`,
      out_for_delivery: (id) => `ऑर्डर #${id} आपके पास आ रहा है।`,
      delivered: (id) => `ऑर्डर #${id} डिलीवर हो गया है।`,
      cancelled: (id) =>
        `ऑर्डर #${id} कैंसिल हो गया। अगर आपने ऑनलाइन पेमेंट किया था, तो रिफ़ंड उसी तरीके में वापस जाएगा।`,
    },
    arrivingIn: (m) => `लगभग ${m} मिनट में पहुँच जाना चाहिए।`,
    runningLate: "उम्मीद से ज़्यादा समय लग रहा है — इसके लिए माफ़ी।",
    rateLimited: "आप बहुत जल्दी-जल्दी मैसेज भेज रहे हैं। थोड़ा रुककर फिर कोशिश करें।",
    error: "मेरी तरफ़ से कुछ गड़बड़ हुई। आप हमारी टीम से बात कर सकते हैं।",
    talkToPerson: "किसी से बात करें",
    agentReplyPush: "Zyppi सपोर्ट ने जवाब दिया",
  },
  pa: {
    welcome: "ਸਤ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ Zyppi ਦਾ ਸਹਾਇਕ ਹਾਂ। ਆਪਣੇ ਆਰਡਰ, ਡਿਲੀਵਰੀ, ਭੁਗਤਾਨ ਜਾਂ ਰਿਫ਼ੰਡ ਬਾਰੇ ਕੁਝ ਵੀ ਪੁੱਛੋ।",
    welcomeOrder: (id) => `ਸਤ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ Zyppi ਦਾ ਸਹਾਇਕ ਹਾਂ। ਆਰਡਰ #${id} ਵਿੱਚ ਕਿਵੇਂ ਮਦਦ ਕਰਾਂ?`,
    didYouMean: "ਮੈਂ ਠੀਕ ਤਰ੍ਹਾਂ ਸਮਝ ਨਹੀਂ ਸਕਿਆ। ਕੀ ਤੁਸੀਂ ਇਨ੍ਹਾਂ ਵਿੱਚੋਂ ਕੁਝ ਪੁੱਛਣਾ ਚਾਹੁੰਦੇ ਹੋ?",
    unknown: "ਮਾਫ਼ ਕਰਨਾ, ਇਸ ਦਾ ਜਵਾਬ ਅਜੇ ਮੇਰੇ ਕੋਲ ਨਹੀਂ ਹੈ। ਕੀ ਤੁਸੀਂ ਸਾਡੀ ਟੀਮ ਨਾਲ ਗੱਲ ਕਰਨਾ ਚਾਹੋਗੇ?",
    handoff:
      "ਮੈਂ ਇਹ ਚੈਟ ਸਾਡੀ ਟੀਮ ਨੂੰ ਭੇਜ ਦਿੱਤੀ ਹੈ — ਉਹ ਇੱਥੇ ਹੀ ਜਵਾਬ ਦੇਣਗੇ। ਜਲਦੀ ਮਦਦ ਲਈ ਤੁਸੀਂ WhatsApp ਜਾਂ ਕਾਲ ਵੀ ਕਰ ਸਕਦੇ ਹੋ।",
    noOrder: "ਤੁਹਾਡੇ ਖਾਤੇ ਵਿੱਚ ਕੋਈ ਹਾਲੀਆ ਆਰਡਰ ਨਹੀਂ ਮਿਲਿਆ।",
    status: {
      placed: (id) => `ਆਰਡਰ #${id} ਪੱਕਾ ਹੋ ਗਿਆ ਹੈ ਅਤੇ ਸਟੋਰ ਉਸ ਨੂੰ ਤਿਆਰ ਕਰ ਰਿਹਾ ਹੈ।`,
      packed: (id) => `ਆਰਡਰ #${id} ਪੈਕ ਹੋ ਗਿਆ ਹੈ ਅਤੇ ਡਿਲੀਵਰੀ ਪਾਰਟਨਰ ਦੀ ਉਡੀਕ ਹੈ।`,
      out_for_delivery: (id) => `ਆਰਡਰ #${id} ਤੁਹਾਡੇ ਵੱਲ ਆ ਰਿਹਾ ਹੈ।`,
      delivered: (id) => `ਆਰਡਰ #${id} ਡਿਲੀਵਰ ਹੋ ਗਿਆ ਹੈ।`,
      cancelled: (id) =>
        `ਆਰਡਰ #${id} ਰੱਦ ਹੋ ਗਿਆ। ਜੇ ਤੁਸੀਂ ਔਨਲਾਈਨ ਭੁਗਤਾਨ ਕੀਤਾ ਸੀ, ਤਾਂ ਰਿਫ਼ੰਡ ਉਸੇ ਤਰੀਕੇ ਵਿੱਚ ਵਾਪਸ ਜਾਵੇਗਾ।`,
    },
    arrivingIn: (m) => `ਲਗਭਗ ${m} ਮਿੰਟ ਵਿੱਚ ਪਹੁੰਚ ਜਾਣਾ ਚਾਹੀਦਾ ਹੈ।`,
    runningLate: "ਉਮੀਦ ਤੋਂ ਵੱਧ ਸਮਾਂ ਲੱਗ ਰਿਹਾ ਹੈ — ਇਸ ਲਈ ਮਾਫ਼ੀ।",
    rateLimited: "ਤੁਸੀਂ ਬਹੁਤ ਤੇਜ਼ੀ ਨਾਲ ਸੁਨੇਹੇ ਭੇਜ ਰਹੇ ਹੋ। ਥੋੜ੍ਹਾ ਰੁਕ ਕੇ ਫਿਰ ਕੋਸ਼ਿਸ਼ ਕਰੋ।",
    error: "ਮੇਰੇ ਵੱਲੋਂ ਕੁਝ ਗੜਬੜ ਹੋਈ। ਤੁਸੀਂ ਸਾਡੀ ਟੀਮ ਨਾਲ ਗੱਲ ਕਰ ਸਕਦੇ ਹੋ।",
    talkToPerson: "ਕਿਸੇ ਨਾਲ ਗੱਲ ਕਰੋ",
    agentReplyPush: "Zyppi ਸਹਾਇਤਾ ਨੇ ਜਵਾਬ ਦਿੱਤਾ",
  },
};

/** Same rule as the app's shortOrderId(): first UUID block, upper-cased. */
export function shortOrderId(id: string): string {
  return /^[0-9a-f]{8}-/i.test(id) ? id.slice(0, 8).toUpperCase() : id;
}

/** "Order #3F2A9C1B is on its way to you. It should reach you in about 9 min." */
export function orderStatusText(
  lang: Lang,
  order: { id: string; status: string; placedAtMs: number | null; etaMinutes: number | null },
  nowMs: number,
): string {
  const copy = COPY[lang];
  const id = shortOrderId(order.id);
  const line = (copy.status[order.status] ?? copy.status.placed)(id);
  if (order.status === "delivered" || order.status === "cancelled") return line;
  if (order.etaMinutes == null || order.placedAtMs == null) return line;
  const remaining = Math.ceil(order.etaMinutes - (nowMs - order.placedAtMs) / 60000);
  return `${line} ${remaining > 0 ? copy.arrivingIn(remaining) : copy.runningLate}`;
}
