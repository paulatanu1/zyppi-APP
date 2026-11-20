import { describe, expect, it } from "vitest";
import { BIAS_RADIUS_M, locationBias, toDetails, toPredictions } from "../../src/places";

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

describe("locationBias", () => {
  it("biases to a circle around a point in India", () => {
    expect(locationBias({ lat: 23.33, lng: 86.36 })).toEqual({
      locationBias: { circle: { center: { latitude: 23.33, longitude: 86.36 }, radius: BIAS_RADIUS_M } },
    });
  });

  it("ignores missing, junk, (0, 0) and out-of-India points", () => {
    expect(locationBias(undefined)).toEqual({});
    expect(locationBias({ lat: "23", lng: 86 })).toEqual({});
    expect(locationBias({ lat: 0, lng: 0 })).toEqual({});
    expect(locationBias({ lat: 51.5, lng: -0.1 })).toEqual({});
    expect(locationBias({ lat: Number.NaN, lng: 86 })).toEqual({});
  });
});
