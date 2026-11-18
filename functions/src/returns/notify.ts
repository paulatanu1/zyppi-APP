import { logger } from "firebase-functions";
import { db } from "../shared/firebase";
import { pushOrderCustomer } from "../push";
import { isLang, type Lang } from "../support/lang";
import { CHATS, postMessages } from "../support/bot";

/**
 * What the customer is told at each step of a claim / return: a push (and
 * notification-list entry) and, when the claim started in the support
 * chat, a message there too. bn / hi / pa need native-speaker review.
 */
export type ReturnNote =
  | "claimAutoReturn"
  | "claimForReview"
  | "riderAssigned"
  | "riderAtDoor"
  | "notHomeFirst"
  | "pickedUp"
  | "refunded"
  | "replacementSent"
  | "review"
  | "failed";

type Text = { title: string; body: string };
type Args = { amount?: string; code?: string };

const T: Record<ReturnNote, Record<Lang, (a: Args) => Text>> = {
  claimAutoReturn: {
    en: () => ({ title: "Return booked", body: "A rider will come to collect the item. Show them the pickup code in the app. Your refund goes out as soon as the store receives it." }),
    bn: () => ({ title: "রিটার্ন বুক হয়েছে", body: "একজন রাইডার জিনিসটি নিতে আসবেন। অ্যাপের পিকআপ কোডটি দেখান। দোকানে পৌঁছালেই রিফান্ড হবে।" }),
    hi: () => ({ title: "रिटर्न बुक हो गया", body: "एक राइडर सामान लेने आएगा। उसे ऐप में पिकअप कोड दिखाएँ। दुकान पर पहुँचते ही रिफ़ंड हो जाएगा।" }),
    pa: () => ({ title: "ਰਿਟਰਨ ਬੁੱਕ ਹੋ ਗਈ", body: "ਇੱਕ ਰਾਈਡਰ ਸਾਮਾਨ ਲੈਣ ਆਵੇਗਾ। ਉਸ ਨੂੰ ਐਪ ਵਿੱਚ ਪਿਕਅੱਪ ਕੋਡ ਦਿਖਾਓ। ਦੁਕਾਨ 'ਤੇ ਪਹੁੰਚਦੇ ਹੀ ਰਿਫੰਡ ਹੋ ਜਾਵੇਗਾ।" }),
  },
  claimForReview: {
    en: () => ({ title: "Report received", body: "Our team will check it and get back to you soon." }),
    bn: () => ({ title: "অভিযোগ পেয়েছি", body: "আমাদের টিম দেখে শীঘ্রই জানাবে।" }),
    hi: () => ({ title: "शिकायत मिल गई", body: "हमारी टीम जाँच करके जल्द बताएगी।" }),
    pa: () => ({ title: "ਸ਼ਿਕਾਇਤ ਮਿਲ ਗਈ", body: "ਸਾਡੀ ਟੀਮ ਜਾਂਚ ਕਰਕੇ ਜਲਦੀ ਦੱਸੇਗੀ।" }),
  },
  riderAssigned: {
    en: () => ({ title: "Rider on the way", body: "A rider is coming to collect your return." }),
    bn: () => ({ title: "রাইডার আসছেন", body: "আপনার রিটার্ন নিতে একজন রাইডার আসছেন।" }),
    hi: () => ({ title: "राइडर आ रहा है", body: "आपका रिटर्न लेने एक राइडर आ रहा है।" }),
    pa: () => ({ title: "ਰਾਈਡਰ ਆ ਰਿਹਾ ਹੈ", body: "ਤੁਹਾਡੀ ਰਿਟਰਨ ਲੈਣ ਇੱਕ ਰਾਈਡਰ ਆ ਰਿਹਾ ਹੈ।" }),
  },
  riderAtDoor: {
    en: () => ({ title: "Rider at your door", body: "Hand over the item and tell them your pickup code." }),
    bn: () => ({ title: "রাইডার দরজায়", body: "জিনিসটি দিন আর পিকআপ কোড বলুন।" }),
    hi: () => ({ title: "राइडर दरवाज़े पर", body: "सामान दें और पिकअप कोड बताएँ।" }),
    pa: () => ({ title: "ਰਾਈਡਰ ਦਰਵਾਜ਼ੇ 'ਤੇ", body: "ਸਾਮਾਨ ਦਿਓ ਅਤੇ ਪਿਕਅੱਪ ਕੋਡ ਦੱਸੋ।" }),
  },
  notHomeFirst: {
    en: () => ({ title: "We couldn't reach you", body: "The rider is waiting to collect your return. If they can't reach you again, the return will be cancelled." }),
    bn: () => ({ title: "আপনাকে পাওয়া যায়নি", body: "রাইডার রিটার্ন নিতে অপেক্ষা করছেন। আবার না পেলে রিটার্ন বাতিল হবে।" }),
    hi: () => ({ title: "आपसे संपर्क नहीं हो सका", body: "राइडर रिटर्न लेने के लिए इंतज़ार कर रहा है। फिर से संपर्क न हुआ तो रिटर्न रद्द हो जाएगा।" }),
    pa: () => ({ title: "ਤੁਹਾਡੇ ਨਾਲ ਸੰਪਰਕ ਨਹੀਂ ਹੋਇਆ", body: "ਰਾਈਡਰ ਰਿਟਰਨ ਲੈਣ ਲਈ ਉਡੀਕ ਕਰ ਰਿਹਾ ਹੈ। ਫਿਰ ਸੰਪਰਕ ਨਾ ਹੋਇਆ ਤਾਂ ਰਿਟਰਨ ਰੱਦ ਹੋ ਜਾਵੇਗੀ।" }),
  },
  pickedUp: {
    en: () => ({ title: "Item collected", body: "Your return is on its way to the store. The refund goes out as soon as they receive it." }),
    bn: () => ({ title: "জিনিস নেওয়া হয়েছে", body: "রিটার্ন দোকানে যাচ্ছে। পৌঁছালেই রিফান্ড হবে।" }),
    hi: () => ({ title: "सामान ले लिया गया", body: "आपका रिटर्न दुकान जा रहा है। पहुँचते ही रिफ़ंड हो जाएगा।" }),
    pa: () => ({ title: "ਸਾਮਾਨ ਲੈ ਲਿਆ ਗਿਆ", body: "ਤੁਹਾਡੀ ਰਿਟਰਨ ਦੁਕਾਨ ਜਾ ਰਹੀ ਹੈ। ਪਹੁੰਚਦੇ ਹੀ ਰਿਫੰਡ ਹੋ ਜਾਵੇਗਾ।" }),
  },
  refunded: {
    en: (a) => ({ title: "Refund done", body: `${a.amount} refunded for your return.` }),
    bn: (a) => ({ title: "রিফান্ড হয়েছে", body: `আপনার রিটার্নের জন্য ${a.amount} রিফান্ড হয়েছে।` }),
    hi: (a) => ({ title: "रिफ़ंड हो गया", body: `आपके रिटर्न के लिए ${a.amount} रिफ़ंड हुए।` }),
    pa: (a) => ({ title: "ਰਿਫੰਡ ਹੋ ਗਿਆ", body: `ਤੁਹਾਡੀ ਰਿਟਰਨ ਲਈ ${a.amount} ਰਿਫੰਡ ਹੋਏ।` }),
  },
  replacementSent: {
    en: () => ({ title: "Replacement on its way", body: "We've received your return and sent a free replacement." }),
    bn: () => ({ title: "বদলি আসছে", body: "রিটার্ন পেয়েছি, বিনামূল্যে বদলি পাঠানো হয়েছে।" }),
    hi: () => ({ title: "बदला हुआ सामान आ रहा है", body: "आपका रिटर्न मिल गया, मुफ़्त बदलाव भेज दिया गया है।" }),
    pa: () => ({ title: "ਬਦਲਿਆ ਸਾਮਾਨ ਆ ਰਿਹਾ ਹੈ", body: "ਤੁਹਾਡੀ ਰਿਟਰਨ ਮਿਲ ਗਈ, ਮੁਫ਼ਤ ਬਦਲੀ ਭੇਜ ਦਿੱਤੀ ਹੈ।" }),
  },
  review: {
    en: () => ({ title: "Return under review", body: "The rider couldn't confirm the item, so our team will check your report and get back to you." }),
    bn: () => ({ title: "রিটার্ন যাচাই হচ্ছে", body: "রাইডার জিনিসটি মিলিয়ে নিতে পারেননি, তাই আমাদের টিম দেখে জানাবে।" }),
    hi: () => ({ title: "रिटर्न की जाँच हो रही है", body: "राइडर सामान की पुष्टि नहीं कर सका, इसलिए हमारी टीम जाँच करके बताएगी।" }),
    pa: () => ({ title: "ਰਿਟਰਨ ਦੀ ਜਾਂਚ ਹੋ ਰਹੀ ਹੈ", body: "ਰਾਈਡਰ ਸਾਮਾਨ ਦੀ ਪੁਸ਼ਟੀ ਨਹੀਂ ਕਰ ਸਕਿਆ, ਇਸ ਲਈ ਸਾਡੀ ਟੀਮ ਜਾਂਚ ਕਰਕੇ ਦੱਸੇਗੀ।" }),
  },
  failed: {
    en: () => ({ title: "Return cancelled", body: "We couldn't collect the item because nobody was available. Contact support if you still need help." }),
    bn: () => ({ title: "রিটার্ন বাতিল", body: "কেউ না থাকায় জিনিসটি নেওয়া যায়নি। দরকার হলে সাহায্যে যোগাযোগ করুন।" }),
    hi: () => ({ title: "रिटर्न रद्द", body: "कोई मौजूद न होने से सामान नहीं लिया जा सका। मदद चाहिए तो सहायता से संपर्क करें।" }),
    pa: () => ({ title: "ਰਿਟਰਨ ਰੱਦ", body: "ਕੋਈ ਮੌਜੂਦ ਨਾ ਹੋਣ ਕਰਕੇ ਸਾਮਾਨ ਨਹੀਂ ਲਿਆ ਜਾ ਸਕਿਆ। ਲੋੜ ਹੋਵੇ ਤਾਂ ਸਹਾਇਤਾ ਨਾਲ ਸੰਪਰਕ ਕਰੋ।" }),
  },
};

export function returnText(note: ReturnNote, lang: Lang, args: Args = {}): Text {
  return T[note][lang](args);
}

export const rupeesText = (paise: number) => `₹${(paise / 100).toFixed(paise % 100 === 0 ? 0 : 2)}`;

/** The caller's own support chat, or null (a claim from elsewhere). */
export async function ownChatId(uid: string, raw: unknown): Promise<string | null> {
  if (typeof raw !== "string" || !/^[\w-]{1,64}$/.test(raw)) return null;
  const chat = await db.collection(CHATS).doc(raw).get();
  return chat.exists && chat.get("userId") === uid ? chat.id : null;
}

/** A system message in the support chat, in the chat's language. */
export async function tellChat(chatId: string, note: ReturnNote, args: Args = {}): Promise<void> {
  const ref = db.collection(CHATS).doc(chatId);
  const chat = await ref.get();
  if (!chat.exists) return;
  const lang = isLang(chat.get("lang")) ? (chat.get("lang") as Lang) : "en";
  const t = returnText(note, lang, args);
  await postMessages(ref, [{ from: "system", text: `${t.title}\n${t.body}` }]);
}

/**
 * Tells the customer about their claim / return: push + notification list
 * (in their language), and the support chat it came from. Never throws.
 */
export async function tellCustomer(
  issue: { orderId?: unknown; userId?: unknown; chatId?: unknown; id?: string },
  note: ReturnNote,
  args: Args = {},
): Promise<void> {
  try {
    const uid = typeof issue.userId === "string" ? issue.userId : null;
    const orderId = typeof issue.orderId === "string" ? issue.orderId : null;
    if (!uid || !orderId) return;
    const user = await db.collection("users").doc(uid).get();
    const lang = isLang(user.get("lang")) ? (user.get("lang") as Lang) : "en";
    await pushOrderCustomer(orderId, returnText(note, lang, args), { issueId: issue.id ?? "" });
    if (typeof issue.chatId === "string" && issue.chatId) await tellChat(issue.chatId, note, args);
  } catch (error) {
    logger.warn("Return: customer message failed", { note, error: String(error) });
  }
}
