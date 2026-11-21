import { describe, expect, it } from "vitest";
import { prepareMessage } from "../../src/support/smalltalk";

const talk = (t: string) => prepareMessage(t).smallTalk;

describe("prepareMessage", () => {
  it("recognises greetings in every language and common spellings", () => {
    for (const t of ["hi", "Hiii", "hello zyppi", "Good Morning!", "gm", "gud mrng", "namaste ji", "নমস্কার", "সুপ্রভাত", "नमस्ते", "सुप्रभात", "ਸਤ ਸ੍ਰੀ ਅਕਾਲ"]) {
      expect(talk(t), t).toBe("greeting");
    }
  });

  it("recognises goodbyes, thanks, acknowledgements and how-are-you", () => {
    for (const t of ["good night", "gud nyt", "gn", "ok bye", "tata", "শুভ রাত্রি", "शुभ रात्रि", "ਸ਼ੁਭ ਰਾਤ"]) {
      expect(talk(t), t).toBe("goodbye");
    }
    for (const t of ["thanks", "thank u", "tq", "ok thanks", "thanks a lot bhai", "🙏", "ধন্যবাদ", "शुक्रिया"]) {
      expect(talk(t), t).toBe("thanks");
    }
    for (const t of ["ok", "okk", "k", "hmm", "👍", "thik hai", "ঠিক আছে"]) expect(talk(t), t).toBe("acknowledge");
    for (const t of ["how are you", "hi how r u", "kaise ho", "কেমন আছেন"]) expect(talk(t), t).toBe("how_are_you");
  });

  it("strips a leading greeting from a real question", () => {
    expect(prepareMessage("hi, where is my order?")).toMatchObject({ text: "where is my order?", smallTalk: null });
    expect(prepareMessage("Good morning sir my order is late").text).toBe("my order is late");
    // "morning" alone is not a greeting here: it changes the question.
    expect(prepareMessage("morning delivery possible?").text).toBe("morning delivery possible?");
  });

  it("leaves questions that merely contain a greeting word alone", () => {
    expect(talk("is cash ok")).toBeNull();
    expect(talk("bye the way where is my refund")).toBeNull();
    expect(prepareMessage("where is my order").text).toBe("where is my order");
  });

  it("flags messages with no letters", () => {
    for (const t of ["?", "...", "123456", "!!!"]) expect(prepareMessage(t).empty, t).toBe(true);
    expect(prepareMessage("COD?").empty).toBe(false);
  });
});
