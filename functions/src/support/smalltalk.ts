/**
 * Small talk the embedding model handles badly: very short messages
 * ("gm", "tq", "👍") score about the same against every entry. These are
 * matched by pattern before retrieval, in all four languages and the usual
 * romanised forms. The reply text still comes from the knowledge base entry
 * with that id, so the team edits it in the admin like any other answer.
 */

/** Knowledge-base ids the patterns map to (see chatbot-knowledge-base/). */
export type SmallTalkId = "greeting" | "goodbye" | "thanks" | "acknowledge" | "how_are_you";

export interface PreparedMessage {
  /** Text to search with: the message minus a leading greeting. */
  text: string;
  /** The whole message was small talk: answer with this entry. */
  smallTalk: SmallTalkId | null;
  /** No letters at all ("?", "...", "123"): nothing to search for. */
  empty: boolean;
}

const FILLER = String.raw`(?:\s+(?:zyppi|team|sir|madam|mam|maam|ji|bhai|bhaiya|dada|didi|there|all|everyone|friend|bro|dear))*`;

const GREETING = String.raw`(?:h+i+|h+e+l+o+|h+e+y+|hlo+|hlw|helo+|yo|hola|namaste|namaskar|nomoshkar|salaam|salam|sat\s*sri\s*akal|good\s*(?:morning|afternoon|evening|day)|gud\s*(?:m(?:o|ou)?rn(?:i)?n?g?|evening|eve)|good\s*mrng|gm|g\.m\.?|নমস্কার|হ্যালো|সুপ্রভাত|শুভ\s*সকাল|শুভ\s*সন্ধ্যা|নমস্তে|नमस्ते|नमस्कार|हैलो|हेलो|सुप्रभात|गुड\s*मॉर्निंग|शुभ\s*संध्या|ਸਤ\s*ਸ੍ਰੀ\s*ਅਕਾਲ|ਹੈਲੋ|ਸ਼ੁਭ\s*ਸਵੇਰ|ਗੁੱਡ\s*ਮਾਰਨਿੰਗ)`;

const PATTERNS: [SmallTalkId, RegExp][] = [
  [
    "thanks",
    new RegExp(
      String.raw`^(?:(?:ok+|okay|great|nice|cool)\s+)?(?:thanks?|thank\s*(?:you|u)|thanku|thnx|thx|tnx|tq|ty|tysm|thank\s*you\s*so\s*much|dhanyavad|dhanyawad|dhonnobad|shukriya|ধন্যবাদ|অনেক\s*ধন্যবাদ|धन्यवाद|शुक्रिया|ਧੰਨਵਾਦ|ਸ਼ੁਕਰੀਆ|🙏+)(?:\s+(?:so\s*much|a\s*lot|very\s*much|again))?${FILLER}$`,
      "u",
    ),
  ],
  [
    "goodbye",
    new RegExp(
      String.raw`^(?:(?:ok+|okay)\s+)?(?:b+y+e+|bye\s*bye|good\s*night|good\s*nyt|gud\s*n(?:i|y)(?:gh)?te?|gn8?|g\.n\.?|tata|see\s*(?:you|ya|u)|cya|talk\s*later|শুভ\s*রাত্রি|বিদায়|शुभ\s*रात्रि|गुड\s*नाइट|अलविदा|बाय|ਸ਼ੁਭ\s*ਰਾਤ|ਅਲਵਿਦਾ|ਬਾਏ)${FILLER}$`,
      "u",
    ),
  ],
  [
    "how_are_you",
    new RegExp(
      String.raw`^(?:${GREETING}\s+)?(?:how\s*(?:are|r)\s*(?:you|u)(?:\s*doing)?|how\s*is\s*it\s*going|what'?s\s*up|wassup|sup|kaise\s*ho|kya\s*haal\s*hai|kemon\s*(?:acho|achen)|কেমন\s*আছ(?:েন|ো)|आप\s*कैसे\s*हैं|कैसे\s*हो|ਤੁਸੀਂ\s*ਕਿਵੇਂ\s*ਹੋ|ਕੀ\s*ਹਾਲ\s*ਹੈ)${FILLER}$`,
      "u",
    ),
  ],
  ["greeting", new RegExp(String.raw`^${GREETING}${FILLER}$`, "u")],
  [
    "acknowledge",
    new RegExp(
      String.raw`^(?:o+k+|okay|okey|k+|fine|alright|got\s*it|understood|hm+|acc?h+a|thi+k\s*(?:hai|he|ache|aache)|cool|done|sure|ঠিক\s*আছে|আচ্ছা|ठीक\s*है|अच्छा|ओके|ਠੀਕ\s*ਹੈ|ਅੱਛਾ|ਓਕੇ|👍+|👌+)${FILLER}$`,
      "u",
    ),
  ],
];

/** A greeting in front of a real question ("hi, where is my order"). */
const LEADING_GREETING = new RegExp(String.raw`^${GREETING}${FILLER}[\s,.!:;-]+`, "u");

/** Lower case, punctuation (except the emoji we match) turned into spaces. */
function normalise(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^\p{L}\p{M}\p{N}\s'👍👌🙏]/gu, " ")
    .replace(/\s+/g, " ")
    .trim();
}

export function prepareMessage(raw: string): PreparedMessage {
  const text = raw.trim();
  const plain = normalise(text);
  for (const [id, re] of PATTERNS) {
    if (re.test(plain)) return { text, smallTalk: id, empty: false };
  }
  if (!/\p{L}/u.test(plain)) return { text, smallTalk: null, empty: true };
  const rest = text.toLowerCase().replace(LEADING_GREETING, "").trim();
  return { text: rest && rest !== text.toLowerCase() ? rest : text, smallTalk: null, empty: false };
}
