import { describe, expect, it } from "vitest";
import { toDetails, toPredictions } from "../../src/places";

describe("places mapping (Places API New → app shape)", () => {
  it("maps autocomplete suggestions to predictions", () => {
    const out = toPredictions({
      suggestions: [
        {
          placePrediction: {
            placeId: "abc",
            text: { text: "Purulia Station, Purulia, West Bengal" },
            structuredFormat: { mainText: { text: "Purulia Station" }, secondaryText: { text: "Purulia, West Bengal" } },
            types: ["train_station"],
          },
        },
        { placePrediction: {} },
      ],
    });
    expect(out.status).toBe("OK");
    expect(out.predictions).toEqual([
      {
        description: "Purulia Station, Purulia, West Bengal",
        placeId: "abc",
        structuredFormatting: { mainText: "Purulia Station", secondaryText: "Purulia, West Bengal" },
        types: ["train_station"],
      },
    ]);
    expect(toPredictions({}).status).toBe("ZERO_RESULTS");
  });

  it("maps place details to result.geometry and addressComponents", () => {
    const out = toDetails({
      id: "abc",
      displayName: { text: "Purulia Station" },
      formattedAddress: "Station Rd, Purulia, West Bengal 723101, India",
      location: { latitude: 23.33, longitude: 86.36 },
      addressComponents: [{ longText: "723101", shortText: "723101", types: ["postal_code"] }],
    });
    expect(out.status).toBe("OK");
    expect(out.result.geometry).toEqual({ location: { lat: 23.33, lng: 86.36 } });
    expect(out.result.addressComponents[0]).toEqual({
      longName: "723101",
      shortName: "723101",
      types: ["postal_code"],
    });
    expect(toDetails({}).result.geometry).toBeNull();
  });
});
